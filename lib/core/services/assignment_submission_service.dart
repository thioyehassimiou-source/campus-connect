import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String studentId;
  final String fileUrl;
  final String fileName;
  final DateTime submittedAt;
  final String status; // submitted, graded, late
  final double? score;
  final String? feedback;
  final DateTime? gradedAt;
  final String? gradedBy;
  final String? studentName;

  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.fileUrl,
    required this.fileName,
    required this.submittedAt,
    required this.status,
    this.score,
    this.feedback,
    this.gradedAt,
    this.gradedBy,
    this.studentName,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      id: json['id'],
      assignmentId: json['assignment_id'],
      studentId: json['student_id'],
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      submittedAt: DateTime.parse(json['submitted_at']),
      status: json['status'],
      score: json['score']?.toDouble(),
      feedback: json['feedback'],
      gradedAt: json['graded_at'] != null ? DateTime.parse(json['graded_at']) : null,
      gradedBy: json['graded_by'],
      studentName: json['profiles']?['nom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'file_url': fileUrl,
      'file_name': fileName,
      'submitted_at': submittedAt.toIso8601String(),
      'status': status,
      'score': score,
      'feedback': feedback,
      'graded_at': gradedAt?.toIso8601String(),
      'graded_by': gradedBy,
    };
  }
}

class AssignmentSubmissionService {
  static final _supabase = Supabase.instance.client;

  /// Soumettre un devoir
  static Future<AssignmentSubmission> submitAssignment({
    required String assignmentId,
    required String fileUrl,
    required String fileName,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Utilisateur non connecté');

      final response = await _supabase
          .from('submissions')
          .insert({
            'assignment_id': assignmentId,
            'student_id': userId,
            'file_url': fileUrl,
            'file_name': fileName,
            'status': 'submitted',
          })
          .select()
          .single();

      return AssignmentSubmission.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la soumission: $e');
    }
  }

  /// Récupérer les soumissions de l'étudiant connecté
  static Future<List<AssignmentSubmission>> getMySubmissions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Utilisateur non connecté');

      final response = await _supabase
          .from('submissions')
          .select()
          .eq('student_id', userId)
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((json) => AssignmentSubmission.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération: $e');
    }
  }

  /// Récupérer une soumission spécifique
  static Future<AssignmentSubmission?> getSubmissionForAssignment(String assignmentId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Utilisateur non connecté');

      final response = await _supabase
          .from('submissions')
          .select()
          .eq('assignment_id', assignmentId)
          .eq('student_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return AssignmentSubmission.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération: $e');
    }
  }

  /// Récupérer toutes les soumissions pour un devoir (enseignant)
  static Future<List<AssignmentSubmission>> getSubmissionsForAssignment(String assignmentId) async {
    try {
      final response = await _supabase
          .from('submissions')
          .select('*, profiles(nom)')
          .eq('assignment_id', assignmentId)
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((json) {
            final submission = AssignmentSubmission.fromJson(json);
            // On peut ajouter le nom si on veut, mais pour l'instant on garde le modèle simple
            // On pourrait modifier le modèle pour inclure studentName
            return submission;
          })
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération: $e');
    }
  }

  /// Noter une soumission (enseignant)
  static Future<void> gradeSubmission({
    required String submissionId,
    required double score,
    String? feedback,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Utilisateur non connecté');

      await _supabase
          .from('submissions')
          .update({
            'grade': score,
            'feedback': feedback,
            'status': 'graded',
          })
          .eq('id', submissionId);
    } catch (e) {
      throw Exception('Erreur lors de la notation: $e');
    }
  }

  /// Mettre à jour le fichier d'une soumission
  static Future<void> updateSubmission({
    required String submissionId,
    required String fileUrl,
    required String fileName,
  }) async {
    try {
      await _supabase
          .from('submissions')
          .update({
            'file_url': fileUrl,
            'file_name': fileName,
            'submitted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', submissionId);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  /// Supprimer une soumission
  static Future<void> deleteSubmission(String submissionId) async {
    try {
      await _supabase
          .from('submissions')
          .delete()
          .eq('id', submissionId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
}
