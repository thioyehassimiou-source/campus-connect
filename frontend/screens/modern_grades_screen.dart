import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/core/services/grade_service.dart';
import 'package:campusconnect/core/services/export_service.dart';
import 'package:campusconnect/core/services/download_service.dart';
import 'package:campusconnect/controllers/grade_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModernGradesScreen extends ConsumerStatefulWidget {
  final bool isTeacher;
  const ModernGradesScreen({super.key, this.isTeacher = false});

  @override
  ConsumerState<ModernGradesScreen> createState() => _ModernGradesScreenState();
}

class _ModernGradesScreenState extends ConsumerState<ModernGradesScreen> {
  String _selectedCourse = 'Tous les cours';
  String _selectedSemester = 'Semestre 1';
  late Future<List<Grade>> _gradesFuture;

  @override
  void initState() {
    super.initState();
    // Les données sont gérées par Riverpod
  }

  @override
  Widget build(BuildContext context) {
    final gradesAsync = ref.watch(widget.isTeacher ? teacherGradesProvider : studentGradesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Text(
              'Consultation en temps réel',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.isTeacher)
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
              onPressed: _showAddGradeDialog,
            ),
          IconButton(
            icon: Icon(Icons.download, color: Theme.of(context).iconTheme.color),
            onPressed: _exportGrades,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              ref.invalidate(widget.isTeacher ? teacherGradesProvider : studentGradesProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres (Visuels seulement pour l'instant)
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCourse,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).iconTheme.color),
                            items: _buildDropdownItems(gradesAsync),
                            onChanged: (value) {
                              setState(() {
                                _selectedCourse = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          
          // Liste des notes
          Expanded(
            child: gradesAsync.when(
              data: (grades) {
                // Filtrer les notes
                final filteredGrades = grades.where((g) {
                  return _selectedCourse == 'Tous les cours' || g.subject == _selectedCourse;
                }).toList();

                if (filteredGrades.isEmpty) {
                  return Center(
                    child: Text(
                      grades.isEmpty ? 'Aucune note disponible.' : 'Aucune note pour ce cours.',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredGrades.length,
                  itemBuilder: (context, index) {
                    return _buildGradeCard(filteredGrades[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(Grade grade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grade.subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${grade.type} • Semestre ${grade.semester}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getGradeColor(grade.value).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getGradeColor(grade.value),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        grade.value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _getGradeColor(grade.value),
                        ),
                      ),
                      Text(
                        '/20',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getGradeColor(grade.value),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Coeff. ${grade.coefficient}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${grade.date.day}/${grade.date.month}/${grade.date.year}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 16) return const Color(0xFF10B981);
    if (grade >= 14) return const Color(0xFF2563EB);
    if (grade >= 12) return const Color(0xFFF59E0B);
    if (grade >= 10) return const Color(0xFFFB923C);
    return const Color(0xFFEF4444);
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(AsyncValue<List<Grade>> gradesAsync) {
    Set<String> subjects = {'Tous les cours'};
    
    gradesAsync.whenData((grades) {
      subjects.addAll(grades.map((g) => g.subject));
    });

    final sortedSubjects = subjects.toList()..sort();
    // Ensure 'Tous les cours' is first
    sortedSubjects.remove('Tous les cours');
    sortedSubjects.insert(0, 'Tous les cours');

    // Verify _selectedCourse is still valid
    if (!subjects.contains(_selectedCourse)) {
      // Defer state update to avoid build error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCourse = 'Tous les cours';
          });
        }
      });
    }

    return sortedSubjects.map((course) => DropdownMenuItem(
      value: course,
      child: Text(
        course,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    )).toList();
  }

  void _showAddGradeDialog() {
    // Form variables
    String studentId = ''; 
    String subject = '';
    String type = 'CC';
    double value = 10.0;
    double coef = 1.0;
    
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une note'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'ID Étudiant (UUID)'),
                    onChanged: (v) => studentId = v,
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                   TextFormField(
                    decoration: const InputDecoration(labelText: 'Matière'),
                    onChanged: (v) => subject = v,
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                   TextFormField(
                    decoration: const InputDecoration(labelText: 'Note (/20)'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => value = double.tryParse(v) ?? 0.0,
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                   TextFormField(
                    decoration: const InputDecoration(labelText: 'Coefficient'),
                     keyboardType: TextInputType.number,
                    onChanged: (v) => coef = double.tryParse(v) ?? 1.0,
                    initialValue: '1.0',
                  ),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: ['CC', 'Examen', 'TP', 'Projet'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => type = v!,
                    decoration: const InputDecoration(labelText: 'Type'),
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if(formKey.currentState!.validate()) {
                  try {
                    await ref.read(gradeControllerProvider.notifier).addGrade(
                      studentId: studentId,
                      subject: subject,
                      value: value,
                      coefficient: coef,
                      type: type,
                      ref: ref,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note ajoutée')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _exportGrades() async {
    try {
      // Récupérer les notes
      final gradesAsync = widget.isTeacher 
          ? ref.read(teacherGradesProvider)
          : ref.read(studentGradesProvider);
      
      await gradesAsync.when(
        data: (grades) async {
          if (grades.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aucune note à exporter')),
            );
            return;
          }

          // Calculer la moyenne
          double totalWeighted = 0;
          double totalCoeff = 0;
          for (final grade in grades) {
            totalWeighted += grade.value * grade.coefficient;
            totalCoeff += grade.coefficient;
          }
          final average = totalCoeff > 0 ? totalWeighted / totalCoeff : 0.0;

          // Générer le PDF
          final pdfBytes = await ExportService.generateGradesPdf(grades, average);
          
          // Afficher le dialogue de choix
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exporter les notes'),
                content: const Text('Choisissez une action :'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await DownloadService.sharePdf(
                        pdfBytes,
                        'notes_${DateTime.now().millisecondsSinceEpoch}.pdf',
                      );
                    },
                    child: const Text('Partager'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await DownloadService.savePdfWithPreview(
                        pdfBytes,
                        'notes_${DateTime.now().millisecondsSinceEpoch}.pdf',
                        context,
                      );
                    },
                    child: const Text('Prévisualiser'),
                  ),
                ],
              ),
            );
          }
        },
        loading: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chargement des notes...')),
          );
        },
        error: (e, st) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export: $e')),
        );
      }
    }
  }
}

