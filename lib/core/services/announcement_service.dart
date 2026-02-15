import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/core/services/profile_service.dart';

class Announcement {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final DateTime createdAt;
  final String category;
  final String priority;
  final bool isPinned;
  final String? scope;
  final String? departmentId;
  final String? niveau;
  final String? facultyId;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
    required this.category,
    required this.priority,
    required this.isPinned,
    this.scope,
    this.departmentId,
    this.niveau,
    this.facultyId,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'].toString(),
      title: json['title'],
      content: json['content'],
      authorName: json['author'] ?? json['author_name'] ?? 'Administration',
      createdAt: DateTime.parse(json['created_at']),
      category: json['category'] ?? 'Toutes',
      priority: json['priority'] ?? 'Moyenne',
      isPinned: json['is_pinned'] ?? false,
      scope: json['scope'],
      departmentId: json['department_id']?.toString(),
      niveau: json['niveau'],
      facultyId: json['faculty_id']?.toString(),
    );
  }

  // Pour l'affichage "Il y a X temps"
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}

class AnnouncementService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupérer toutes les annonces (épinglées en premier, puis par date)
  static Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await _supabase
          .from('announcements')
          .select()
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Announcement.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur récupération annonces: $e');
      return [];
    }
  }

  /// Créer une nouvelle annonce (Prof/Admin uniquement)
  static Future<void> createAnnouncement({
    required String title,
    required String content,
    required String category,
    String priority = 'Moyenne',
    String scope = 'university',
    String? departmentId,
    String? niveau,
    String? facultyId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Récupérer le nom de l'auteur et son service depuis le profil
      String authorName = 'Enseignant';
      String? serviceId;
      try {
        final profile = await ProfileService.getCurrentUserProfile();
        if (profile != null) {
          if (profile['nom'] != null) {
            authorName = profile['nom'];
          }
          // Récupération automatique du service_id
          if (profile['service_id'] != null) {
            serviceId = profile['service_id'];
          }
        }
      } catch (e) {
        print('Erreur récupération profil auteur: $e');
      }
      
      await _supabase.from('announcements').insert({
        'title': title,
        'content': content,
        'author': authorName,
        'category': category,
        'priority': priority,
        'user_id': user.id,
        'scope': scope,
        'department_id': departmentId,
        'niveau': niveau,
        'faculty_id': facultyId,
        'service_id': serviceId,
      });

      // 🔔 Notification automatique aux utilisateurs concernés
      _notifyTargetUsers(
        title: title,
        content: content,
        scope: scope,
        facultyId: facultyId,
        departmentId: departmentId,
        niveau: niveau,
        excludeUserId: user.id, 
      );

    } catch (e) {
      print('❌ Erreur création annonce: $e');
      rethrow;
    }
  }

  /// Envoie une notification aux utilisateurs ciblés par l'annonce
  static Future<void> _notifyTargetUsers({
    required String title,
    required String content,
    required String scope,
    String? facultyId,
    String? departmentId,
    String? niveau,
    required String excludeUserId,
  }) async {
    try {
      var query = _supabase.from('profiles').select('id');

      // Filtrage selon la portée
      if (scope == 'faculty' && facultyId != null) {
        query = query.eq('faculty_id', facultyId);
      } else if (scope == 'department' && departmentId != null) {
        query = query.eq('department_id', departmentId);
      }
      
      // Filtrage par niveau si spécifié
      if (niveau != null && niveau.isNotEmpty && niveau != 'Tous') {
        query = query.eq('niveau', niveau);
      }

      final response = await query;
      final List<dynamic> users = response as List<dynamic>;

      if (users.isEmpty) return;

      final notifications = users
          .where((u) => u['id'] != excludeUserId)
          .map((u) => {
                'user_id': u['id'],
                'title': '📢 $title',
                'content': content.length > 60 ? '${content.substring(0, 60)}...' : content,
                'type': 'announcement',
                'is_read': false,
                'created_at': DateTime.now().toIso8601String(),
              })
          .toList();

      if (notifications.isNotEmpty) {
        // Insertion par lot (batch)
        await _supabase.from('notifications').insert(notifications);
        print('✅ ${notifications.length} notifications envoyées.');
      }
    } catch (e) {
      print('⚠️ Erreur lors de l\'envoi des notifications: $e');
      // On ne rethrow pas pour ne pas bloquer la création de l'annonce
    }
  }

  /// Basculer le statut épinglé d'une annonce
  static Future<void> togglePin(String announcementId, bool currentStatus) async {
    try {
      await _supabase
          .from('announcements')
          .update({'is_pinned': !currentStatus})
          .eq('id', announcementId);
    } catch (e) {
      print('❌ Erreur toggle pin: $e');
      rethrow;
    }
  }

  /// Supprimer une annonce
  static Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _supabase
          .from('announcements')
          .delete()
          .eq('id', announcementId);
    } catch (e) {
      print('❌ Erreur suppression annonce: $e');
      rethrow;
    }
  }
}
