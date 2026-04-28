import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/assignment_model.dart';

class AssignmentService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupérer les devoirs (pour un étudiant)
  static Future<List<Assignment>> getStudentAssignments() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      // Fetch assignments joined with submission status for current student
      final response = await _supabase
          .from('assignments')
          .select('*, submissions(status, grade, feedback)')
          .order('due_date', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) {
        // Soumissions de l'étudiant actuel
        final List submissions = json['submissions'] as List;
        final submission = submissions.isEmpty ? null : submissions[0];
        
        return Assignment.fromJson({
          ...json,
          'submitted': submission != null,
          'grade': submission?['grade'],
          'status': submission?['status'] ?? 'pending',
          'feedback': submission?['feedback'],
        });
      }).toList();
    } catch (e) {
      print('❌ Erreur récupération devoirs étudiant: $e');
      return [];
    }
  }

  /// Récupérer les devoirs (pour un enseignant)
  static Future<List<Assignment>> getTeacherAssignments() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('assignments')
          .select('*')
          .eq('teacher_id', user.id)
          .order('due_date', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Assignment.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur récupération devoirs prof: $e');
      return [];
    }
  }

  /// Créer un devoir (Enseignant)
  static Future<void> createAssignment({
    required String title,
    required String description,
    required DateTime dueDate,
    required String course,
    String priority = 'medium',
    String type = 'Devoir',
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Non connecté');

      // Récupérer le nom du prof depuis son profil
      final profileRes = await _supabase
          .from('profiles')
          .select('nom')
          .eq('id', user.id)
          .single();
      
      final String teacherName = profileRes['nom'] ?? 'Professeur';

      await _supabase.from('assignments').insert({
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'course': course,
        'priority': priority,
        'type': type,
        'teacher_id': user.id,
        'teacher_name': teacherName,
      });
    } catch (e) {
      print('❌ Erreur création devoir: $e');
      rethrow;
    }
  }

  /// Soumettre un devoir (Étudiant)
  static Future<void> submitAssignment({
    required String assignmentId,
    required String content,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Non connecté');

      await _supabase.from('submissions').upsert({
        'assignment_id': assignmentId,
        'student_id': user.id,
        'content': content,
        'status': 'submitted',
        'submitted_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Erreur soumission devoir: $e');
      rethrow;
    }
  }

  /// Récupérer les soumissions pour un devoir spécifique (Enseignant)
  static Future<List<Map<String, dynamic>>> getAssignmentSubmissions(String assignmentId) async {
    try {
      final response = await _supabase
          .from('submissions')
          .select('*, profiles(nom)')
          .eq('assignment_id', assignmentId)
          .order('submitted_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Erreur récupération soumissions: $e');
      return [];
    }
  }
}
