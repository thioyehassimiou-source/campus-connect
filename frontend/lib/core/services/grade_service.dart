import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class Grade {
  final String id;
  final String subject;
  final double value;
  final double coefficient;
  final String type; // CC, Examen, etc.
  final String semester;
  final DateTime date;

  Grade({
    required this.id,
    required this.subject,
    required this.value,
    required this.coefficient,
    required this.type,
    required this.semester,
    required this.date,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] ?? json['course_name'] ?? 'Inconnu',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      coefficient: (json['coefficient'] as num?)?.toDouble() ?? 1.0,
      type: json['type'] ?? 'CC',
      semester: json['semester'] ?? 'S1',
      date: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}

class GradeService {
  /// Récupérer les notes de l'étudiant connecté via REST
  static Future<List<Grade>> getMyGrades() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getMyGrades(token);

      if (response.success && response.data != null) {
        return response.data!.map((json) => Grade.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération notes: $e');
      return [];
    }
  }

  /// Récupérer les notes données par l'enseignant connecté via REST
  static Future<List<Grade>> getTeacherGrades() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getTeacherGrades(token);

      if (response.success && response.data != null) {
        return response.data!.map((json) => Grade.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération notes prof: $e');
      return [];
    }
  }

  /// Ajouter une note (Prof seulement) via REST
  static Future<void> addGrade({
    required String studentId,
    required String subject,
    required double value,
    required double coefficient,
    required String type,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final data = {
        'student_id': studentId,
        'subject': subject,
        'value': value,
        'coefficient': coefficient,
        'type': type,
      };

      final response = await ApiService.addGrade(data, token);
      
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de l\'ajout de la note');
      }
    } catch (e) {
      print('❌ Erreur ajout note: $e');
      rethrow;
    }
  }
}
