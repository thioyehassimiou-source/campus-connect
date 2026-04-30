import 'package:campusconnect/services/api_service.dart';
import '../../models/institutional_service.dart';

class CampusService {
  /// Récupérer tous les blocs du campus
  static Future<List<Map<String, dynamic>>> getCampusBlocs() async {
    try {
      final response = await ApiService.getCampusBlocs();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des blocs REST: $e');
      return [];
    }
  }

  /// Récupérer tous les services, optionnellement par catégorie
  static Future<List<Map<String, dynamic>>> getServices({String? category}) async {
    try {
      final response = await ApiService.getInstitutionalServices(category: category);
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des services REST: $e');
      return [];
    }
  }

  /// Récupérer la structure de gouvernance
  static Future<List<Map<String, dynamic>>> getGovernanceStructure() async {
    return getServices(category: 'GOUVERNANCE');
  }

  /// Récupérer les services sous forme d'entités typées
  static Future<List<InstitutionalService>> getInstitutionalServices({ServiceCategory? category}) async {
    try {
      final services = await getServices(category: category?.name);
      return services.map((e) => InstitutionalService.fromMap(e)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des services institutionnels REST: $e');
      return [];
    }
  }

  /// Récupérer les annonces d'un service spécifique
  static Future<List<Map<String, dynamic>>> getServiceAnnouncements(String serviceId) async {
    // TODO: Implémenter le filtrage par serviceId dans le backend
    return [];
  }
}
