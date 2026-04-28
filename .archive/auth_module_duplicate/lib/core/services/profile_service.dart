import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/domain/models/app_user.dart';

class ProfileService {
  final SupabaseClient _client;

  ProfileService(this._client);

  Future<AppUser> fetchProfile({required String userId}) async {
    final data = await _client
        .from('users')
        .select('id,email,first_name,last_name,role')
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      throw Exception('Profil utilisateur introuvable');
    }

    return AppUser.fromMap(data);
  }

  Future<AppUser> fetchOrCreateProfile({
    required String userId,
    required String email,
    UserRole? role,
    String? firstName,
    String? lastName,
  }) async {
    final existing = await _client
        .from('users')
        .select('id,email,first_name,last_name,role')
        .eq('id', userId)
        .maybeSingle();

    if (existing != null) {
      return AppUser.fromMap(existing);
    }

    final inserted = await _client
        .from('users')
        .insert({
          'id': userId,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'role': (role ?? UserRole.etudiant).value,
        })
        .select('id,email,first_name,last_name,role')
        .single();

    return AppUser.fromMap(inserted);
  }

  Future<AppUser> upsertProfile({
    required String userId,
    required String email,
    required UserRole role,
    String? firstName,
    String? lastName,
  }) async {
    final data = await _client
        .from('users')
        .upsert({
          'id': userId,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'role': role.value,
        })
        .select('id,email,first_name,last_name,role')
        .single();

    return AppUser.fromMap(data);
  }
}
