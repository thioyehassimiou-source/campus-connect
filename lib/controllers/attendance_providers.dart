import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/attendance_service.dart';
import '../shared/models/attendance_model.dart';

/// Provider pour l'historique de présence de l'étudiant
final studentAttendanceProvider = FutureProvider<List<AttendanceRecord>>((ref) async {
  return await AttendanceService.getStudentAttendance();
});

/// Provider pour les stats de présence de l'étudiant
final studentAttendanceStatsProvider = FutureProvider<AttendanceStats>((ref) async {
  return await AttendanceService.getStudentStats();
});

/// Provider pour calculer le taux de présence global
final studentAttendanceRateProvider = FutureProvider<double>((ref) async {
  final stats = await ref.watch(studentAttendanceStatsProvider.future);
  return stats.attendanceRate; // Renvoie directement le taux de présence (0.0 à 100.0)
});

/// Provider pour les étudiants d'un cours (Enseignant)
final studentsForCourseProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, course) async {
  return await AttendanceService.getStudentsForCourse(course);
});

/// Provider pour les présences déjà enregistrées (Enseignant)
final attendanceByDateProvider = FutureProvider.family<List<AttendanceRecord>, ({String course, DateTime date})>((ref, arg) async {
  return await AttendanceService.getAttendanceForDate(arg.course, arg.date);
});

/// StateNotifier pour gérer les présences
class AttendanceController extends StateNotifier<AsyncValue<void>> {
  AttendanceController() : super(const AsyncValue.data(null));

  Future<void> saveAttendance({
    required String course,
    required Map<String, String> statuses,
    required DateTime date,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AttendanceService.upsertAttendance(
        course: course, 
        statuses: statuses,
        date: date,
      );
      // Invalider les providers pour forcer le rafraîchissement
      ref.invalidate(studentAttendanceProvider);
      ref.invalidate(studentAttendanceStatsProvider);
      ref.invalidate(attendanceByDateProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final attendanceControllerProvider = StateNotifierProvider<AttendanceController, AsyncValue<void>>((ref) {
  return AttendanceController();
});
