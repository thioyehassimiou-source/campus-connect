import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/features/admin/data/services/admin_service_v2.dart';

/// Priorité d'une annonce.
enum AnnouncementPriority { normale, urgente, info }

/// Cible d'une annonce.
enum AnnouncementTarget { global, etudiants, enseignants, filiere }

/// Modèle d'une annonce administrative.
class AdminAnnouncementModel {
  final String id;
  final String titre;
  final String contenu;
  final String authorId;
  final String? authorName;
  final AnnouncementPriority priority;
  final AnnouncementTarget target;
  final String? targetFiliere;
  final bool isDraft;
  final DateTime createdAt;
  final int? views;

  const AdminAnnouncementModel({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.authorId,
    this.authorName,
    this.priority = AnnouncementPriority.normale,
    this.target = AnnouncementTarget.global,
    this.targetFiliere,
    this.isDraft = false,
    required this.createdAt,
    this.views,
  });

  factory AdminAnnouncementModel.fromJson(Map<String, dynamic> j) {
    AnnouncementPriority prio = AnnouncementPriority.normale;
    switch ((j['priority'] ?? j['priorite'] ?? '').toString().toLowerCase()) {
      case 'urgente':
      case 'urgent':
        prio = AnnouncementPriority.urgente;
        break;
      case 'info':
        prio = AnnouncementPriority.info;
        break;
    }

    AnnouncementTarget tgt = AnnouncementTarget.global;
    switch ((j['target'] ?? j['cible'] ?? 'global').toString().toLowerCase()) {
      case 'etudiants':
      case 'etudiant':
      case 'students':
        tgt = AnnouncementTarget.etudiants;
        break;
      case 'enseignants':
      case 'teachers':
        tgt = AnnouncementTarget.enseignants;
        break;
      case 'filiere':
        tgt = AnnouncementTarget.filiere;
        break;
    }

    return AdminAnnouncementModel(
      id: j['id']?.toString() ?? '',
      titre: j['titre'] ?? j['title'] ?? '',
      contenu: j['contenu'] ?? j['content'] ?? j['description'] ?? '',
      authorId: j['author_id']?.toString() ?? j['created_by']?.toString() ?? '',
      authorName: j['author_name'] ?? j['profiles']?['full_name'],
      priority: prio,
      target: tgt,
      targetFiliere: j['target_filiere'] ?? j['filiere'],
      isDraft: j['is_draft'] ?? false,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at']) ?? DateTime.now()
          : DateTime.now(),
      views: j['views'],
    );
  }

  String get priorityLabel {
    switch (priority) {
      case AnnouncementPriority.urgente:
        return 'Urgente';
      case AnnouncementPriority.info:
        return 'Info';
      case AnnouncementPriority.normale:
        return 'Normale';
    }
  }

  String get targetLabel {
    switch (target) {
      case AnnouncementTarget.etudiants:
        return 'Étudiants';
      case AnnouncementTarget.enseignants:
        return 'Enseignants';
      case AnnouncementTarget.filiere:
        return targetFiliere != null ? 'Filière: $targetFiliere' : 'Filière';
      case AnnouncementTarget.global:
        return 'Tout le campus';
    }
  }
}

/// Service de gestion des annonces pour les administrateurs.
class AdminAnnouncementService {
  static final SupabaseClient _sb = Supabase.instance.client;

  static Future<List<AdminAnnouncementModel>> getAnnouncements({
    bool includeDrafts = true,
  }) async {
    try {
      var q = _sb
          .from('announcements')
          .select('*, profiles!announcements_author_id_fkey(full_name)')
          .order('created_at', ascending: false);

      if (!includeDrafts) {
        q = q.eq('is_draft', false);
      }

      final res = await q;
      return (res as List).map((j) => AdminAnnouncementModel.fromJson(j)).toList();
    } catch (e) {
      print('❌ AdminAnnouncementService.getAnnouncements: $e');
      // Fallback sans join
      try {
        final res = await _sb
            .from('announcements')
            .select()
            .order('created_at', ascending: false);
        return (res as List).map((j) => AdminAnnouncementModel.fromJson(j)).toList();
      } catch (_) {
        return [];
      }
    }
  }

  static Future<void> createAnnouncement({
    required String titre,
    required String contenu,
    AnnouncementPriority priority = AnnouncementPriority.normale,
    AnnouncementTarget target = AnnouncementTarget.global,
    String? targetFiliere,
    bool isDraft = false,
  }) async {
    final adminId = _sb.auth.currentUser?.id;
    if (adminId == null) throw Exception('Non authentifié');

    final targetStr = {
      AnnouncementTarget.global: 'global',
      AnnouncementTarget.etudiants: 'etudiants',
      AnnouncementTarget.enseignants: 'enseignants',
      AnnouncementTarget.filiere: 'filiere',
    }[target];

    final priorityStr = {
      AnnouncementPriority.normale: 'normale',
      AnnouncementPriority.urgente: 'urgente',
      AnnouncementPriority.info: 'info',
    }[priority];

    await _sb.from('announcements').insert({
      'titre': titre,
      'title': titre,
      'contenu': contenu,
      'content': contenu,
      'author_id': adminId,
      'created_by': adminId,
      'priority': priorityStr,
      'priorite': priorityStr,
      'target': targetStr,
      'cible': targetStr,
      'target_filiere': targetFiliere,
      'is_draft': isDraft,
      'created_at': DateTime.now().toIso8601String(),
    });

    await AdminServiceV2.logActivity(
      action: 'create_announcement',
      targetType: 'announcement',
      details: {'titre': titre, 'target': targetStr, 'isDraft': isDraft},
    );
  }

  static Future<void> publishDraft(String announcementId) async {
    await _sb
        .from('announcements')
        .update({'is_draft': false})
        .eq('id', announcementId);
  }

  static Future<void> deleteAnnouncement(String id) async {
    await _sb.from('announcements').delete().eq('id', id);
  }
}
