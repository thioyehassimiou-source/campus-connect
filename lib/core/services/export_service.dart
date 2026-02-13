import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../services/grade_service.dart';
import 'schedule_service.dart';

class ExportService {
  /// Génère un PDF des notes de l'étudiant
  static Future<Uint8List> generateGradesPdf(List<Grade> grades, double average) async {
    final pdf = pw.Document();

    // Grouper les notes par matière
    final Map<String, List<Grade>> gradesBySubject = {};
    for (final grade in grades) {
      if (!gradesBySubject.containsKey(grade.subject)) {
        gradesBySubject[grade.subject] = [];
      }
      gradesBySubject[grade.subject]!.add(grade);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // En-tête
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Relevé de Notes',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Généré le ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.Divider(thickness: 2),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Moyenne générale
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Moyenne Générale',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${average.toStringAsFixed(2)}/20',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: average >= 10 ? PdfColors.green : PdfColors.red,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Tableau des notes par matière
          ...gradesBySubject.entries.map((entry) {
            final subject = entry.key;
            final subjectGrades = entry.value;
            
            // Calculer la moyenne de la matière
            double totalWeighted = 0;
            double totalCoeff = 0;
            for (final g in subjectGrades) {
              totalWeighted += g.value * g.coefficient;
              totalCoeff += g.coefficient;
            }
            final subjectAverage = totalCoeff > 0 ? totalWeighted / totalCoeff : 0;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      subject,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Moyenne: ${subjectAverage.toStringAsFixed(2)}/20',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: subjectAverage >= 10 ? PdfColors.green : PdfColors.orange,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    // En-tête du tableau
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _buildTableCell('Type', isHeader: true),
                        _buildTableCell('Note', isHeader: true),
                        _buildTableCell('Coef.', isHeader: true),
                        _buildTableCell('Date', isHeader: true),
                      ],
                    ),
                    // Lignes de notes
                    ...subjectGrades.map((g) => pw.TableRow(
                      children: [
                        _buildTableCell(g.type),
                        _buildTableCell('${g.value.toStringAsFixed(1)}/20'),
                        _buildTableCell(g.coefficient.toString()),
                        _buildTableCell(DateFormat('dd/MM/yy').format(g.date)),
                      ],
                    )),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],
            );
          }),

          // Pied de page
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text(
            'Total: ${grades.length} note(s)',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Génère un PDF de l'emploi du temps
  static Future<Uint8List> generateSchedulePdf(List<ScheduleItem> items) async {
    final pdf = pw.Document();

    // Grouper par jour
    final Map<String, List<ScheduleItem>> itemsByDay = {
      'Lundi': [],
      'Mardi': [],
      'Mercredi': [],
      'Jeudi': [],
      'Vendredi': [],
      'Samedi': [],
    };

    for (final item in items) {
      final dayName = DateFormat('EEEE', 'fr_FR').format(item.startTime);
      final normalizedDay = _normalizeDayName(dayName);
      if (itemsByDay.containsKey(normalizedDay)) {
        itemsByDay[normalizedDay]!.add(item);
      }
    }

    // Trier par heure
    for (final day in itemsByDay.keys) {
      itemsByDay[day]!.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          // En-tête
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Emploi du Temps',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Semaine du ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.Divider(thickness: 2),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Grille horaire
          ...itemsByDay.entries.map((entry) {
            final day = entry.key;
            final dayItems = entry.value;

            if (dayItems.isEmpty) return pw.SizedBox();

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    day,
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 8),
                ...dayItems.map((item) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8, left: 16),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 80,
                        child: pw.Text(
                          '${DateFormat('HH:mm').format(item.startTime)} - ${DateFormat('HH:mm').format(item.endTime)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.subject,
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Salle: ${item.room} • ${item.teacher}',
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                pw.SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static String _normalizeDayName(String dayName) {
    final Map<String, String> dayMapping = {
      'lundi': 'Lundi',
      'mardi': 'Mardi',
      'mercredi': 'Mercredi',
      'jeudi': 'Jeudi',
      'vendredi': 'Vendredi',
      'samedi': 'Samedi',
      'dimanche': 'Dimanche',
    };
    return dayMapping[dayName.toLowerCase()] ?? dayName;
  }
}
