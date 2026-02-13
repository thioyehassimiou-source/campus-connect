import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/resource_service.dart';
import 'auth_providers.dart';

/// Provider pour récupérer la liste des ressources
final allResourcesProvider = FutureProvider<List<Resource>>((ref) async {
  return await ResourceService.getResources();
});

/// Provider pour les ressources d'un enseignant spécifique
final teacherResourcesProvider = FutureProvider<List<Resource>>((ref) async {
  final all = await ref.watch(allResourcesProvider.future);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return all.where((r) => r.authorId == user.id).toList();
});

/// StateNotifier pour gérer les actions sur les ressources
class ResourceController extends StateNotifier<AsyncValue<void>> {
  ResourceController() : super(const AsyncValue.data(null));

  Future<void> addResource({
    required String title,
    required String description,
    required String url,
    required String type,
    required String subject,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ResourceService.addResource(
        title: title,
        description: description,
        url: url,
        type: type,
        subject: subject,
      );
      ref.invalidate(allResourcesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final resourceControllerProvider = StateNotifierProvider<ResourceController, AsyncValue<void>>((ref) {
  return ResourceController();
});
