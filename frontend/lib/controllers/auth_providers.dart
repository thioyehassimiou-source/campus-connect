import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

/// Provider pour l'utilisateur actuel (récupéré depuis le stockage local/API)
final authStateProvider = StateNotifierProvider<AuthStateNotifier, UserModel?>((ref) {
  return AuthStateNotifier();
});

class AuthStateNotifier extends StateNotifier<UserModel?> {
  AuthStateNotifier() : super(null) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final user = await AuthService.getStoredUser();
    state = user;
  }

  void setUser(UserModel? user) {
    state = user;
  }

  Future<void> signOut() async {
    await AuthService.logout();
    state = null;
  }
}

/// Provider pour savoir si on est connecté
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider) != null;
});

/// Provider pour l'ID de l'utilisateur actuel
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider)?.id;
});
