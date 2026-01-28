import 'package:flutter/material.dart';

class ModernCourseManagementScreen extends StatefulWidget {
  const ModernCourseManagementScreen({super.key});

  @override
  State<ModernCourseManagementScreen> createState() => _ModernCourseManagementScreenState();
}

class _ModernCourseManagementScreenState extends State<ModernCourseManagementScreen> {
  String _selectedSemester = 'Semestre 1';
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    setState(() {
      _courses = [
        {
          'id': 'MAT101',
          'title': 'Mathématiques Fondamentales',
          'level': 'L1',
          'students': 45,
          'status': 'Actif',
          'color': const Color(0xFF2563EB),
        },
        {
          'id': 'MAT201',
          'title': 'Analyse Numérique',
          'level': 'L2',
          'students': 40,
          'status': 'Actif',
          'color': const Color(0xFF10B981),
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Gestion des Cours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
            onPressed: _showCreateCourseDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return _buildCourseCard(course);
        },
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: course['color'],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course['id']} • ${course['level']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: course['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  course['status'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: course['color'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: course['color']),
              const SizedBox(width: 4),
              Text('${course['students']} étudiants'),
              const Spacer(),
              TextButton(
                onPressed: () => _manageCourse(course),
                child: const Text('Gérer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateCourseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un cours'),
        content: const TextField(
          decoration: InputDecoration(labelText: 'Nom du cours'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _manageCourse(Map<String, dynamic> course) {
    // Navigation vers la gestion détaillée du cours
  }
}
