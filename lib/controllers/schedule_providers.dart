import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/schedule_service.dart';

/// Provider pour récupérer l'emploi du temps validé (pour étudiants)
final validatedScheduleProvider = FutureProvider<List<ScheduleItem>>((ref) async {
  return await ScheduleService.getValidatedSchedule();
});

/// Provider pour récupérer les propositions d'un enseignant
final teacherProposalsProvider = FutureProvider<List<ScheduleItem>>((ref) async {
  return await ScheduleService.getTeacherProposals();
});

/// Provider pour récupérer les propositions en attente (pour admin)
final pendingSchedulesProvider = FutureProvider<List<ScheduleItem>>((ref) async {
  return await ScheduleService.getPendingSchedules();
});

/// StateNotifier pour gérer les actions sur l'emploi du temps
class ScheduleController extends StateNotifier<AsyncValue<void>> {
  ScheduleController() : super(const AsyncValue.data(null));

  Future<void> addSchedule({
    required String subject,
    required String teacher,
    required DateTime startTime,
    required DateTime endTime,
    required String room,
    required int day,
    String? niveau,
    String scope = 'license',
    int? departmentId,
    String? facultyId,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ScheduleService.proposeSchedule(
        subject: subject,
        teacher: teacher,
        startTime: startTime,
        endTime: endTime,
        room: room,
        day: day,
        niveau: niveau,
        scope: scope,
        departmentId: departmentId,
        facultyId: facultyId,
      );
      ref.invalidate(teacherProposalsProvider);
      ref.invalidate(validatedScheduleProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancelSchedule(String id, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await ScheduleService.cancelSchedule(id);
      ref.invalidate(pendingSchedulesProvider);
      ref.invalidate(validatedScheduleProvider);
      ref.invalidate(teacherProposalsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final scheduleControllerProvider = StateNotifierProvider<ScheduleController, AsyncValue<void>>((ref) {
  return ScheduleController();
});
