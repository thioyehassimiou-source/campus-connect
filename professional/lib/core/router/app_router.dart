import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    
    // Redirections basées sur l'état d'authentification
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );
      
      // Routes protégées
      final protectedRoutes = ['/', '/profile'];
      final authRoutes = ['/login', '/register'];
      
      if (protectedRoutes.contains(state.location.name) && !isAuthenticated) {
        return '/login';
      }
      
      if (authRoutes.contains(state.location.name) && isAuthenticated) {
        return '/';
      }
      
      if (state.location.name == 'splash' && isAuthenticated) {
        return '/';
      }
      
      return null;
    },
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Erreur: ${state.error}'),
      ),
    ),
  );
});

// Provider pour l'état d'authentification (sera implémenté dans auth_provider.dart)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial());
  
  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  Future<void> signUp(String email, String password, Map<String, dynamic> userData) async {
    state = const AuthState.loading();
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = const AuthState.initial();
  }
  
  void checkAuthStatus() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      state = AuthState.authenticated(user);
    }
  }
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.error(String message) = _Error;
}
