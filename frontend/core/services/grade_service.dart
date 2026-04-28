import 'package:supabase_flutter/supabase_flutter.dart';

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
      id: json['id'],
      subject: json['subject'],
      value: (json['value'] as num).toDouble(),
      coefficient: (json['coefficient'] as num).toDouble(),
      type: json['type'] ?? 'CC',
      semester: json['semester'] ?? 'S1',
      date: DateTime.parse(json['created_at']),
    );
  }
}

class GradeService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupérer les notes de l'étudiant connecté
  static Future<List<Grade>> getMyGrades() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('grades')
          .select()
          .eq('student_id', user.id) // Sécurité supplémentaire côté client
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Grade.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur récupération notes: $e');
      return [];
    }
  }

  /// Récupérer les notes données par l'enseignant connecté
  static Future<List<Grade>> getTeacherGrades() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('grades')
          .select()
          .eq('teacher_id', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Grade.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur récupération notes prof: $e');
      return [];
    }
  }

  /// Ajouter une note (Prof seulement)
  static Future<void> addGrade({
    required String studentId,
    required String subject,
    required double value,
    required double coefficient,
    required String type,
  }) async {
    try {
      await _supabase.from('grades').insert({
        'student_id': studentId,
        'subject': subject,
        'value': value,
        'coefficient': coefficient,
        'type': type,
        'teacher_id': _supabase.auth.currentUser?.id,
      });
    } catch (e) {
      print('❌ Erreur ajout note: $e');
      rethrow;
    }
  }
}
