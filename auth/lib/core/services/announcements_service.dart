import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/announcements/domain/models/announcement.dart';
import '../../features/auth/domain/models/app_user.dart';

class AnnouncementsService {
  final SupabaseClient _client;

  AnnouncementsService(this._client);

  bool canCreate(UserRole role) {
    return role == UserRole.enseignant || role == UserRole.admin;
  }

  List<String> _targetsForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return ['tous', 'etudiants', 'enseignants'];
      case UserRole.enseignant:
        return ['tous', 'enseignants'];
      case UserRole.etudiant:
        return ['tous', 'etudiants'];
    }
  }

  Future<List<Announcement>> fetchForRole(UserRole role) async {
    final targets = _targetsForRole(role);

    final rows = await _client
        .from('annonces')
        .select('*')
        .in_('target', targets)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((e) => Announcement.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<Announcement> create({
    required AppUser author,
    required String title,
    required String content,
    required AnnouncementTarget target,
  }) async {
    if (!canCreate(author.role)) {
      throw Exception('Accès refusé');
    }

    final row = await _client
        .from('annonces')
        .insert({
          'title': title,
          'content': content,
          'target': target.value,
          'author_id': author.id,
        })
        .select()
        .single();

    return Announcement.fromMap(row);
  }
}
