import 'package:campusconnect/services/api_service.dart';
import 'package:campusconnect/services/auth_service.dart';
import '../../shared/models/notification_model.dart';

class NotificationService {
  /// Récupérer les notifications de l'utilisateur actuel
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiService.getNotifications(token: token);
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération notifications REST: $e');
      return [];
    }
  }

  /// Marquer une notification comme lue
  static Future<void> markAsRead(String id) async {
    try {
      final token = await AuthService.getToken();
      await ApiService.markNotificationAsRead(id, token: token);
    } catch (e) {
      print('❌ Erreur markAsRead REST: $e');
    }
  }

  /// Tout marquer comme lu
  static Future<void> markAllAsRead() async {
    try {
      final token = await AuthService.getToken();
      await ApiService.markAllNotificationsAsRead(token: token);
    } catch (e) {
      print('❌ Erreur markAllAsRead REST: $e');
    }
  }

  /// Écouter les notifications en temps réel (Simulé via REST ou vide pour l'instant)
  static Stream<List<NotificationModel>> streamNotifications() {
    // Dans une version future, on utilisera des WebSockets
    // Pour l'instant on retourne un stream qui fetch une fois
    return Stream.fromFuture(getNotifications());
  }

  /// Supprimer une notification
  static Future<void> deleteNotification(String id) async {
    try {
      final token = await AuthService.getToken();
      await ApiService.deleteNotification(id, token: token);
    } catch (e) {
      print('❌ Erreur suppression notification REST: $e');
    }
  }
}
