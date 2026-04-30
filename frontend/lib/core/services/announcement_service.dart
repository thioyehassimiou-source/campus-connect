import 'package:campusconnect/services/api_service.dart';
import 'package:campusconnect/services/auth_service.dart';
import 'package:campusconnect/models/announcement_model.dart';

export 'package:campusconnect/models/announcement_model.dart';

class AnnouncementService {
  /// Récupérer toutes les annonces
  static Future<List<Announcement>> getAnnouncements() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiService.getAnnouncements(token: token);
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération annonces REST: $e');
      return [];
    }
  }

  /// Créer une nouvelle annonce
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
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final data = {
        'title': title,
        'content': content,
        'category': category,
        'priority': priority,
        'scope': scope,
        'departmentId': departmentId,
        'facultyId': facultyId,
        'niveau': niveau,
      };

      final response = await ApiService.createAnnouncement(data, token);
      
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la création de l\'annonce');
      }
    } catch (e) {
      print('❌ Erreur création annonce REST: $e');
      rethrow;
    }
  }

  /// Supprimer une annonce
  static Future<void> deleteAnnouncement(String announcementId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final response = await ApiService.deleteAnnouncement(announcementId, token);
      
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la suppression de l\'annonce');
      }
    } catch (e) {
      print('❌ Erreur suppression annonce REST: $e');
      rethrow;
    }
  }

  /// Basculer le statut épinglé
  static Future<void> togglePin(String announcementId, bool currentStatus) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      // TODO: Implémenter ApiService.patchAnnouncement si nécessaire
      // Pour l'instant, on peut utiliser un update générique si dispo
      print('Toggling pin status via API: $announcementId to ${!currentStatus}');
    } catch (e) {
      print('❌ Erreur toggle pin REST: $e');
      rethrow;
    }
  }
}
