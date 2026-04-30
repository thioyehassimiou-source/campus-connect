import '../../shared/models/attendance_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AttendanceService {
  /// Récupérer l'historique de présence de l'étudiant via REST
  static Future<List<AttendanceRecord>> getStudentAttendance() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getStudentAttendance(token);

      if (response.success && response.data != null) {
        return response.data!.map((json) => AttendanceRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération présence étudiant: $e');
      return [];
    }
  }

  /// Récupérer les statistiques de présence de l'étudiant via REST
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
      attendanceRate: total > 0 ? (present + late) / total * 100 : 0,
    );
  }

  /// Récupérer les présences pour un cours et une date spécifique via REST
  static Future<List<AttendanceRecord>> getAttendanceForDate(String course, DateTime date) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final dateStr = date.toIso8601String().split('T')[0];
      final response = await ApiService.getAttendanceForDate(course, dateStr, token);

      if (response.success && response.data != null) {
        return response.data!.map((json) => AttendanceRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération présences par date: $e');
      return [];
    }
  }

  /// Récupérer les étudiants pour un cours (Enseignant) via REST
  static Future<List<Map<String, dynamic>>> getStudentsForCourse(String course) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getStudentsForCourse(course, token);

      if (response.success && response.data != null) {
        return response.data!.map((json) => {
          'id': json['id']?.toString() ?? '',
          'name': json['nom'] ?? json['full_name'] ?? 'Sans nom',
          'photo': json['avatar_url'],
          'group': json['group_name'] ?? 'Groupe A',
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération étudiants cours: $e');
      return [];
    }
  }

  /// Enregistrer ou mettre à jour les présences (Enseignant) via REST
  static Future<void> upsertAttendance({
    required String course,
    required Map<String, String> statuses, // studentId -> status
    required DateTime date,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non connecté');

      final dateStr = date.toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> data = [];

      statuses.forEach((studentId, status) {
        data.add({
          'student_id': studentId,
          'course': course,
          'status': status,
          'date': dateStr,
        });
      });

      final response = await ApiService.upsertAttendance(data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de l\'enregistrement des présences');
      }
    } catch (e) {
      print('❌ Erreur upsert présences: $e');
      rethrow;
    }
  }
}
