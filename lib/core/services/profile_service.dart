import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/core/services/supabase_service.dart';

class ProfileService {
  static final SupabaseClient _supabase = SupabaseService.database;

  /// Récupère le profil de l'utilisateur actuellement connecté.
  /// Utilise maybeSingle() pour éviter les crashes et retry avec backoff exponentiel.
  static Future<Map<String, dynamic>?> getCurrentUserProfile({
    int retryCount = 5,
    int delayMs = 800,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      print('[ProfileService] No authenticated user');
      return null;
    }

    for (int attempt = 0; attempt < retryCount; attempt++) {
      try {
        final response = await _supabase
            .from('profiles')
            .select('*, faculties(nom), departments(nom), services(nom)')
            .eq('id', userId)
            .maybeSingle(); // ✅ Ne crash pas si vide

        if (response != null) {
          print('[ProfileService] Profile loaded (attempt ${attempt + 1})');
          return response;
        }

        print('[ProfileService] Profile not found, retry ${attempt + 1}/$retryCount');
        
        // Attendre avant retry (backoff exponentiel)
        if (attempt < retryCount - 1) {
          await Future.delayed(Duration(milliseconds: delayMs * (attempt + 1)));
        }
      } catch (e) {
        print('[ProfileService] Error attempt ${attempt + 1}: $e');
        
        if (attempt == retryCount - 1) {
          return null;
        }
        
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

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
      print('[ProfileService] Creating missing profile for ${user.id}');
      try {
        final metadata = user.userMetadata ?? {};
        final role = metadata['role'] ?? 'Étudiant';
        
        await _supabase.from('profiles').insert({
          'id': user.id,
          'nom': metadata['nom'] ?? 'Utilisateur',
          'email': user.email,
          'role': role,
          'faculty_id': metadata['faculty_id'],
          'department_id': metadata['department_id'],
          'service_id': metadata['service_id'],
          'telephone': metadata['telephone'] ?? '',
          'niveau': role == 'Étudiant' ? (metadata['niveau'] ?? 'Licence 1') : 'Non renseigné',
          'filiere_id': metadata['filiere_id'], // ✅ null si non renseignée
        });
        
        print('[ProfileService] Profile created successfully');
      } catch (e) {
        print('[ProfileService] Failed to create profile: $e');
        rethrow;
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
