class AIAssistantService {
  Future<Map<String, dynamic>> sendMessage({required String message, String? context}) async {
    // Placeholder for Node.js REST API
    // En production, cet appel devrait pointer vers un endpoint /ai/chat
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'response': "Je suis votre assistant CampusConnect. L'intégration de l'IA est en cours de migration vers le nouveau backend Node.js. Posez-moi une question sur votre emploi du temps ou vos cours !"
    };
  }
}
