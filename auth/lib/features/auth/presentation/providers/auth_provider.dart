import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/profile_service.dart';
import '../../domain/models/app_user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoading;
  final AppUser? user;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    required this.isLoading,
    this.user,
    this.errorMessage,
    this.successMessage,
  });

  const AuthState.initial() : this(isLoading: false);

  AuthState copyWith({
    bool? isLoading,
    AppUser? user,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial()) {
    _hydrateFromSupabaseSession();
  }

  final _profileService = ProfileService(Supabase.instance.client);

  Future<void> _hydrateFromSupabaseSession() async {
    final supaUser = Supabase.instance.client.auth.currentUser;
    if (supaUser == null) return;

    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final profile = await _profileService.fetchOrCreateProfile(
        userId: supaUser.id,
        email: supaUser.email ?? '',
      );
      state = state.copyWith(isLoading: false, user: profile);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger le profil',
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final supaUser = response.user;
      if (supaUser == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Connexion échouée',
        );
        return;
      }

      final profile = await _profileService.fetchOrCreateProfile(
        userId: supaUser.id,
        email: supaUser.email ?? email,
      );

      state = state.copyWith(isLoading: false, user: profile);
    } catch (e) {
      String errorMessage = 'Erreur de connexion';

      if (e is AuthException) {
        switch (e.message) {
          case 'Invalid login credentials':
            errorMessage = 'Email ou mot de passe incorrect';
            break;
          case 'Email not confirmed':
            errorMessage = 'Veuillez confirmer votre email';
            break;
          case 'Too many requests':
            errorMessage = 'Trop de tentatives, réessayez plus tard';
            break;
          default:
            errorMessage = e.message;
        }
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final supaUser = response.user;
      if (supaUser == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erreur lors de l\'inscription',
        );
        return;
      }

      final role = UserRole.fromString(userData['role']?.toString());
      await _profileService.upsertProfile(
        userId: supaUser.id,
        email: email,
        role: role,
        firstName: userData['first_name']?.toString(),
        lastName: userData['last_name']?.toString(),
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Inscription réussie ! Vous pouvez vous connecter.',
      );
    } catch (e) {
      String errorMessage = 'Erreur d\'inscription';

      if (e is AuthException) {
        switch (e.message) {
          case 'User already registered':
            errorMessage = 'Cet email est déjà utilisé';
            break;
          case 'Password should be at least 6 characters':
            errorMessage = 'Le mot de passe doit contenir au moins 6 caractères';
            break;
          case 'Unable to validate email address: invalid format':
            errorMessage = 'Format d\'email invalide';
            break;
          default:
            errorMessage = e.message;
        }
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      state = const AuthState.initial();
    } catch (_) {
      state = state.copyWith(errorMessage: 'Erreur lors de la déconnexion');
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
