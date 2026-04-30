import 'package:campusconnect/features/admin/data/services/admin_service_v2.dart';
import 'package:campusconnect/services/api_service.dart';
import 'package:campusconnect/services/auth_service.dart';

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
      authorName: j['author_name'] ?? j['author']?['nom'] ?? 'Inconnu',
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

/// Service de gestion des annonces pour les administrateurs via REST.
class AdminAnnouncementService {
  static Future<List<AdminAnnouncementModel>> getAnnouncements({
    bool includeDrafts = true,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getAllAnnouncements(token, includeDrafts: includeDrafts);
      
      if (response.success && response.data != null) {
        return response.data!.map((j) => AdminAnnouncementModel.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      print('❌ AdminAnnouncementService.getAnnouncements: $e');
      return [];
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
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

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

      final data = {
        'titre': titre,
        'contenu': contenu,
        'priority': priorityStr,
        'target': targetStr,
        'target_filiere': targetFiliere,
        'is_draft': isDraft,
      };

      final response = await ApiService.createAnnouncement(data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la création de l\'annonce');
      }

      await AdminServiceV2.logActivity(
        action: 'create_announcement',
        targetType: 'announcement',
        details: {'titre': titre, 'target': targetStr, 'isDraft': isDraft},
      );
    } catch (e) {
      print('❌ Erreur création annonce: $e');
      rethrow;
    }
  }

  static Future<void> publishDraft(String announcementId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await ApiService.publishAnnouncement(announcementId, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la publication');
      }
    } catch (e) {
      print('❌ Erreur publication brouillon: $e');
      rethrow;
    }
  }

  static Future<void> deleteAnnouncement(String id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await ApiService.deleteAnnouncement(id, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      print('❌ Erreur suppression annonce: $e');
      rethrow;
    }
  }
}
