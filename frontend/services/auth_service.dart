import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Récupérer le token d'accès valide
  Future<String?> getValidAccessToken() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final accessToken = session?.accessToken;
      
      if (accessToken == null) {
        // Rafraîchir la session si nécessaire
        final refreshedSession = await Supabase.instance.client.auth.refreshSession();
        return refreshedSession.session?.accessToken;
      }
      
      return accessToken;
    } catch (e) {
      print('❌ Erreur récupération token: $e');
      return null;
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null;
  }

  // Obtenir l'utilisateur courant
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      return user?.toJson();
    } catch (e) {
      print('❌ Erreur récupération utilisateur: $e');
      return null;
    }
  }
}
