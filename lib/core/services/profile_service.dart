import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/core/services/supabase_service.dart';

class ProfileService {
  static final SupabaseClient _supabase = SupabaseService.database;

  /// Récupère le profil de l'utilisateur actuellement connecté.
  static Future<Map<String, dynamic>?> getCurrentUserProfile({int retryCount = 3}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      print('No authenticated user found');
      return null;
    }

    // Essayer différents noms de tables
    final tableNames = ['profiles', 'users', 'user_profiles'];
    
    for (final tableName in tableNames) {
      for (int attempt = 0; attempt < retryCount; attempt++) {
        try {
          final response = await _supabase
              .from(tableName)
              .select('*, faculties(nom), departments(nom), services(nom)')
              .eq('id', userId)
              .single();
          
          print('Profile loaded successfully from table: $tableName');
          return response;
        } catch (e) {
          print('Error fetching from $tableName (attempt ${attempt + 1}/$retryCount): $e');
          
          if (attempt == retryCount - 1) {
            // Dernière tentative pour cette table échouée
            break;
          }
          
          // Attendre avant de réessayer
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }
    
    print('Failed to load profile from all tables: $tableNames');
    return null;
  }

  /// S'assure qu'un profil existe pour l'utilisateur connecté.
  /// Si le profil est manquant (ex: échec lors de l'inscription à cause du RLS),
  /// on en crée un par défaut à partir des métadonnées de l'utilisateur.
  static Future<void> ensureProfileExists() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await getCurrentUserProfile(retryCount: 1);
    if (profile == null) {
      print('Profile manquant pour ${user.id}, création par défaut...');
      try {
        final metadata = user.userMetadata ?? {};
        final fullName = metadata['nom'] ?? 'Utilisateur';
        final role = metadata['role'] ?? 'Étudiant';
        final niveau = role == 'Étudiant' ? (metadata['niveau'] ?? 'Licence 1') : 'Non renseigné';
        
        await _supabase.from('profiles').insert({
          'id': user.id,
          'nom': fullName,
          'email': user.email,
          'role': role,
          'faculty_id': metadata['faculty_id'],
          'department_id': metadata['department_id'],
          'service_id': metadata['service_id'],
          'telephone': metadata['telephone'] ?? '',
          'niveau': niveau,
          'filiere_id': metadata['filiere_id'] ?? 'Non renseignée',
          'created_at': DateTime.now().toIso8601String(),
        });
        print('Profil créé automatiquement avec succès (Rôle: $role, Niveau: $niveau).');
      } catch (e) {
        print('Échec de la création automatique du profil : $e');
      }
    }
  }

  /// Met à jour le profil de l'utilisateur (optionnel pour l'instant).
  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('profiles').update(data).eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}
