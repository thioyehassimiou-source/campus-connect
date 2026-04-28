import 'package:flutter/material.dart';
import 'package:campusconnect/core/services/schedule_service.dart';
import 'package:campusconnect/core/services/export_service.dart';
import 'package:campusconnect/core/services/download_service.dart';
import 'package:campusconnect/shared/models/course_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModernScheduleScreen extends StatefulWidget {
  final bool isTeacher;
  final bool isDP; // Directeur de Programme

  const ModernScheduleScreen({
    super.key,
    this.isTeacher = false,
    this.isDP = false, // Par défaut non-DP
  });

  @override
  State<ModernScheduleScreen> createState() => _ModernScheduleScreenState();
}

class _ModernScheduleScreenState extends State<ModernScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  late Future<List<CourseModel>> _scheduleFuture;
  final List<String> weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  bool _isDpMode = false; // Toggle local pour la démo si isDP n'est pas passé explicitement ou pour switch

  @override
  void initState() {
    super.initState();
    _isDpMode = widget.isDP;
    _refreshSchedule();
  }

  void _refreshSchedule() {
    setState(() {
      if (_isDpMode) {
        _scheduleFuture = _fetchPendingSchedules();
      } else if (widget.isTeacher) {
        _scheduleFuture = _fetchTeacherProposals();
      } else {
        _scheduleFuture = _fetchValidatedSchedule();
      }
    });
  }

  Future<List<CourseModel>> _fetchValidatedSchedule() async {
    final items = await ScheduleService.getValidatedSchedule();
    return items.map(_mapToCourse).toList();
  }

  Future<List<CourseModel>> _fetchTeacherProposals() async {
    final items = await ScheduleService.getTeacherProposals();
    return items.map(_mapToCourse).toList();
  }

  Future<List<CourseModel>> _fetchPendingSchedules() async {
    final items = await ScheduleService.getPendingSchedules();
    return items.map(_mapToCourse).toList();
  }

  CourseModel _mapToCourse(ScheduleItem item) {
    return CourseModel(
      id: item.id,
      subject: item.subject,
      teacher: item.teacher, // Utilise le nom directement
      room: item.room,
      startTime: item.startTime,
      endTime: item.endTime,
      day: DayOfWeek.values[item.startTime.weekday - 1], // 1=Lun -> 0
      color: _getStatusColor(item.status),
      status: _mapStatus(item.status),
    );
  }

  CourseStatus _mapStatus(int status) {
    switch (status) {
      case 3: return CourseStatus.pending;
      case 0: return CourseStatus.validated;
      case 4: return CourseStatus.rejected;
      default: return CourseStatus.scheduled;
    }
  }

  String _getStatusColor(int status) {
    switch (status) {
      case 3: return '#F59E0B'; // Orange
      case 0: return '#10B981'; // Green
      case 4: return '#EF4444'; // Red
      default: return '#3B82F6'; // Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si mode DP, on montre une liste globale (pas filtrée par jour pour faciliter la supervision)
    // ou on garde le filtre jour ? Pour la supervision, souvent on veut voir tout ce qui est en attente.
    // On va garder le filtre jour pour l'emploi du temps classique, mais pour DP "En attente", on pourrait tout montrer.
    // Disons qu'on garde la structure par jour pour l'instant pour cohérence.

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isDpMode ? 'Supervision (DP)' : 'Emploi du temps',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
             Text(
              '${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Theme.of(context).iconTheme.color),
            onPressed: _exportSchedule,
            tooltip: 'Exporter l\'emploi du temps',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
            onPressed: _refreshSchedule,
          ),
          // Toggle DP Mode pour la démo si Enseignant (Simule switch rôle)
          if (widget.isTeacher)
            IconButton(
              icon: Icon(_isDpMode ? Icons.person : Icons.admin_panel_settings, 
                color: _isDpMode ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color),
              onPressed: () {
                setState(() {
                  _isDpMode = !_isDpMode;
                  _refreshSchedule();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_isDpMode ? 'Mode Supervision activé' : 'Mode Enseignant activé')),
                );
              },
              tooltip: 'Basculer mode Supervision',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: FutureBuilder<List<CourseModel>>(
              future: _scheduleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                
                final allCourses = snapshot.data ?? [];
                
                // Filtrer par jour sélectionné
                final dayCourses = allCourses.where((c) => 
                  c.startTime.day == selectedDate.day && 
                  c.startTime.month == selectedDate.month && 
                  c.startTime.year == selectedDate.year
                ).toList();

                if (dayCourses.isEmpty) {
                   // Si DP et rien ce jour, on affiche peut être un message "Rien en attente ce jour"
                   return Center(child: Text(_isDpMode 
                     ? 'Aucune proposition en attente pour ce jour.' 
                     : 'Aucun cours prévu.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dayCourses.length,
                  itemBuilder: (context, index) {
                    return _buildCourseCard(dayCourses[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: (widget.isTeacher && !_isDpMode) 
          ? FloatingActionButton.extended(
              onPressed: _showAddCourseDialog,
              label: const Text('Proposer'),
              icon: const Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }

  Widget _buildDaySelector() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 14, // 2 semaines
          itemBuilder: (context, index) {
             final dayDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index));
             final isSelected = selectedDate.day == dayDate.day && selectedDate.month == dayDate.month;
             
             return GestureDetector(
               onTap: () => setState(() => selectedDate = dayDate),
               child: Container(
                 width: 60,
                 margin: const EdgeInsets.symmetric(horizontal: 4),
                 decoration: BoxDecoration(
                   color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor),
                 ),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text(weekDays[dayDate.weekday - 1], 
                       style: TextStyle(color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color)),
                     Text('${dayDate.day}',
                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                         color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color)),
                   ],
                 ),
               ),
             );
          },
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    Color color = _parseColor(course.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4, height: 40,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.subject, 
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text('${course.startTimeFormatted} - ${course.endTimeFormatted}', 
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ],
                  ),
                ),
                _buildStatusBadge(course.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.room, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(course.room),
                const Spacer(),
                if (_isDpMode && course.status == CourseStatus.pending) ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _validateCourse(course),
                    tooltip: 'Valider',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _rejectCourse(course),
                    tooltip: 'Rejeter',
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(CourseStatus status) {
    Color color;
    String text;
    switch (status) {
      case CourseStatus.pending:
        color = Colors.orange;
        text = 'EN ATTENTE';
        break;
      case CourseStatus.validated:
        color = Colors.green;
        text = 'VALIDÉ';
        break;
      case CourseStatus.rejected:
        color = Colors.red;
        text = 'REJETÉ';
        break;
      default:
        color = Colors.blue;
        text = 'PROGRAMMÉ';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  Future<void> _validateCourse(CourseModel course) async {
    try {
      await ScheduleService.validateSchedule(course.id);
      _refreshSchedule();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Validé !')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _rejectCourse(CourseModel course) async {
    // Show dialog for reason
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motif du rejet'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Raison...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ScheduleService.rejectSchedule(course.id, controller.text);
                _refreshSchedule();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejeté.')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showAddCourseDialog() {
    String subject = '';
    String room = '';
    TimeOfDay start = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Proposer un cours'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Matière'),
                  onChanged: (v) => subject = v,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Salle'),
                  onChanged: (v) => room = v,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: start);
                        if (t != null) setDialogState(() => start = t);
                      },
                      child: Text('Début: ${start.format(context)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: end);
                        if (t != null) setDialogState(() => end = t);
                      },
                      child: Text('Fin: ${end.format(context)}'),
                    ),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () async {
                  if (subject.isNotEmpty && room.isNotEmpty) {
                    try {
                      final now = selectedDate;
                      final startDt = DateTime(now.year, now.month, now.day, start.hour, start.minute);
                      final endDt = DateTime(now.year, now.month, now.day, end.hour, end.minute);
                      
                      await ScheduleService.proposeSchedule(
                        subject: subject,
                        startTime: startDt,
                        endTime: endDt,
                        room: room,
                        day: startDt.weekday - 1,
                        type: 'CM', // Default or add selector
                      );
                      Navigator.pop(context);
                      _refreshSchedule();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proposition envoyée')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                    }
                  }
                },
                child: const Text('Proposer'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _exportSchedule() async {
    try {
      final schedules = await _scheduleFuture;
      
      if (schedules.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun cours à exporter')),
        );
        return;
      }

      // Convertir CourseModel en ScheduleItem pour le service
      final scheduleItems = schedules.map((course) => ScheduleItem(
        id: course.id,
        subject: course.subject,
        teacher: course.teacher,
        room: course.room,
        startTime: course.startTime,
        endTime: course.endTime,
        day: course.day.index,
        type: 'CM',
        status: course.status == CourseStatus.validated ? 0 : 3,
      )).toList();

      // Générer le PDF
      final pdfBytes = await ExportService.generateSchedulePdf(scheduleItems);
      
      // Afficher le dialogue de choix
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exporter l\'emploi du temps'),
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
                    'emploi_du_temps_${DateTime.now().millisecondsSinceEpoch}.pdf',
                  );
                },
                child: const Text('Partager'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await DownloadService.savePdfWithPreview(
                    pdfBytes,
                    'emploi_du_temps_${DateTime.now().millisecondsSinceEpoch}.pdf',
                    context,
                  );
                },
                child: const Text('Prévisualiser'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export: $e')),
        );
      }
    }
  }
}
