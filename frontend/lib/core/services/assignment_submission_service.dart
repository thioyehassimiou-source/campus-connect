import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String studentId;
  final String? fileUrl;
  final String? fileName;
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
    this.fileUrl,
    this.fileName,
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
      id: json['id']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      submittedAt: json['submitted_at'] != null ? DateTime.parse(json['submitted_at']) : DateTime.now(),
      status: json['status'] ?? 'submitted',
      score: json['grade'] != null ? double.tryParse(json['grade'].toString()) : null,
      feedback: json['feedback'],
      gradedAt: json['graded_at'] != null ? DateTime.parse(json['graded_at']) : null,
      gradedBy: json['graded_by']?.toString(),
      studentName: json['student']?['nom'] ?? json['student_name'],
    );
  }
}

class AssignmentSubmissionService {
  /// Soumettre un devoir via REST
  static Future<AssignmentSubmission> submitAssignment({
    required String assignmentId,
    String? fileUrl,
    String? fileName,
    String? content,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non connecté');

      final data = {
        'file_url': fileUrl,
        'file_name': fileName,
        'content': content,
      };

      final response = await ApiService.submitAssignment(assignmentId, data, token);

      if (response.success && response.data != null) {
        return AssignmentSubmission.fromJson(response.data!);
      } else {
        throw Exception(response.error?.message ?? 'Erreur lors de la soumission');
      }
    } catch (e) {
      print('❌ Erreur soumission: $e');
      rethrow;
    }
  }

  /// Récupérer les soumissions de l'étudiant connecté via REST
  static Future<List<AssignmentSubmission>> getMySubmissions() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non connecté');

      final response = await ApiService.getMySubmissions(token);

      if (response.success && response.data != null) {
        return response.data!.map((json) => AssignmentSubmission.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération mes soumissions: $e');
      return [];
    }
  }

  /// Récupérer une soumission spécifique via REST
  static Future<AssignmentSubmission?> getSubmissionForAssignment(String assignmentId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non connecté');

      final response = await ApiService.getSubmissionForAssignment(assignmentId, token);

      if (response.success && response.data != null) {
        return AssignmentSubmission.fromJson(response.data!);
      }
      return null;
    } catch (e) {
      print('❌ Erreur récupération soumission: $e');
      return null;
    }
  }

  /// Récupérer toutes les soumissions pour un devoir (enseignant) via REST
  static Future<List<AssignmentSubmission>> getSubmissionsForAssignment(String assignmentId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getAssignmentSubmissions(assignmentId, token);
      
      if (response.success && response.data != null) {
        return response.data!.map((json) => AssignmentSubmission.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération soumissions devoir: $e');
      return [];
    }
  }

  /// Noter une soumission (enseignant) via REST
  static Future<void> gradeSubmission({
    required String submissionId,
    required double score,
    String? feedback,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non connecté');

      final data = {
        'grade': score,
        'feedback': feedback,
      };

      final response = await ApiService.gradeSubmission(submissionId, data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la notation');
      }
    } catch (e) {
      print('❌ Erreur notation: $e');
      rethrow;
    }
  }

  /// Mettre à jour une soumission via REST
  static Future<void> updateSubmission({
    required String submissionId,
    required String fileUrl,
    required String fileName,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non connecté');

      final data = {
        'file_url': fileUrl,
        'file_name': fileName,
      };

      final response = await ApiService.submitAssignment(submissionId, data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      print('❌ Erreur mise à jour soumission: $e');
      rethrow;
    }
  }
}
