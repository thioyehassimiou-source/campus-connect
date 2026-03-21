import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/features/admin/data/models/admin_user_model.dart';
import 'package:campusconnect/features/admin/data/services/admin_service_v2.dart';

// ─────────────────────────────────────────────
// État du filtre utilisateurs
// ─────────────────────────────────────────────

class AdminUsersFilter {
  final String search;
  final String? roleFilter;
  final int page;

  const AdminUsersFilter({
    this.search = '',
    this.roleFilter,
    this.page = 0,
  });

  AdminUsersFilter copyWith({
    String? search,
    String? roleFilter,
    bool clearRole = false,
    int? page,
  }) {
    return AdminUsersFilter(
      search: search ?? this.search,
      roleFilter: clearRole ? null : (roleFilter ?? this.roleFilter),
      page: page ?? this.page,
    );
  }
}

// ─────────────────────────────────────────────
// State Notifier — Gestion complète de la liste
// ─────────────────────────────────────────────

class AdminUsersNotifier extends StateNotifier<AsyncValue<List<AdminUserModel>>> {
  AdminUsersNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  AdminUsersFilter _filter = const AdminUsersFilter();
  AdminUsersFilter get currentFilter => _filter;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      _filter = _filter.copyWith(page: 0);
      state = const AsyncValue.loading();
      _hasMore = true;
    }
    try {
      final users = await AdminServiceV2.getUsersPaginated(
        page: _filter.page,
        limit: 20,
        search: _filter.search.isNotEmpty ? _filter.search : null,
        roleFilter: _filter.roleFilter,
      );

      _hasMore = users.length == 20;

      if (_filter.page == 0) {
        state = AsyncValue.data(users);
      } else {
        final current = state.value ?? [];
        state = AsyncValue.data([...current, ...users]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Applique un filtre de recherche (debounce géré côté UI).
  void applySearch(String query) {
    _filter = _filter.copyWith(search: query, page: 0);
    load(refresh: true);
  }

  /// Filtre par rôle. Passer null pour tout afficher.
  void applyRoleFilter(String? role) {
    _filter = AdminUsersFilter(
      search: _filter.search,
      roleFilter: role,
      page: 0,
    );
    load(refresh: true);
  }

  /// Charge la page suivante (pagination infinie).
  void loadNextPage() {
    if (!_hasMore) return;
    _filter = _filter.copyWith(page: _filter.page + 1);
    load();
  }

  // ── Actions CRUD ──────────────────────────────

  Future<void> toggleUserStatus(AdminUserModel user) async {
    await AdminServiceV2.toggleUserStatus(user.id, !user.isActive);
    // Mise à jour locale optimiste
    final updated = state.value?.map((u) {
      if (u.id == user.id) return u.copyWith(isActive: !user.isActive);
      return u;
    }).toList();
    if (updated != null) state = AsyncValue.data(updated);
  }

  Future<void> deleteUser(String userId) async {
    await AdminServiceV2.deleteUser(userId);
    final updated = state.value?.where((u) => u.id != userId).toList();
    if (updated != null) state = AsyncValue.data(updated);
  }

  Future<void> updateUser({
    required String userId,
    String? fullName,
    String? role,
    String? phone,
  }) async {
    await AdminServiceV2.updateUser(
      userId: userId,
      fullName: fullName,
      role: role,
      phone: phone,
    );
    load(refresh: true);
  }
}

// ─────────────────────────────────────────────
// Providers exportés
// ─────────────────────────────────────────────

final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier, AsyncValue<List<AdminUserModel>>>(
  (ref) => AdminUsersNotifier(),
);
