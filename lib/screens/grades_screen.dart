import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/shared/models/grade_model.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:campusconnect/core/services/firebase_service.dart';

class GradesScreen extends StatefulWidget {
  final UserModel user;

  const GradesScreen({super.key, required this.user});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  List<GradeModel> _grades = [];
  bool _isLoading = true;
  String _selectedCourse = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);

    try {
      QuerySnapshot querySnapshot;
      
      if (widget.user.role == UserRole.teacher) {
        // Teacher sees grades for courses they teach
        querySnapshot = await FirebaseService.firestore
            .collection('grades')
            .where('teacherId', isEqualTo: widget.user.id)
            .get();
      } else {
        // Student sees their own grades
        querySnapshot = await FirebaseService.firestore
            .collection('grades')
            .where('studentId', isEqualTo: widget.user.id)
            .get();
      }

      final grades = querySnapshot.docs
          .map((doc) => GradeModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _grades = grades;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  List<GradeModel> get _filteredGrades {
    if (_selectedCourse == 'Tous') return _grades;
    return _grades.where((grade) => grade.courseName == _selectedCourse).toList();
  }

  List<String> get _courses {
    final courses = _grades.map((grade) => grade.courseName).toSet().toList();
    courses.sort();
    return ['Tous', ...courses];
  }

  double get _average {
    if (_filteredGrades.isEmpty) return 0.0;
    
    final totalWeighted = _filteredGrades.fold<double>(
      0.0,
      (sum, grade) => sum + grade.weightedValue,
    );
    
    final totalMaxWeighted = _filteredGrades.fold<double>(
      0.0,
      (sum, grade) => sum + grade.weightedMaxValue,
    );
    
    return totalMaxWeighted > 0 ? (totalWeighted / totalMaxWeighted) * 20 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGrades,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Card
                if (widget.user.role == UserRole.student) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Moyenne générale',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _average.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_filteredGrades.length} note(s)',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Course Filter
                if (_courses.length > 1)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCourse,
                        isExpanded: true,
                        items: _courses.map((course) {
                          return DropdownMenuItem(
                            value: course,
                            child: Text(course),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCourse = value!;
                          });
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Grades List
                Expanded(
                  child: _filteredGrades.isEmpty
                      ? const Center(
                          child: Text('Aucune note disponible'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredGrades.length,
                          itemBuilder: (context, index) {
                            final grade = _filteredGrades[index];
                            return _buildGradeCard(grade);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildGradeCard(GradeModel grade) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(grade.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    grade.typeDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy').format(grade.date),
                  style: AppTheme.captionStyle,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              grade.title,
              style: AppTheme.subheadingStyle,
            ),
            
            const SizedBox(height: 4),
            
            Text(
              grade.courseName,
              style: AppTheme.bodyStyle.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                // Grade Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getGradeColor(grade.percentage),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    grade.gradeDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Percentage
                Text(
                  '${grade.percentage.toStringAsFixed(1)}%',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const Spacer(),
                
                // Coefficient
                if (grade.coefficient != 1) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Coeff: ${grade.coefficient}',
                      style: AppTheme.captionStyle,
                    ),
                  ),
                ],
              ],
            ),
            
            if (grade.feedback != null && grade.feedback!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commentaire:',
                      style: AppTheme.captionStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      grade.feedback!,
                      style: AppTheme.bodyStyle,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(GradeType type) {
    switch (type) {
      case GradeType.exam:
        return AppTheme.errorColor;
      case GradeType.assignment:
        return AppTheme.primaryColor;
      case GradeType.project:
        return AppTheme.successColor;
      case GradeType.participation:
        return AppTheme.warningColor;
      case GradeType.quiz:
        return Colors.purple;
    }
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 80) return AppTheme.successColor;
    if (percentage >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
