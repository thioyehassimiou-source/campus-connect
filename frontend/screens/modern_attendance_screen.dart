import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/controllers/attendance_providers.dart';
import 'package:campusconnect/controllers/course_providers.dart';

class ModernAttendanceScreen extends ConsumerStatefulWidget {
  const ModernAttendanceScreen({super.key});

  @override
  ConsumerState<ModernAttendanceScreen> createState() => _ModernAttendanceScreenState();
}

class _ModernAttendanceScreenState extends ConsumerState<ModernAttendanceScreen> {
  String? _selectedCourseId;
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _attendanceStatus = {}; // studentId -> status (present/absent/late)
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    // Initialisé via Riverpod
  }

  void _refreshStudents() {
    if (_selectedCourseId != null) {
      ref.invalidate(studentsForCourseProvider(_selectedCourseId!));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Gestion des Présences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              'Émargement numérique',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Theme.of(context).primaryColor),
            onPressed: _saveAttendance,
          ),
          IconButton(
            icon: Icon(Icons.share, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
            onPressed: _shareAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final coursesAsync = ref.watch(teacherCoursesProvider);
                      
                      return coursesAsync.when(
                        data: (courses) {
                          if (courses.isEmpty) return const Text('Aucun cours');
                          _selectedCourseId ??= courses.first.id;
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCourseId,
                                isExpanded: true,
                                icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                                items: courses.map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.title, style: const TextStyle(fontSize: 14)),
                                )).toList(),
                                onChanged: (v) => setState(() => _selectedCourseId = v),
                              ),
                            ),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, st) => Text('Erreur: $e'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _isInit = false;
                          _attendanceStatus.clear();
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 14),
                          ),
                          Icon(Icons.calendar_today, size: 16, color: Theme.of(context).primaryColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Statistiques gérées dynamiquement par la liste
          const SizedBox(height: 16),
          
          // Actions rapides
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _markAll(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Tous présents'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _markAll(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Tous absents'),
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des étudiants
          Expanded(
            child: _selectedCourseId == null 
              ? const Center(child: Text('Veuillez sélectionner un cours'))
              : Consumer(
                  builder: (context, ref, child) {
                    final studentsAsync = ref.watch(studentsForCourseProvider(_selectedCourseId!));
                    
                    // On observe aussi les présences existantes si on ne les a pas encore chargées
                    if (!_isInit) {
                      ref.listen(attendanceByDateProvider((course: _selectedCourseId!, date: _selectedDate)), (previous, next) {
                        next.whenData((records) {
                          if (records.isNotEmpty && !_isInit) {
                            setState(() {
                              for (var r in records) {
                                _attendanceStatus[r.studentId] = r.status;
                              }
                              _isInit = true;
                            });
                          }
                        });
                      });
                    }

                    return studentsAsync.when(
                      data: (students) {
                        if (students.isEmpty) return const Center(child: Text('Aucun étudiant.'));
                        
                        // Initialisation par défaut si pas de données existantes
                        if (!_isInit && students.isNotEmpty) {
                          for (var s in students) {
                            if (!_attendanceStatus.containsKey(s['id'])) {
                              _attendanceStatus[s['id']] = 'present';
                            }
                          }
                          _isInit = true;
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final status = _attendanceStatus[student['id']] ?? 'present';
                            return _buildStudentCard(student, status);
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text('Erreur: $e')),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Photo - unchanged
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: student['photo'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        student['photo'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.person, color: Color(0xFF2563EB), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'],
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    student['id'], 
                    style: TextStyle(
                      fontSize: 12, 
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            // Statuts
            Row(
              children: [
                _buildStatusBtn(student['id'], 'present', Icons.check_circle, Colors.green, status == 'present'),
                const SizedBox(width: 8),
                _buildStatusBtn(student['id'], 'absent', Icons.cancel, Colors.red, status == 'absent'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBtn(String studentId, String targetStatus, IconData icon, Color color, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _attendanceStatus[studentId] = targetStatus),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? color : Colors.grey.shade300),
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 20),
      ),
    );
  }

  void _markAll(bool present) {
    if (_selectedCourseId == null) return;
    final students = ref.read(studentsForCourseProvider(_selectedCourseId!)).value ?? [];
    setState(() {
      for (var s in students) {
        _attendanceStatus[s['id']] = present ? 'present' : 'absent';
      }
    });
  }

  Future<void> _saveAttendance() async {
    if (_selectedCourseId == null) return;
    if (_attendanceStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucune donnée à enregistrer')));
      return;
    }

    try {
      await ref.read(attendanceControllerProvider.notifier).saveAttendance(
            course: _selectedCourseId!,
            statuses: _attendanceStatus,
            date: _selectedDate,
            ref: ref,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Présences enregistrées!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  void _shareAttendance() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partage de la liste...')));
  }
}
