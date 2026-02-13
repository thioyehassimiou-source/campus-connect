import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/admin_service.dart';

/// Provider pour les statistiques globales
final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return await AdminService.getGlobalStats();
});

/// Provider pour la liste de tous les utilisateurs
final allUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await AdminService.getAllUsers();
});

/// StateNotifier pour les actions d'administration
class AdminController extends StateNotifier<AsyncValue<void>> {
  AdminController() : super(const AsyncValue.data(null));

  Future<void> deleteUser(String userId, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await AdminService.deleteUser(userId);
      ref.invalidate(allUsersProvider);
      ref.invalidate(adminStatsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AdminService.createUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );
      ref.invalidate(allUsersProvider);
      ref.invalidate(adminStatsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminControllerProvider = StateNotifierProvider<AdminController, AsyncValue<void>>((ref) {
  return AdminController();
});
