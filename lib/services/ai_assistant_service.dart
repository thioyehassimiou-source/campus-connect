import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/services/auth_service.dart';
import 'package:campusconnect/core/services/profile_service.dart';
import 'package:campusconnect/core/constants/university_hierarchy.dart';
import 'dart:convert';

class AIAssistantService {
  static const String _aiApiUrl = 'https://oecmtlkkklpbzhlajysz.supabase.co/functions/v1/assistant';


  // Envoyer un message à l'assistant IA
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String context,
  }) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final accessToken = session?.accessToken;

      if (accessToken == null) {
        throw Exception('Vous devez être connecté pour utiliser l\'assistant.');
      }

      final profile = await ProfileService.getCurrentUserProfile();
      final roleStr = profile?['role']?.toString().toUpperCase() ?? 'ETUDIANT';
      final serviceType = profile?['service_type']?.toString().toUpperCase();
      final facultyId = profile?['faculty_id']?.toString();
      final departmentId = profile?['department_id']?.toString();

      final institutionalContext = """
Structure de l'université (référence) :
- Gouvernance : Rectorat, Secrétariat général, Vice-rectorats.
- Services Centraux : Scolarité, DAAF, DRH, COUV, Sécurité.
- Appui : Bibliothèque, Centre Informatique, Laboratoires.
- Académique : Services de Facultés et Départements, Recherche.
Utilisateur actuel : Rôle $roleStr, Service ${serviceType ?? 'Aucun'}, Faculté ${facultyId ?? 'N/A'}, Département ${departmentId ?? 'N/A'}.
""";

      return _sendRequest(
        token: accessToken, 
        message: message, 
        context: "$institutionalContext\n$context",
        role: roleStr,
        serviceType: serviceType,
        facultyId: facultyId,
        departmentId: departmentId,
      );

    } catch (e) {
      print('❌ Erreur appel IA: $e');
      return {
        'success': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Méthode séparée pour envoyer la requête
  Future<Map<String, dynamic>> _sendRequest({
    required String token,
    required String message,
    required String context,
    String? role,
    String? serviceType,
    String? facultyId,
    String? departmentId,
  }) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    print('🔑 Headers envoyés: ${headers.keys.toList()}');
    print('🎯 Token utilisé: ${token.substring(0, 20)}...');

    final body = jsonEncode({
      'message': message,
      'context': context,
      'userId': Supabase.instance.client.auth.currentUser?.id,
      'userRole': role,
      'serviceType': serviceType,
      'facultyId': facultyId,
      'departmentId': departmentId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final response = await http.post(
      Uri.parse(_aiApiUrl),
      headers: headers,
      body: body,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Timeout de la requête IA'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {
        'success': true,
        'response': responseData['reply'], // Adaptation pour la réponse Groq
        'timestamp': DateTime.now().toIso8601String(),
      };
    } else if (response.statusCode == 401) {
      // Tentative de rafraîchissement du token
      try {
        print('🔄 Erreur 401: Tentative de refresh du session...');
        final refreshResponse = await Supabase.instance.client.auth.refreshSession();
        
        if (refreshResponse.session?.accessToken != null) {
          final newToken = refreshResponse.session!.accessToken!;
           print('✅ Refresh réussi, nouvelle tentative avec le nouveau token...');
           
           // Retry unique avec le nouveau token
           final retryHeaders = {
              'Authorization': 'Bearer $newToken',
              'Content-Type': 'application/json',
           };
           
           final retryResponse = await http.post(
            Uri.parse(_aiApiUrl),
            headers: retryHeaders,
            body: body,
          );
          
          if (retryResponse.statusCode == 200) {
             final responseData = jsonDecode(retryResponse.body);
             return {
              'success': true,
              'response': responseData['reply'],
              'timestamp': DateTime.now().toIso8601String(),
            };
          }
        }
      } catch (e) {
        print('⚠️ Échec du refresh: $e');
      }
      
      throw Exception('Erreur 401: Session expirée. Veuillez vous reconnecter.');
      
    } else if (response.statusCode == 403) {
      throw Exception('Erreur 403: Accès interdit (Validation serveur échouée)');
    } else {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }
}
