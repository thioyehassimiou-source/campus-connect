import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/features/admin/data/services/admin_service_v2.dart';

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

/// Service de gestion académique pour les administrateurs.
class AdminAcademicService {
  static final SupabaseClient _sb = Supabase.instance.client;

  // ─────────────────────────────────────────────
  // FILIÈRES
  // ─────────────────────────────────────────────

  static Future<List<FiliereModel>> getFilieres() async {
    try {
      final res = await _sb.from('filieres').select().order('nom');
      return (res as List).map((j) => FiliereModel.fromJson(j)).toList();
    } catch (e) {
      print('❌ AdminAcademicService.getFilieres: $e');
      return [];
    }
  }

  static Future<void> createFiliere(FiliereModel filiere) async {
    await _sb.from('filieres').insert(filiere.toJson());
    await AdminServiceV2.logActivity(
      action: 'create_filiere',
      targetType: 'filiere',
      details: {'nom': filiere.nom},
    );
  }

  static Future<void> updateFiliere(String id, Map<String, dynamic> data) async {
    await _sb.from('filieres').update(data).eq('id', id);
  }

  static Future<void> deleteFiliere(String id) async {
    await _sb.from('filieres').delete().eq('id', id);
  }

  // ─────────────────────────────────────────────
  // COURS
  // ─────────────────────────────────────────────

  static Future<List<CourseAdminModel>> getCourses() async {
    try {
      final res = await _sb
          .from('courses')
          .select('*, profiles!courses_teacher_id_fkey(full_name)')
          .order('nom');
      return (res as List).map((j) {
        final teacherName = j['profiles'] != null
            ? j['profiles']['full_name']
            : j['teacher'];
        return CourseAdminModel.fromJson({...j, 'teacher_name': teacherName});
      }).toList();
    } catch (e) {
      print('❌ AdminAcademicService.getCourses: $e');
      // Fallback sans join
      try {
        final res = await _sb.from('courses').select().order('nom');
        return (res as List).map((j) => CourseAdminModel.fromJson(j)).toList();
      } catch (_) {
        return [];
      }
    }
  }

  static Future<void> createCourse(CourseAdminModel course) async {
    await _sb.from('courses').insert(course.toJson());
    await AdminServiceV2.logActivity(
      action: 'create_course',
      targetType: 'course',
      details: {'nom': course.nom},
    );
  }

  static Future<void> assignTeacherToCourse(String courseId, String teacherId) async {
    await _sb.from('courses').update({'teacher_id': teacherId}).eq('id', courseId);
    await AdminServiceV2.logActivity(
      action: 'assign_teacher',
      targetType: 'course',
      targetId: courseId,
      details: {'teacher_id': teacherId},
    );
  }

  static Future<void> deleteCourse(String courseId) async {
    await _sb.from('courses').delete().eq('id', courseId);
  }

  // ─────────────────────────────────────────────
  // INSCRIPTIONS ÉTUDIANTS
  // ─────────────────────────────────────────────

  /// Inscrit un étudiant à une filière (met à jour son profil).
  static Future<void> enrollStudentToFiliere(String studentId, String filiereName) async {
    await _sb.from('profiles').update({
      'filiere': filiereName,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', studentId);
    await AdminServiceV2.logActivity(
      action: 'enroll_student',
      targetType: 'user',
      targetId: studentId,
      details: {'filiere': filiereName},
    );
  }

  /// Récupère la liste des enseignants (pour le dropdown assignation).
  static Future<List<Map<String, String>>> getTeachersList() async {
    try {
      final res = await _sb
          .from('profiles')
          .select('id, full_name')
          .eq('role', 'Enseignant')
          .order('full_name');
      return (res as List)
          .map((j) => {'id': j['id'].toString(), 'name': j['full_name'].toString()})
          .toList();
    } catch (e) {
      print('❌ AdminAcademicService.getTeachersList: $e');
      return [];
    }
  }
}
