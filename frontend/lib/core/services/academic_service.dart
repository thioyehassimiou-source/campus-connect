import 'package:campusconnect/services/api_service.dart';
import 'package:campusconnect/services/auth_service.dart';
import 'package:campusconnect/models/course_model.dart';

export 'package:campusconnect/models/course_model.dart';

class AcademicService {
  /// Récupérer les cours de l'enseignant connecté
  static Future<List<Course>> getTeacherCourses() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiService.getCourses(token: token);
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('❌ Erreur AcademicService REST: $e');
      return [];
    }
  }

  /// Créer un cours
  static Future<void> createCourse({
    required String title,
    required String level,
    required String color,
    String? description,
    String scope = 'license',
    String? departmentId,
    String? facultyId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final data = {
        'title': title,
        'level': level,
        'color': color,
        'description': description,
        'scope': scope,
        'departmentId': departmentId,
        'facultyId': facultyId,
      };

      final response = await ApiService.createCourse(data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la création du cours');
      }
    } catch (e) {
      print('❌ Erreur création cours REST: $e');
      rethrow;
    }
  }

  /// Mettre à jour un cours
  static Future<void> updateCourse({
    required String id,
    required String title,
    required String level,
    required String color,
    String? description,
    String? status,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final data = {
        'title': title,
        'level': level,
        'color': color,
        'description': description,
        'status': status,
      };

      final response = await ApiService.updateCourse(id, data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la mise à jour du cours');
      }
    } catch (e) {
      print('❌ Erreur mise à jour cours REST: $e');
      rethrow;
    }
  }

  /// Supprimer un cours
  static Future<void> deleteCourse(String id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final response = await ApiService.deleteCourse(id, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la suppression du cours');
      }
    } catch (e) {
      print('❌ Erreur suppression cours REST: $e');
      rethrow;
    }
  }
}
