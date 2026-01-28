import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/core/services/supabase_service.dart';

class SupabaseAuthService {
  static final SupabaseClient _supabase = SupabaseService.database;

  // Register with email and password
  static Future<AuthResponse> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? filiereId,
    String? niveau,
    String? departementId,
    String? telephone,
  }) async {
    try {
      print('Starting registration for email: $email');
      
      // Create user with email and password
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
        },
      );

      if (response.user != null) {
        // Create user profile in database
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'nom': '$firstName $lastName',
          'email': email,
          'role': role,
          'filiere_id': filiereId,
          'niveau': niveau,
          'departement_id': departementId,
          'telephone': telephone,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      print('User registered successfully: ${response.user?.id}');
      return response;
    } on AuthException catch (e) {
      print('Auth Exception: ${e.message}');
      throw _getErrorMessage(e.message);
    } catch (e) {
      print('General Exception during registration: $e');
      throw 'Une erreur est survenue lors de l\'inscription: ${e.toString()}';
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting sign in for email: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      print('Sign in successful: ${response.user?.id}');
      return response;
    } on AuthException catch (e) {
      print('Auth Exception during sign in: ${e.message}');
      throw _getErrorMessage(e.message);
    } catch (e) {
      print('General Exception during sign in: $e');
      throw 'Une erreur est survenue lors de la connexion: ${e.toString()}';
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw 'Une erreur est survenue lors de la déconnexion';
    }
  }

  // Get current user data from database
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', userId)
            .single();
        return response;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get user-friendly error message
  static String _getErrorMessage(String? message) {
    if (message == null) return 'Une erreur est survenue';
    
    if (message.contains('Weak password')) {
      return 'Le mot de passe est trop faible';
    } else if (message.contains('User already registered')) {
      return 'Cet email est déjà utilisé';
    } else if (message.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    } else if (message.contains('Email not confirmed')) {
      return 'Veuillez confirmer votre email';
    } else if (message.contains('Invalid email')) {
      return 'Email invalide';
    } else if (message.contains('User disabled')) {
      return 'Ce compte a été désactivé';
    } else if (message.contains('Too many requests')) {
      return 'Trop de tentatives. Veuillez réessayer plus tard';
    } else {
      return 'Une erreur est survenue: $message';
    }
  }
}
