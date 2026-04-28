import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_auth_service.dart';

/// Provider pour l'état d'authentification (basé sur Supabase)
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Provider pour l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? Supabase.instance.client.auth.currentUser;
});

/// StateNotifier pour gérer les actions d'authentification
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncValue.data(null));

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await SupabaseAuthService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController();
});

// Pour la compatibilité avec mon code précédent (si j'ai utilisé une autre appellation par erreur)
final supabaseAuthProvider = authControllerProvider;
