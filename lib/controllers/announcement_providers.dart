import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/announcement_service.dart';

/// Provider pour récupérer toutes les annonces
final allAnnouncementsProvider = FutureProvider<List<Announcement>>((ref) async {
  return await AnnouncementService.getAnnouncements();
});

/// StateNotifier pour gérer les annonces
class AnnouncementController extends StateNotifier<AsyncValue<void>> {
  AnnouncementController() : super(const AsyncValue.data(null));

  Future<void> createAnnouncement({
    required String title,
    required String content,
    required String category,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AnnouncementService.createAnnouncement(
        title: title,
        content: content,
        category: category,
      );
      ref.invalidate(allAnnouncementsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final announcementControllerProvider = StateNotifierProvider<AnnouncementController, AsyncValue<void>>((ref) {
  return AnnouncementController();
});
