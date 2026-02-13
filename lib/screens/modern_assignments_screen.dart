import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/shared/models/assignment_model.dart';
import 'package:campusconnect/controllers/assignment_providers.dart';
import 'package:campusconnect/controllers/assignment_submission_providers.dart';
import 'package:campusconnect/core/services/assignment_service.dart';
import 'package:campusconnect/core/services/supabase_storage_service.dart';
import 'package:campusconnect/core/services/assignment_submission_service.dart';
import 'package:campusconnect/core/services/download_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ModernAssignmentsScreen extends ConsumerStatefulWidget {
  final bool isTeacher;
  const ModernAssignmentsScreen({super.key, this.isTeacher = false});

  @override
  ConsumerState<ModernAssignmentsScreen> createState() => _ModernAssignmentsScreenState();
}

class _ModernAssignmentsScreenState extends ConsumerState<ModernAssignmentsScreen> {
  String _selectedFilter = 'Tous';
  // List<Map<String, dynamic>> _assignments = [] is removed, using Riverpod

  @override
  void initState() {
    super.initState();
    // Géré par Riverpod
  }

  void _refreshAssignments() {
    ref.invalidate(widget.isTeacher ? teacherAssignmentsProvider : studentAssignmentsProvider);
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
            const Text(
              'Suivi des travaux',
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
            onPressed: _refreshAssignments,
          ),
          if (widget.isTeacher)
            IconButton(
              icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
              onPressed: _showCreateAssignmentDialog,
            ),
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
          
          // Liste des devoirs
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final assignmentsAsync = ref.watch(widget.isTeacher ? teacherAssignmentsProvider : studentAssignmentsProvider);
                
                return assignmentsAsync.when(
                  data: (data) {
                    var assignments = _filterAssignments(data);
                    
                    if (assignments.isEmpty) {
                      return const Center(child: Text('Aucun devoir trouvé.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        return _buildAssignmentCard(assignments[index]);
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

  List<Assignment> _filterAssignments(List<Assignment> assignments) {
    switch (_selectedFilter) {
      case 'En attente':
        return assignments.where((a) => a.status == 'pending').toList();
      case 'Soumis':
        return assignments.where((a) => a.submitted).toList();
      case 'Notés':
        return assignments.where((a) => a.grade != null).toList();
      default:
        return assignments;
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

  Widget _buildAssignmentCard(Assignment assignment) {
    final status = assignment.status;
    final priority = assignment.priority;
    final isOverdue = assignment.dueDate.isBefore(DateTime.now()) && !assignment.submitted;
    
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
                          Expanded(
                            child: Text(
                              assignment.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
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
                        '${assignment.course} • ${assignment.teacher}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        assignment.description,
                        style: const TextStyle(
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
                const SizedBox(width: 12),
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
                    assignment.type,
                    style: const TextStyle(
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
                    DateFormat('dd/MM à HH:mm').format(assignment.dueDate),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                const Spacer(),
                if (assignment.attachments.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${assignment.attachments.length} pièce(s)',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (assignment.grade != null)
              Row(
                children: [
                  const Text(
                    'Note obtenue : ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${assignment.grade}/${assignment.maxGrade}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _getGradeColor(assignment.grade!),
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
                    child: const Text(
                      'Voir détails',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // For teachers: View submissions
                if (widget.isTeacher)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showSubmissionsDialog(assignment),
                      icon: const Icon(Icons.people_outline, size: 16),
                      label: const Text('Voir soumissions', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  )
                else if (status == 'pending') // Only show submit button if pending
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
                      child: const Text(
                        'Soumettre',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else if (status == 'submitted') // Show 'Soumis' text if already submitted
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Soumis',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (status == 'graded')
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
                      child: const Text(
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

  void _showSubmissionsDialog(Assignment assignment) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Soumissions - ${assignment.title}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer(
            builder: (context, ref, child) {
              final submissionsAsync = ref.watch(assignmentSubmissionsProvider(assignment.id));
              
              return submissionsAsync.when(
                data: (submissions) {
                  if (submissions.isEmpty) {
                    return const Center(child: Text('Aucune soumission pour le moment.'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final sub = submissions[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE2E8F0),
                          child: Icon(Icons.person, color: Color(0xFF64748B)),
                        ),
                        title: Text(sub.studentName ?? 'Étudiant ${sub.studentId.substring(0, 8)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fichier: ${sub.fileName}'),
                            Text(
                              'Statut: ${sub.status == "graded" ? "Noté" : "À corriger"}',
                              style: TextStyle(
                                color: sub.status == "graded" ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download, color: Color(0xFF2563EB)),
                              onPressed: () {
                                // Utiliser le DownloadService pour télécharger
                                DownloadService.downloadFile(
                                  sub.fileUrl,
                                  sub.fileName,
                                  context,
                                );
                              },
                            ),
                            ElevatedButton(
                              onPressed: () => _gradeSubmission(sub, assignment),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: sub.status == "graded" ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: Text(sub.status == "graded" ? '${sub.score}/${assignment.maxGrade}' : 'Noter'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Erreur: $e')),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _gradeSubmission(AssignmentSubmission submission, Assignment assignment) {
    double score = submission.score ?? 0;
    String feedback = submission.feedback ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Noter le travail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Étudiant: ${submission.studentId.substring(0, 8)}'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Note / ${assignment.maxGrade}',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => score = double.tryParse(v) ?? 0,
              controller: TextEditingController(text: score.toString()),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Feedback / Commentaire',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (v) => feedback = v,
              controller: TextEditingController(text: feedback),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(submissionControllerProvider.notifier).gradeSubmission(
                  submissionId: submission.id,
                  assignmentId: assignment.id,
                  score: score,
                  feedback: feedback,
                  ref: ref,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note enregistrée !'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
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

  // Removed _isOverdue as it's replaced by DateTime logic

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

  void _viewAssignmentDetails(Assignment assignment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(assignment.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cours: ${assignment.course}'),
                Text('Professeur: ${assignment.teacher}'),
                Text('Type: ${assignment.type}'),
                Text('Date limite: ${DateFormat('dd/MM à HH:mm').format(assignment.dueDate)}'),
                const SizedBox(height: 8),
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(assignment.description),
                const SizedBox(height: 8),
                Text('Pièces jointes: ${assignment.attachments.isEmpty ? "Aucune" : ""}'),
                ...assignment.attachments.map((file) => Text('• $file')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _submitAssignment(Assignment assignment) async {
    File? selectedFile;
    String fileName = '';
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Soumettre le devoir'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sélectionnez votre fichier (PDF, Word, etc.) :',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: isUploading ? null : () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg', 'jpeg'],
                    );

                    if (result != null) {
                      setStateDialog(() {
                        selectedFile = File(result.files.single.path!);
                        fileName = result.files.single.name;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFF8FAFC),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedFile != null ? Icons.insert_drive_file : Icons.cloud_upload_outlined,
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedFile != null ? fileName : 'Cliquez pour choisir un fichier',
                            style: TextStyle(
                              fontSize: 13,
                              color: selectedFile != null ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isUploading) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Chargement en cours...',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: (selectedFile == null || isUploading) ? null : () async {
                  setStateDialog(() => isUploading = true);
                  try {
                    final userId = Supabase.instance.client.auth.currentUser?.id;
                    if (userId == null) throw Exception('Non connecté');

                    // 1. Upload vers Storage
                    final path = '$userId/${assignment.id}_${DateTime.now().millisecondsSinceEpoch}_$fileName';
                    final publicUrl = await SupabaseStorageService.uploadFile(
                      file: selectedFile!,
                      path: path,
                    );

                    // 2. Enregistrer la soumission
                    await ref.read(submissionControllerProvider.notifier).submitAssignment(
                      assignmentId: assignment.id,
                      fileUrl: publicUrl,
                      fileName: fileName,
                      ref: ref,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Devoir soumis avec succès !'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                      // Rafraîchir les devoirs
                      ref.invalidate(studentAssignmentsProvider);
                    }
                  } catch (e) {
                    setStateDialog(() => isUploading = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Soumettre'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _viewFeedback(Assignment assignment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Feedback du professeur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Note: ${assignment.grade}/${assignment.maxGrade}'),
              const SizedBox(height: 16),
              const Text('Commentaires:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Excellent travail! L\'analyse est pertinente et la présentation est claire.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateAssignmentDialog() {
    String title = '';
    String description = '';
    String course = '';
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un devoir'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Titre'),
                onChanged: (v) => title = v,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Matière'),
                onChanged: (v) => course = v,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onChanged: (v) => description = v,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Date limite'),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(dueDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(dueDate),
                    );
                    if (time != null) {
                      setState(() {
                         dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      });
                    }
                  }
                },
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
              if (title.isNotEmpty && course.isNotEmpty) {
                try {
                  await ref.read(assignmentControllerProvider.notifier).createAssignment(
                    title: title,
                    description: description,
                    dueDate: dueDate,
                    course: course,
                    ref: ref,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Devoir créé avec succès!')),
                  );
                } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
