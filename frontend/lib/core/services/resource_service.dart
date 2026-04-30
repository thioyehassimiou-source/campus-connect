import 'package:campusconnect/services/api_service.dart';
import 'package:campusconnect/services/auth_service.dart';
import 'package:campusconnect/models/resource_model.dart';

export 'package:campusconnect/models/resource_model.dart';

class ResourceService {
  /// Récupérer les ressources (optionnel: filtrer par matière)
  static Future<List<Resource>> getResources({String? subject}) async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiService.getResources(subject: subject, token: token);
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération ressources REST: $e');
      return [];
    }
  }

  /// Téléverser un fichier vers le backend
  static Future<String> uploadResourceFile(String fileName, List<int> bytes) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final response = await ApiService.uploadFileFromBytes(fileName, bytes, token);
      
      if (response.success && response.data != null) {
        // Le backend retourne l'URL relative, on ajoute la base URL si nécessaire
        // Mais ApiConfig.baseUrl contient déjà le domaine
        return response.data!['url'];
      }
      throw Exception(response.error?.message ?? 'Échec de l\'upload');
    } catch (e) {
      print('❌ Erreur uploadResourceFile REST: $e');
      rethrow;
    }
  }

  /// Ajouter une ressource
  static Future<void> addResource({
    required String title,
    required String description,
    required String url,
    required String type,
    required String subject,
    String scope = 'license',
    String? departmentId,
    String? facultyId,
    String? niveau,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final data = {
        'title': title,
        'description': description,
        'url': url,
        'type': type,
        'subject': subject,
        'scope': scope,
        'departmentId': departmentId,
        'facultyId': facultyId,
        'niveau': niveau,
      };

      final response = await ApiService.createResource(data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de l\'ajout de la ressource');
      }
    } catch (e) {
      print('❌ Erreur ajout ressource REST: $e');
      rethrow;
    }
  }
}
