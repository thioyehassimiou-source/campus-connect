import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/notification_model.dart';

class NotificationService {
  static final _supabase = Supabase.instance.client;

  /// Récupérer les notifications de l'utilisateur actuel
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('notifications')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Erreur récupération notifications: $e');
      return [];
    }
  }

  /// Marquer une notification comme lue
  static Future<void> markAsRead(String id) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      print('❌ Erreur markAsRead: $e');
    }
  }

  /// Tout marquer comme lu
  static Future<void> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (e) {
      print('❌ Erreur markAllAsRead: $e');
    }
  }

  /// Écouter les notifications en temps réel
  static Stream<List<NotificationModel>> streamNotifications() {
    final user = _supabase.auth.currentUser;
    if (user == null) return Stream.value([]);

    // Note: stream() en Supabase Flutter nécessite que la table ait Realtime activé
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => NotificationModel.fromJson(json)).toList());
  }

  /// Supprimer une notification
  static Future<void> deleteNotification(String id) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('❌ Erreur suppression notification: $e');
    }
  }
}
