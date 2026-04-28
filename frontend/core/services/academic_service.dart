import 'package:supabase_flutter/supabase_flutter.dart';

class Course {
  final String id;
  final String title;
  final String level;
  final int studentsCount;
  final String status;
  final String color;
  final String? scope;
  final String? departmentId;
  final String? facultyId;

  Course({
    required this.id,
    required this.title,
    required this.level,
    required this.studentsCount,
    required this.status,
    required this.color,
    this.scope,
    this.departmentId,
    this.facultyId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? json['subject'] ?? 'Cours sans titre',
      level: json['level'] ?? 'L1',
      studentsCount: json['students_count'] ?? 0,
      status: json['status'] ?? 'Actif',
      color: json['color'] ?? '#2563EB',
      scope: json['scope'],
      departmentId: json['department_id']?.toString(),
      facultyId: json['faculty_id']?.toString(),
    );
  }
}

class AcademicService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupérer les cours de l'enseignant connecté
  static Future<List<Course>> getTeacherCourses() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('courses')
          .select()
          .eq('teacher_id', user.id)
          .order('created_at', ascending: false);
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur AcademicService Fetch: $e');
      // On retourne une liste vide au lieu de simuler, 
      // car on a maintenant une table dédiée.
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
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Non connecté');

    try {
      await _supabase.from('courses').insert({
        'title': title,
        'level': level,
        'color': color,
        'description': description,
        'teacher_id': user.id,
        'status': 'Actif',
        'scope': scope,
        'department_id': departmentId,
        'niveau': level,
        'faculty_id': facultyId,
      });
    } catch (e) {
      print('❌ Erreur création cours: $e');
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
      await _supabase.from('courses').update({
        'title': title,
        'level': level,
        'color': color,
        'description': description,
        'status': status ?? 'Actif',
      }).eq('id', id);
    } catch (e) {
      print('❌ Erreur mise à jour cours: $e');
      rethrow;
    }
  }

  /// Supprimer un cours
  static Future<void> deleteCourse(String id) async {
    try {
      await _supabase.from('courses').delete().eq('id', id);
    } catch (e) {
      print('❌ Erreur suppression cours: $e');
      rethrow;
    }
  }
}
