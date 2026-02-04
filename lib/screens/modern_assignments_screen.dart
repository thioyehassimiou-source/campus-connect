import 'package:flutter/material.dart';

class ModernAssignmentsScreen extends StatefulWidget {
  const ModernAssignmentsScreen({super.key});

  @override
  State<ModernAssignmentsScreen> createState() => _ModernAssignmentsScreenState();
}

class _ModernAssignmentsScreenState extends State<ModernAssignmentsScreen> {
  String _selectedFilter = 'Tous';
  List<Map<String, dynamic>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  void _loadAssignments() {
    // Simulation de chargement des devoirs
    setState(() {
      _assignments = [
        {
          'id': '1',
          'title': 'Projet d\'Algorithmique',
          'course': 'Algorithmique',
          'teacher': 'Prof. Martin',
          'description': 'Implémenter un algorithme de tri avancé avec analyse de complexité',
          'type': 'Projet',
          'dueDate': '15/01/2025',
          'dueTime': '23:59',
          'status': 'pending',
          'priority': 'high',
          'submitted': false,
          'grade': null,
          'maxGrade': 20,
          'attachments': ['sujet.pdf', 'exemples.zip'],
          'submissionCount': 12,
          'maxSubmissions': 45,
        },
        {
          'id': '2',
          'title': 'TP Base de Données',
          'course': 'Base de Données',
          'teacher': 'Prof. Petit',
          'description': 'Créer une base de données relationnelle pour une bibliothèque',
          'type': 'TP',
          'dueDate': '10/01/2025',
          'dueTime': '18:00',
          'status': 'submitted',
          'priority': 'medium',
          'submitted': true,
          'grade': 16.5,
          'maxGrade': 20,
          'attachments': ['tp_sujet.pdf'],
          'submissionCount': 38,
          'maxSubmissions': 45,
        },
        {
          'id': '3',
          'title': 'Rapport de Physique',
          'course': 'Physique',
          'teacher': 'Prof. Dubois',
          'description': 'Rapport sur les expériences de mécanique quantique',
          'type': 'Rapport',
          'dueDate': '20/01/2025',
          'dueTime': '14:00',
          'status': 'pending',
          'priority': 'medium',
          'submitted': false,
          'grade': null,
          'maxGrade': 20,
          'attachments': ['guide_rapport.pdf'],
          'submissionCount': 8,
          'maxSubmissions': 45,
        },
        {
          'id': '4',
          'title': 'Exercices Mathématiques',
          'course': 'Mathématiques',
          'teacher': 'Prof. Bernard',
          'description': 'Exercices 1 à 15 du chapitre 3 sur les intégrales',
          'type': 'Exercices',
          'dueDate': '08/01/2025',
          'dueTime': '10:00',
          'status': 'graded',
          'priority': 'low',
          'submitted': true,
          'grade': 18.0,
          'maxGrade': 20,
          'attachments': ['exercices.pdf'],
          'submissionCount': 42,
          'maxSubmissions': 45,
        },
        {
          'id': '5',
          'title': 'Présentation Informatique',
          'course': 'Informatique',
          'teacher': 'Prof. Leroy',
          'description': 'Présentation sur les technologies web modernes (10 min)',
          'type': 'Présentation',
          'dueDate': '25/01/2025',
          'dueTime': '12:00',
          'status': 'pending',
          'priority': 'high',
          'submitted': false,
          'grade': null,
          'maxGrade': 20,
          'attachments': ['consignes.pdf', 'evaluation.pdf'],
          'submissionCount': 5,
          'maxSubmissions': 45,
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
              'Devoirs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${_assignments.where((a) => a['status'] == 'pending').length} en attente',
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
            icon: Icon(Icons.filter_list, color: Color(0xFF64748B)),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
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
                Icon(
                  Icons.assignment,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Tous', 'En attente', 'Soumis', 'Notés'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Statistiques
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
                Expanded(
                  child: _buildStatCard(
                    'En attente',
                    '${_assignments.where((a) => a['status'] == 'pending').length}',
                    Icons.pending_actions,
                    const Color(0xFFF59E0B),
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Soumis',
                    '${_assignments.where((a) => a['submitted']).length}',
                    Icons.upload_file,
                    const Color(0xFF2563EB),
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Notés',
                    '${_assignments.where((a) => a['grade'] != null).length}',
                    Icons.grade,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des devoirs
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredAssignments.length,
              itemBuilder: (context, index) {
                final assignment = _filteredAssignments[index];
                return _buildAssignmentCard(assignment);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredAssignments {
    switch (_selectedFilter) {
      case 'En attente':
        return _assignments.where((a) => a['status'] == 'pending').toList();
      case 'Soumis':
        return _assignments.where((a) => a['submitted']).toList();
      case 'Notés':
        return _assignments.where((a) => a['grade'] != null).toList();
      default:
        return _assignments;
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final status = assignment['status'];
    final priority = assignment['priority'];
    final isOverdue = _isOverdue(assignment['dueDate'], assignment['dueTime']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                      Row(
                        children: [
                          Text(
                            assignment['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(priority).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getPriorityText(priority),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getPriorityColor(priority),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${assignment['course']} • ${assignment['teacher']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        assignment['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(status),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(status),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(status),
                        ),
                        textAlign: TextAlign.center,
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    assignment['type'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isOverdue ? const Color(0xFFEF4444).withOpacity(0.1) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${assignment['dueDate']} à ${assignment['dueTime']}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                const Spacer(),
                if (assignment['attachments'].isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${assignment['attachments'].length} pièce(s)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (assignment['grade'] != null)
              Row(
                children: [
                  Text(
                    'Note obtenue : ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${assignment['grade']}/${assignment['maxGrade']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _getGradeColor(assignment['grade']),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewAssignmentDetails(assignment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Voir détails',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (status == 'pending')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _submitAssignment(assignment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Soumettre',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (status == 'graded')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _viewFeedback(assignment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Voir feedback',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'submitted':
        return const Color(0xFF2563EB);
      case 'graded':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'submitted':
        return Icons.upload_file;
      case 'graded':
        return Icons.grade;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'submitted':
        return 'Soumis';
      case 'graded':
        return 'Noté';
      default:
        return 'Inconnu';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'high':
        return 'Urgent';
      case 'medium':
        return 'Moyen';
      case 'low':
        return 'Faible';
      default:
        return 'Normal';
    }
  }

  Color _getGradeColor(double grade) {
    if (grade >= 16) return const Color(0xFF10B981);
    if (grade >= 14) return const Color(0xFF2563EB);
    if (grade >= 12) return const Color(0xFFF59E0B);
    if (grade >= 10) return const Color(0xFFFB923C);
    return const Color(0xFFEF4444);
  }

  bool _isOverdue(String dueDate, String dueTime) {
    // Simple check - in real app, parse dates properly
    return false;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filtrer les devoirs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Par priorité'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Par date d\'échéance'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Par cours'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
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

  void _viewAssignmentDetails(Map<String, dynamic> assignment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(assignment['title']),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cours: ${assignment['course']}'),
                Text('Professeur: ${assignment['teacher']}'),
                Text('Type: ${assignment['type']}'),
                Text('Date limite: ${assignment['dueDate']} à ${assignment['dueTime']}'),
                const SizedBox(height: 8),
                Text('Description:'),
                Text(assignment['description']),
                const SizedBox(height: 8),
                Text('Pièces jointes:'),
                ...(assignment['attachments'] as List<String>).map((file) => Text('• $file')),
              ],
            ),
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

  void _submitAssignment(Map<String, dynamic> assignment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Soumettre le devoir'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fonctionnalité de soumission à implémenter'),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Message optionnel...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
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
                    content: Text('Devoir soumis avec succès!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              child: Text('Soumettre'),
            ),
          ],
        );
      },
    );
  }

  void _viewFeedback(Map<String, dynamic> assignment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feedback du professeur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Note: ${assignment['grade']}/${assignment['maxGrade']}'),
              const SizedBox(height: 16),
              Text('Commentaires:'),
              Text('Excellent travail! L\'analyse est pertinente et la présentation est claire. Quelques petites améliorations possibles sur la conclusion.'),
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
}
