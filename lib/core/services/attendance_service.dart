import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/attendance_model.dart';

class AttendanceService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupérer l'historique de présence de l'étudiant
  static Future<List<AttendanceRecord>> getStudentAttendance() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('attendance')
          .select('*, profiles(full_name, avatar_url)')
          .eq('student_id', user.id)
          .order('date', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => AttendanceRecord.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur récupération présence étudiant: $e');
      return [];
    }
  }

  /// Récupérer les statistiques de présence de l'étudiant
  static Future<AttendanceStats> getStudentStats() async {
    final records = await getStudentAttendance();
    if (records.isEmpty) {
      return AttendanceStats(
        totalClasses: 0,
        presentClasses: 0,
        absentClasses: 0,
        lateClasses: 0,
        attendanceRate: 0,
      );
    }

    final present = records.where((r) => r.status == 'present').length;
    final late = records.where((r) => r.status == 'late').length;
    final absent = records.where((r) => r.status == 'absent').length;
    final total = records.length;

    return AttendanceStats(
      totalClasses: total,
      presentClasses: present,
      absentClasses: absent,
      lateClasses: late,
      attendanceRate: (present + late) / total * 100,
    );
  }

  /// Récupérer les présences pour un cours et une date spécifique
  static Future<List<AttendanceRecord>> getAttendanceForDate(String course, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

      final response = await _supabase
          .from('attendance')
          .select('*, profiles(full_name, avatar_url)')
          .eq('course', course)
          .gte('date', startOfDay)
          .lte('date', endOfDay);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => AttendanceRecord.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur récupération présences par date: $e');
      return [];
    }
  }

  /// Récupérer les étudiants pour un cours (Enseignant)
  static Future<List<Map<String, dynamic>>> getStudentsForCourse(String course) async {
    try {
      // Pour la démo, on récupère tous les étudiants. 
      // En prod, on filtrerait par inscription au cours/filière.
      final response = await _supabase
          .from('profiles')
          .select('id, nom, avatar_url')
          .eq('role', 'Étudiant')
          .order('nom');

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => {
        'id': json['id'],
        'name': json['nom'] ?? 'Sans nom',
        'photo': json['avatar_url'],
        'group': 'Groupe A',
      }).toList();
    } catch (e) {
      print('❌ Erreur récupération étudiants cours: $e');
      return [];
    }
  }

  /// Enregistrer ou mettre à jour les présences (Enseignant)
  static Future<void> upsertAttendance({
    required String course,
    required Map<String, String> statuses, // studentId -> status
    required DateTime date,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Non connecté');

      // On s'assure que la date est à midi pour éviter les problèmes de fuseau horaire 
      // si on compare avec date::date en SQL
      final attendanceDate = DateTime(date.year, date.month, date.day, 12, 0, 0);
      
      final List<Map<String, dynamic>> inserts = [];

      statuses.forEach((studentId, status) {
        inserts.add({
          'student_id': studentId,
          'teacher_id': user.id,
          'course': course,
          'status': status,
          'date': attendanceDate.toIso8601String(),
        });
      });

      // Upsert basé sur la contrainte d'unicité (étudiant, cours, jour)
      // Note: on utilise upsert avec onConflict si nécessaire
      await _supabase.from('attendance').upsert(
        inserts,
        onConflict: 'student_id, course, date', // Nécessite que 'date' soit exactement la même ou contrainte nommée
      );
    } catch (e) {
      print('❌ Erreur upsert présences: $e');
      rethrow;
    }
  }
}
