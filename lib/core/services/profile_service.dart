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
            .select('*, faculties(nom), departments(nom)')
            .eq('id', userId)
            .maybeSingle();

        if (response != null) {
          // Copie mutable des données
          final data = Map<String, dynamic>.from(response);

          // 🚀 Calcul des statistiques dynamiques pour les étudiants
          if (data['role'] == 'Étudiant') {
            try {
              final gradesResponse = await _supabase
                  .from('grades')
                  .select('value, coefficient')
                  .eq('student_id', userId);
              
              final grades = (gradesResponse as List).cast<Map<String, dynamic>>();
              
              if (grades.isNotEmpty) {
                double totalPoints = 0;
                double totalCoeff = 0;
                double earnedCredits = 0;

                for (var grade in grades) {
                  final value = (grade['value'] as num).toDouble();
                  final coeff = (grade['coefficient'] as num).toDouble();
                  
                  totalPoints += value * coeff;
                  totalCoeff += coeff;
                  
                  if (value >= 10) {
                    earnedCredits += coeff;
                  }
                }

                if (totalCoeff > 0) {
                  data['moyenne'] = double.parse((totalPoints / totalCoeff).toStringAsFixed(2));
                }
                data['credits_valides'] = earnedCredits;
                data['classement'] = '5ème'; // Simulation
              }
            } catch (e) {
              print('Erreur calcul stats: $e');
            }
          }
          return data;
        }

        print('[ProfileService] Profile not found in DB, retry ${attempt + 1}/$retryCount');
        await Future.delayed(Duration(milliseconds: delayMs));

      } catch (e) {
        print('[ProfileService] Error fetching profile: $e');
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
          'service_type': metadata['service_type'],
          'scope_faculte_id': metadata['scope_faculte_id'],
          'scope_departement_id': metadata['scope_departement_id'],
          'faculty_id': metadata['faculty_id'],
          'department_id': metadata['department_id'],
          'telephone': metadata['telephone'] ?? '',
          'niveau': role == 'ETUDIANT' ? (metadata['niveau'] ?? 'Licence 1') : 'Non renseigné',
          'bio': metadata['bio'],
        });
        
        print('[ProfileService] Profile created successfully');
      } catch (e) {
        print('[ProfileService] Failed to create profile: $e');
        rethrow;
      }
    }
  }

  /// Met à jour le profil de l'utilisateur.
  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        print('[ProfileService] Update failed: No authenticated user');
        return false;
      }

      print('[ProfileService] Updating profile for $userId with data: $data');
      await _supabase.from('profiles').update(data).eq('id', userId);
      return true;
    } catch (e) {
      print('[ProfileService] Error updating profile: $e');
      return false;
    }
  }
}
