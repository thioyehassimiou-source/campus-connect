import '../../shared/models/assignment_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AssignmentService {
  /// Récupérer les devoirs (pour un étudiant) via REST
  static Future<List<Assignment>> getStudentAssignments() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getStudentAssignments(token);

      if (response.success && response.data != null) {
        return response.data!.map((json) => Assignment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération devoirs étudiant: $e');
      return [];
    }
  }

  /// Récupérer les devoirs (pour un enseignant) via REST
  static Future<List<Assignment>> getTeacherAssignments() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getTeacherAssignments(token);

      if (response.success && response.data != null) {
        return response.data!.map((json) => Assignment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération devoirs prof: $e');
      return [];
    }
  }

  /// Créer un devoir (Enseignant) via REST
  static Future<void> createAssignment({
    required String title,
    required String description,
    required DateTime dueDate,
    required String course,
    String priority = 'medium',
    String type = 'Devoir',
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non connecté');

      final data = {
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'course': course,
        'priority': priority,
        'type': type,
      };

      final response = await ApiService.createAssignment(data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la création du devoir');
      }
    } catch (e) {
      print('❌ Erreur création devoir: $e');
      rethrow;
    }
  }

  /// Soumettre un devoir (Étudiant) via REST
  static Future<void> submitAssignment({
    required String assignmentId,
    required String content,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non connecté');

      final data = {
        'content': content,
      };

      final response = await ApiService.submitAssignment(assignmentId, data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la soumission');
      }
    } catch (e) {
      print('❌ Erreur soumission devoir: $e');
      rethrow;
    }
  }

  /// Récupérer les soumissions pour un devoir spécifique (Enseignant) via REST
  static Future<List<Map<String, dynamic>>> getAssignmentSubmissions(String assignmentId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getAssignmentSubmissions(assignmentId, token);
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération soumissions: $e');
      return [];
    }
  }
}
