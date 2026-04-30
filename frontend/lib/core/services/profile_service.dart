import 'package:campusconnect/services/auth_service.dart';
import 'package:campusconnect/models/user_model.dart';

class ProfileService {
  /// Récupère le profil de l'utilisateur actuellement connecté.
  /// Désormais, c'est le Backend qui fournit toutes les infos (moyenne, crédits, etc.)
  static Future<Map<String, dynamic>?> getCurrentUserProfile({
    int retryCount = 1,
    int delayMs = 0,
  }) async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) return null;

      // On transforme le UserModel en Map pour garder la compatibilité avec les widgets existants
      return user.toJson();
    } catch (e) {
      print('[ProfileService] Error fetching profile: $e');
      return null;
    }
  }

  /// S'assure qu'un profil existe pour l'utilisateur connecté.
  /// Sur notre nouveau backend, le profil est créé automatiquement à l'inscription.
  static Future<void> ensureProfileExists() async {
    // Rien à faire ici, le backend gère l'intégrité
    return;
  }

  /// Met à jour le profil de l'utilisateur.
  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    // TODO: Implémenter la route PUT /users/:id dans le backend
    print('[ProfileService] Update profile via REST API (pending backend route)');
    return true; 
  }
}
