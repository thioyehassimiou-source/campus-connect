import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/core/services/academic_service.dart';
import 'package:campusconnect/core/services/profile_service.dart';
import 'package:campusconnect/controllers/course_providers.dart';
import 'package:campusconnect/screens/modern_grades_screen.dart';

class ModernCourseManagementScreen extends ConsumerStatefulWidget {
  const ModernCourseManagementScreen({super.key});

  @override
  ConsumerState<ModernCourseManagementScreen> createState() => _ModernCourseManagementScreenState();
}

class _ModernCourseManagementScreenState extends ConsumerState<ModernCourseManagementScreen> {
  String _selectedSemester = 'Semestre 1';
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    // Géré par Riverpod
  }

  void _refreshCourses() {
    ref.invalidate(teacherCoursesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(teacherCoursesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Gestion des Cours'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            onPressed: _refreshCourses,
          ),
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
            onPressed: () => _showCourseDialog(),
          ),
        ],
      ),
      body: coursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(child: Text('Aucun cours à gérer.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return _buildCourseCard(courses[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    final Color color = Color(int.parse(course.color.replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.id} • ${course.level}',
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  course.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: color),
              const SizedBox(width: 4),
              Text('${course.studentsCount} étudiants'),
              const Spacer(),
              TextButton(
                onPressed: () => _showCourseDialog(course),
                child: const Text('Modifier'),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _deleteCourse(course),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCourseDialog([Course? course]) {
    final isEditing = course != null;
    final titleController = TextEditingController(text: course?.title);
    String selectedLevel = course?.level ?? 'L1';
    String selectedColor = course?.color ?? '#2563EB';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Modifier le cours' : 'Créer un cours'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Nom du cours'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  decoration: const InputDecoration(labelText: 'Niveau'),
                  items: ['L1', 'L2', 'L3', 'M1', 'M2']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedLevel = v!),
                ),
                const SizedBox(height: 16),
                const Text('Couleur du cours', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    '#2563EB', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899'
                  ].map((c) => GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(int.parse(c.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == c ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;
                
                final notifier = ref.read(courseControllerProvider.notifier);
                if (isEditing) {
                  await notifier.updateCourse(
                    id: course.id,
                    title: titleController.text,
                    level: selectedLevel,
                    color: selectedColor,
                    ref: ref,
                  );
                } else {
                  final profile = await ProfileService.getCurrentUserProfile();
                  await notifier.createCourse(
                    title: titleController.text,
                    level: selectedLevel,
                    color: selectedColor,
                    scope: 'license',
                    departmentId: profile?['department_id']?.toString(),
                    facultyId: profile?['faculty_id']?.toString(),
                    ref: ref,
                  );
                }
                if (mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Enregistrer' : 'Créer'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCourse(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le cours'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${course.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(courseControllerProvider.notifier).deleteCourse(course.id, ref: ref);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _manageCourse(Course course) {
    // Navigation vers la gestion détaillée du cours
  }
}
