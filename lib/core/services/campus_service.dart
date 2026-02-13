import 'package:supabase_flutter/supabase_flutter.dart';

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
}
