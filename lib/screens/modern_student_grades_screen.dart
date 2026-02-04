import 'package:flutter/material.dart';

class ModernStudentGradesScreen extends StatefulWidget {
  const ModernStudentGradesScreen({super.key});

  @override
  State<ModernStudentGradesScreen> createState() => _ModernStudentGradesScreenState();
}

class _ModernStudentGradesScreenState extends State<ModernStudentGradesScreen> {
  String _selectedSemester = 'Semestre 1';
  List<Map<String, dynamic>> _grades = [];
  Map<String, dynamic>? _studentInfo;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  void _loadGrades() {
    // Simulation de chargement des notes de l'étudiant
    setState(() {
      _studentInfo = {
        'name': 'Alice Martin',
        'id': 'ET2024001',
        'program': 'Licence Informatique',
        'level': 'L2',
        'average': 15.2,
        'credits': 45,
        'rank': 12,
        'totalStudents': 120,
      };
      
      _grades = [
        {
          'course': 'Mathématiques',
          'evaluation': 'Examen Final',
          'grade': 16.5,
          'coefficient': 3,
          'credits': 6,
          'date': '15/12/2024',
          'status': 'published',
          'teacher': 'Prof. Bernard',
        },
        {
          'course': 'Mathématiques',
          'evaluation': 'TP Noté',
          'grade': 18.0,
          'coefficient': 1,
          'credits': 2,
          'date': '10/12/2024',
          'status': 'published',
          'teacher': 'Prof. Bernard',
        },
        {
          'course': 'Physique',
          'evaluation': 'Examen Final',
          'grade': 14.0,
          'coefficient': 3,
          'credits': 6,
          'date': '18/12/2024',
          'status': 'published',
          'teacher': 'Prof. Dubois',
        },
        {
          'course': 'Informatique',
          'evaluation': 'Projet',
          'grade': 17.5,
          'coefficient': 2,
          'credits': 4,
          'date': '20/12/2024',
          'status': 'published',
          'teacher': 'Prof. Leroy',
        },
        {
          'course': 'Algorithmique',
          'evaluation': 'Contrôle Continu',
          'grade': 15.0,
          'coefficient': 2,
          'credits': 4,
          'date': '05/12/2024',
          'status': 'published',
          'teacher': 'Prof. Martin',
        },
        {
          'course': 'Base de Données',
          'evaluation': 'Examen Final',
          'grade': 13.5,
          'coefficient': 2,
          'credits': 4,
          'date': '22/12/2024',
          'status': 'published',
          'teacher': 'Prof. Petit',
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
              'Mes Notes',
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
            icon: Icon(Icons.download, color: Color(0xFF64748B)),
            onPressed: _exportGrades,
          ),
        ],
      ),
      body: Column(
        children: [
          // Carte d'information étudiant
          if (_studentInfo != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _studentInfo!['name'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${_studentInfo!['program']} • ${_studentInfo!['level']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'ID: ${_studentInfo!['id']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Moyenne',
                          '${_studentInfo!['average'].toStringAsFixed(1)}/20',
                          Icons.grade,
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Crédits',
                          '${_studentInfo!['credits']}/60',
                          Icons.workspace_premium,
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Classement',
                          '${_studentInfo!['rank']}/${_studentInfo!['totalStudents']}',
                          Icons.leaderboard,
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Filtre par semestre
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                Icon(
                  Icons.calendar_today,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Semestre',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSemester,
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
              ],
            ),
          ),
          
          // Liste des notes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(Map<String, dynamic> grade) {
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
                        grade['course'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        grade['evaluation'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prof. ${grade['teacher']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _getGradeColor(grade['grade']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
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
                          fontSize: 20,
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
                    'Coeff. ${grade['coefficient']}',
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
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${grade['credits']} crédits',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
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
            Container(
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: grade['grade'] / 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getGradeColor(grade['grade']),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
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

  void _exportGrades() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Exporter mes notes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
                title: Text('Relevé de notes PDF'),
                subtitle: Text('Format officiel pour impression'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Génération du PDF en cours...'),
                      backgroundColor: Color(0xFF2563EB),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart, color: Color(0xFF10B981)),
                title: Text('Excel'),
                subtitle: Text('Pour analyse personnelle'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export Excel en cours...'),
                      backgroundColor: Color(0xFF2563EB),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }
}
