import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/controllers/grade_providers.dart';
import 'package:campusconnect/core/services/grade_service.dart';
import 'package:intl/intl.dart';

class ModernStudentGradesScreen extends ConsumerStatefulWidget {
  const ModernStudentGradesScreen({super.key});

  @override
  ConsumerState<ModernStudentGradesScreen> createState() => _ModernStudentGradesScreenState();
}

class _ModernStudentGradesScreenState extends ConsumerState<ModernStudentGradesScreen> {
  String _selectedSemester = 'Semestre 1';
  // Removed local data

  @override
  void initState() {
    super.initState();
  }

  void _refreshData() {
    ref.invalidate(studentGradesProvider);
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
              'Mes Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Text(
              'Suivi académique',
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
            icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: Icon(Icons.download, color: Theme.of(context).iconTheme.color),
            onPressed: _exportGrades,
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final gradesAsync = ref.watch(studentGradesProvider);
          
          return gradesAsync.when(
            data: (grades) {
              if (grades.isEmpty) {
                return const Center(child: Text('Aucune note enregistrée.'));
              }
              
              // Filtrage par semestre
              final semesterKey = _selectedSemester == 'Semestre 1' ? 'S1' : 'S2';
              final filteredGrades = grades.where((g) => g.semester == semesterKey).toList();
              
              // Calcul des stats
              double totalValue = 0;
              double totalCoeff = 0;
              for (var g in filteredGrades) {
                totalValue += g.value * g.coefficient;
                totalCoeff += g.coefficient;
              }
              final average = totalCoeff > 0 ? totalValue / totalCoeff : 0.0;
              
              return Column(
                children: [
                  // Carte d'information étudiant (Stats dynamiques)
                  _buildStudentInfoCard(average, filteredGrades.length),
                  
                  // Filtre par semestre
                  _buildSemesterFilter(),
                  
                  // Liste des notes
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredGrades.length,
                      itemBuilder: (context, index) {
                        return _buildGradeCard(filteredGrades[index]);
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Erreur: $e')),
          );
        },
      ),
    );
  }

  Widget _buildStudentInfoCard(double average, int totalGrades) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
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
                child: const Icon(Icons.school, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mon Profil Académique',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      'Suivi des résultats',
                      style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
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
                  '${average.toStringAsFixed(2)}/20',
                  Icons.grade,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Évaluations',
                  '$totalGrades',
                  Icons.assignment,
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Color(0xFF2563EB), size: 20),
          const SizedBox(width: 12),
          Text(
            'Semestre',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSemester,
                icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).iconTheme.color),
                items: ['Semestre 1', 'Semestre 2']
                    .map((semester) => DropdownMenuItem(
                          value: semester,
                          child: Text(
                            semester,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        grade.type,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
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
                    color: _getGradeColor(grade.value).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
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
                          fontSize: 20,
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
                  DateFormat('dd/MM/yyyy').format(grade.date),
                  style: const TextStyle(
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
                widthFactor: grade.value / 20 > 1.0 ? 1.0 : grade.value / 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getGradeColor(grade.value),
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
