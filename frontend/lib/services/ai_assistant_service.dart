import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIAssistantService {
  static const String _supabaseUrl = 'https://oecmtlkkklpbzhlajysz.supabase.co';
  static const String _anonKey = 'sb_publishable_vlC5kvt8eBqQLuCDhM_1FQ_c9BvqTX6';
  static const String _assistantEndpoint = '$_supabaseUrl/functions/v1/assistant';

  Future<Map<String, dynamic>> sendMessage({required String message, String? context}) async {
    try {
      // Pour l'authentification si la function edge la requiert (avec ou sans JWT Node)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_anonKey', // Anon key for Supabase API gateway
      };

      // Si vous utilisez le token JWT du Node backend comme auth additionnel
      if (token != null) {
        headers['x-auth-token'] = token;
      }

      final body = jsonEncode({
        'message': message,
        'context': context ?? '',
      });

      final response = await http.post(
        Uri.parse(_assistantEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'response': data['response'] ?? data['reply'] ?? data['message'] ?? 'Réponse reçue, mais format non reconnu.',
        };
      } else {
        print('Erreur IA Assistant: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'response': 'Erreur serveur: Impossible de contacter l\'assistant IA.'
        };
      }
    } catch (e) {
      print('Exception IA Assistant: $e');
      return {
        'success': false,
        'response': 'Une erreur réseau s\'est produite. Vérifiez votre connexion.'
      };
    }
  }
}
