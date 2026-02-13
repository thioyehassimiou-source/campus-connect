import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class Resource {
  final String id;
  final String title;
  final String description;
  final String url;
  final String type; // PDF, VIDEO, LINK
  final String subject;
  final String authorName;
  final String? authorId; // Make it nullable if not always present
  final DateTime date;
  final String? scope;
  final String? departmentId;
  final String? facultyId;
  final String? niveau;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.type,
    required this.subject,
    required this.authorName,
    this.authorId,
    required this.date,
    this.scope,
    this.departmentId,
    this.facultyId,
    this.niveau,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      url: json['url'],
      type: json['type'] ?? 'PDF',
      subject: json['subject'],
      authorName: json['author_name'] ?? 'Enseignant',
      authorId: json['author_id'],
      date: DateTime.parse(json['created_at']),
      scope: json['scope'],
      departmentId: json['department_id']?.toString(),
      facultyId: json['faculty_id']?.toString(),
      niveau: json['niveau'],
    );
  }

  // Getters for compatibility
  DateTime get uploadDate => date;
}

class ResourceService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupérer les ressources (optionnel: filtrer par matière)
  static Future<List<Resource>> getResources({String? subject}) async {
    try {
      // Start with the filter builder
      var query = _supabase.from('resources').select();
      
      // Apply filters
      if (subject != null && subject.isNotEmpty && subject != 'Tout') {
        query = query.eq('subject', subject);
      }

      // Apply ordering at the end
      final response = await query.order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Resource.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur récupération ressources: $e');
      return [];
    }
  }

  /// Téléverser un fichier vers Supabase Storage
  static Future<String> uploadResourceFile(String fileName, List<int> bytes) async {
    try {
      final String path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await _supabase.storage.from('resources').uploadBinary(
        path,
        Uint8List.fromList(bytes),
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Récupérer l'URL publique
      return _supabase.storage.from('resources').getPublicUrl(path);
    } catch (e) {
      print('❌ Erreur upload fichier: $e');
      rethrow;
    }
  }

  /// Ajouter une ressource (Prof seulement)
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
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Non connecté');

      // Récupérer le nom de l'auteur depuis le profil
      final profile = await _supabase.from('profiles').select('nom').eq('id', user.id).maybeSingle();
      final authorName = profile?['nom'] ?? 'Enseignant';

      await _supabase.from('resources').insert({
        'title': title,
        'description': description,
        'url': url,
        'type': type,
        'subject': subject,
        'author_id': user.id,
        'author_name': authorName,
        'scope': scope,
        'department_id': departmentId,
        'faculty_id': facultyId,
        'niveau': niveau,
      });
    } catch (e) {
      print('❌ Erreur ajout ressource: $e');
      rethrow;
    }
  }
}
