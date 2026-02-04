import 'package:flutter/material.dart';

class ModernGradesScreen extends StatefulWidget {
  const ModernGradesScreen({super.key});

  @override
  State<ModernGradesScreen> createState() => _ModernGradesScreenState();
}

class _ModernGradesScreenState extends State<ModernGradesScreen> {
  String _selectedCourse = 'Tous les cours';
  String _selectedSemester = 'Semestre 1';
  List<Map<String, dynamic>> _grades = [];

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  void _loadGrades() {
    // Simulation de chargement des notes
    setState(() {
      _grades = [
        {
          'studentName': 'Alice Martin',
          'studentId': 'ET2024001',
          'course': 'Mathématiques',
          'evaluation': 'Examen Final',
          'grade': 16.5,
          'coefficient': 3,
          'date': '15/12/2024',
          'status': 'published',
        },
        {
          'studentName': 'Bob Bernard',
          'studentId': 'ET2024002',
          'course': 'Mathématiques',
          'evaluation': 'Examen Final',
          'grade': 14.0,
          'coefficient': 3,
          'date': '15/12/2024',
          'status': 'published',
        },
        {
          'studentName': 'Claire Dubois',
          'studentId': 'ET2024003',
          'course': 'Mathématiques',
          'evaluation': 'Examen Final',
          'grade': 18.0,
          'coefficient': 3,
          'date': '15/12/2024',
          'status': 'published',
        },
        {
          'studentName': 'David Petit',
          'studentId': 'ET2024004',
          'course': 'Mathématiques',
          'evaluation': 'Examen Final',
          'grade': 12.5,
          'coefficient': 3,
          'date': '15/12/2024',
          'status': 'draft',
        },
        {
          'studentName': 'Emma Leroy',
          'studentId': 'ET2024005',
          'course': 'Physique',
          'evaluation': 'TP Noté',
          'grade': 15.0,
          'coefficient': 2,
          'date': '10/12/2024',
          'status': 'published',
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
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
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
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${_grades.length} évaluations',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFF2563EB)),
            onPressed: _showAddGradeDialog,
          ),
          IconButton(
            icon: Icon(Icons.download, color: Color(0xFF64748B)),
            onPressed: _exportGrades,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCourse,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                            items: ['Tous les cours', 'Mathématiques', 'Physique', 'Informatique']
                                .map((course) => DropdownMenuItem(
                                      value: course,
                                      child: Text(
                                        course,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCourse = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSemester,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                            items: ['Semestre 1', 'Semestre 2']
                                .map((semester) => DropdownMenuItem(
                                      value: semester,
                                      child: Text(
                                        semester,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSemester = value!;
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
          
          // Statistiques
          Container(
            margin: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '15.2',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Moyenne',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.people,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_grades.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Étudiants',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.pending,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_grades.where((g) => g['status'] == 'draft').length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Brouillons',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des notes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _grades.length,
              itemBuilder: (context, index) {
                final grade = _grades[index];
                return _buildGradeCard(grade);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(Map<String, dynamic> grade) {
    final isPublished = grade['status'] == 'published';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                        grade['studentName'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${grade['studentId']} • ${grade['course']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
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
                    color: _getGradeColor(grade['grade']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getGradeColor(grade['grade']),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        grade['grade'].toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _getGradeColor(grade['grade']),
                        ),
                      ),
                      Text(
                        '/20',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getGradeColor(grade['grade']),
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
                    grade['evaluation'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Coeff. ${grade['coefficient']}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  grade['date'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!isPublished)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Brouillon',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => _editGrade(grade),
                  child: Text(
                    'Modifier',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isPublished)
                  TextButton(
                    onPressed: () => _viewGradeDetails(grade),
                    child: Text(
                      'Détails',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
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

  void _showAddGradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une note'),
          content: Text('Fonctionnalité à implémenter'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _editGrade(Map<String, dynamic> grade) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier la note'),
          content: Text('Modifier la note de ${grade['studentName']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note modifiée avec succès'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _viewGradeDetails(Map<String, dynamic> grade) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails - ${grade['studentName']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Note: ${grade['grade']}/20'),
              Text('Évaluation: ${grade['evaluation']}'),
              Text('Coefficient: ${grade['coefficient']}'),
              Text('Date: ${grade['date']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _exportGrades() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export des notes en cours...'),
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }
}
