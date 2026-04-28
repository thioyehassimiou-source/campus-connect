import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/institutional_service.dart';

class CampusService {
  static final _supabase = Supabase.instance.client;

  /// Récupérer tous les blocs du campus
  static Future<List<Map<String, dynamic>>> getCampusBlocs() async {
    try {
      final response = await _supabase
          .from('campus_blocs')
          .select()
          .order('name');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des blocs: $e');
      return [];
    }
  }

  /// Récupérer tous les services, optionnellement par catégorie (Retourne Map pour compatibilité)
  static Future<List<Map<String, dynamic>>> getServices({String? category}) async {
    try {
      var query = _supabase
          .from('services')
          .select()
          .eq('is_active', true);
      
      if (category != null) {
        query = query.eq('category', category);
      }

      final response = await query.order('nom');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des services: $e');
      return [];
    }
  }

  /// Récupérer la structure de gouvernance (même si inactive)
  static Future<List<Map<String, dynamic>>> getGovernanceStructure() async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .eq('category', 'GOUVERNANCE')
          .order('nom');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération de la gouvernance: $e');
      return [];
    }
  }

  /// Récupérer les services sous forme d'entités typées
  static Future<List<InstitutionalService>> getInstitutionalServices({ServiceCategory? category}) async {
    try {
      var query = _supabase
          .from('services')
          .select() // Assurez-vous que les colonnes existent
          .eq('is_active', true);
      
      if (category != null) {
        query = query.eq('category', category.name);
      }

      final response = await query.order('nom');
      return (response as List).map((e) => InstitutionalService.fromMap(e)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des services institutionnels: $e');
      return [];
    }
  }

  /// Récupérer les annonces d'un service spécifique
  static Future<List<Map<String, dynamic>>> getServiceAnnouncements(String serviceId) async {
    try {
      final response = await _supabase
          .from('announcements')
          .select()
          .eq('service_id', serviceId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des annonces du service: $e');
      return [];
    }
  }
}
