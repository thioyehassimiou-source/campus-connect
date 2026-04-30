import 'package:campusconnect/services/api_service.dart';
import 'package:campusconnect/services/auth_service.dart';

/// Modèle d'une filière académique.
class FiliereModel {
  final String id;
  final String nom;
  final String? niveau;
  final int? capacite;
  final String? departementId;

  const FiliereModel({
    required this.id,
    required this.nom,
    this.niveau,
    this.capacite,
    this.departementId,
  });

  factory FiliereModel.fromJson(Map<String, dynamic> j) => FiliereModel(
        id: j['id']?.toString() ?? '',
        nom: j['nom'] ?? j['name'] ?? '',
        niveau: j['niveau'] ?? j['level'],
        capacite: j['capacite'] ?? j['capacity'],
        departementId: j['departement_id']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'niveau': niveau,
        'capacite': capacite,
        'departement_id': departementId,
      };
}

/// Modèle d'un cours.
class CourseAdminModel {
  final String id;
  final String nom;
  final String? code;
  final String? teacherId;
  final String? teacherName;
  final String? filiereId;
  final String? filiereName;
  final int? heuresParSemaine;

  const CourseAdminModel({
    required this.id,
    required this.nom,
    this.code,
    this.teacherId,
    this.teacherName,
    this.filiereId,
    this.filiereName,
    this.heuresParSemaine,
  });

  factory CourseAdminModel.fromJson(Map<String, dynamic> j) => CourseAdminModel(
        id: j['id']?.toString() ?? '',
        nom: j['nom'] ?? j['name'] ?? j['title'] ?? '',
        code: j['code'] ?? j['course_code'],
        teacherId: j['teacher_id']?.toString() ?? j['enseignant_id']?.toString(),
        teacherName: j['teacher_name'] ?? j['enseignant'],
        filiereId: j['filiere_id']?.toString(),
        filiereName: j['filiere_name'],
        heuresParSemaine: j['heures_par_semaine'] ?? j['credits'],
      );

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'code': code,
        'teacher_id': teacherId,
        'filiere_id': filiereId,
        'heures_par_semaine': heuresParSemaine,
      };
}

/// Service de gestion académique pour les administrateurs via REST
class AdminAcademicService {
  // ─────────────────────────────────────────────
  // FILIÈRES
  // ─────────────────────────────────────────────

  static Future<List<FiliereModel>> getFilieres() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getAllFilieres(token);
      if (response.success && response.data != null) {
        return response.data!.map((j) => FiliereModel.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      print('❌ AdminAcademicService.getFilieres: $e');
      return [];
    }
  }

  static Future<void> createFiliere(FiliereModel filiere) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await ApiService.createFiliere(filiere.toJson(), token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la création de la filière');
      }
    } catch (e) {
      print('❌ Erreur création filière: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // COURS
  // ─────────────────────────────────────────────

  static Future<List<CourseAdminModel>> getCourses() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getAllCourses(token);
      if (response.success && response.data != null) {
        return response.data!.map((j) => CourseAdminModel.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      print('❌ AdminAcademicService.getCourses: $e');
      return [];
    }
  }

  static Future<void> createCourse(CourseAdminModel course) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await ApiService.createCourse(course.toJson(), token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la création du cours');
      }
    } catch (e) {
      print('❌ Erreur création cours: $e');
      rethrow;
    }
  }

  /// Récupère la liste des enseignants via REST
  static Future<List<Map<String, String>>> getTeachersList() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getTeachersList(token);
      if (response.success && response.data != null) {
        return response.data!.map((j) => {
          'id': j['id'].toString(), 
          'name': (j['nom'] ?? j['full_name'] ?? 'Inconnu').toString()
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ AdminAcademicService.getTeachersList: $e');
      return [];
    }
  }

  static Future<void> deleteFiliere(String id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await ApiService.deleteFiliere(id, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      print('❌ Erreur suppression filière: $e');
      rethrow;
    }
  }

  static Future<void> assignTeacherToCourse(String courseId, String teacherId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await ApiService.updateCourse(courseId, {'teacher_id': teacherId}, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de l\'assignation');
      }
    } catch (e) {
      print('❌ Erreur assignation enseignant: $e');
      rethrow;
    }
  }
}
