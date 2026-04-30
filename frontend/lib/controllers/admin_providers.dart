import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/admin_service.dart';
import '../core/services/room_service.dart';

/// Provider pour les statistiques globales
final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return await AdminService.getGlobalStats();
});

/// Provider pour la liste de tous les utilisateurs
final allUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await AdminService.getAllUsers();
});

/// Provider pour les statistiques des salles par bloc
final roomStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final rooms = await RoomService.getAllRooms();
  final Map<String, int> stats = {};
  
  for (final room in rooms) {
    // Si le bloc n'est pas spécifié ou vide, on le met dans "Autre"
    final bloc = (room.bloc.isEmpty) ? 'Autre' : room.bloc;
    stats[bloc] = (stats[bloc] ?? 0) + 1;
  }
  
  return stats;
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
