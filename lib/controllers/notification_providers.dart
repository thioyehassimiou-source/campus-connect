import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/notification_service.dart';
import '../shared/models/notification_model.dart';

/// Provider pour le flux de notifications en temps réel
final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  return NotificationService.streamNotifications();
});

/// Provider pour calculer le nombre de notifications non lues
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

/// Controller pour les actions sur les notifications
class NotificationController extends StateNotifier<AsyncValue<void>> {
  NotificationController() : super(const AsyncValue.data(null));

  Future<void> markAsRead(String id) async {
    state = const AsyncValue.loading();
    try {
      await NotificationService.markAsRead(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();
    try {
      await NotificationService.markAllAsRead();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteNotification(String id) async {
    state = const AsyncValue.loading();
    try {
      await NotificationService.deleteNotification(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final notificationControllerProvider = StateNotifierProvider<NotificationController, AsyncValue<void>>((ref) {
  return NotificationController();
});
