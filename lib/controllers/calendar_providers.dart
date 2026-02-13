import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/academic_calendar_service.dart';

/// Provider pour les événements du calendrier académique
final academicEventsProvider = FutureProvider<List<AcademicEvent>>((ref) async {
  return await AcademicCalendarService.getAcademicEvents();
});

/// StateNotifier pour gérer les actions sur le calendrier (Admin)
class CalendarController extends StateNotifier<AsyncValue<void>> {
  CalendarController() : super(const AsyncValue.data(null));

  Future<void> addEvent(Map<String, dynamic> eventData, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await AcademicCalendarService.addEvent(eventData);
      ref.invalidate(academicEventsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteEvent(String eventId, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await AcademicCalendarService.deleteEvent(eventId);
      ref.invalidate(academicEventsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final calendarControllerProvider = StateNotifierProvider<CalendarController, AsyncValue<void>>((ref) {
  return CalendarController();
});
