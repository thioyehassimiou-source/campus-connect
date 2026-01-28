import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/domain/models/app_user.dart';
import '../../features/documents/domain/models/document.dart';

class DocumentsService {
  final SupabaseClient _client;

  DocumentsService(this._client);

  bool canPublish(UserRole role) {
    return role == UserRole.enseignant || role == UserRole.admin;
  }

  Future<List<String>> fetchFilieres() async {
    final rows = await _client
        .from('documents')
        .select('filiere')
        .order('filiere');

    final set = <String>{};
    for (final row in (rows as List)) {
      final value = (row as Map)['filiere']?.toString().trim();
      if (value != null && value.isNotEmpty) {
        set.add(value);
      }
    }

    final list = set.toList()..sort();
    return list;
  }

  Future<List<PedagogicDocument>> fetchByFiliere({required String filiere}) async {
    final rows = await _client
        .from('documents')
        .select('*')
        .eq('filiere', filiere)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((e) => PedagogicDocument.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  bool canDownload(AppUser user, PedagogicDocument doc) {
    // Admin can do anything.
    if (user.role == UserRole.admin) return true;

    // For prototype: allow download only if doc is visible for the role.
    return doc.canBeSeenBy(user.role);
  }

  Future<PedagogicDocument> publishDocument({
    required AppUser author,
    required String title,
    required String filiere,
    String? description,
    String? fileUrl,
    String? storageBucket,
    String? storagePath,
    String? fileName,
    int? fileSize,
    bool isPublic = false,
    DocumentTarget target = DocumentTarget.etudiants,
  }) async {
    if (!canPublish(author.role)) {
      throw Exception('Accès refusé');
    }

    final inserted = await _client
        .from('documents')
        .insert({
          'title': title,
          'description': description,
          'filiere': filiere,
          'author_id': author.id,
          'file_url': fileUrl,
          'storage_bucket': storageBucket,
          'storage_path': storagePath,
          'file_name': fileName,
          'file_size': fileSize,
          'is_public': isPublic,
          'target': target.value,
        })
        .select()
        .single();

    return PedagogicDocument.fromMap(inserted);
  }

  Future<String> resolveDownloadUrl({
    required PedagogicDocument doc,
    Duration validity = const Duration(minutes: 10),
  }) async {
    if (doc.fileUrl != null && doc.fileUrl!.isNotEmpty) {
      return doc.fileUrl!;
    }

    final bucket = doc.storageBucket;
    final path = doc.storagePath;

    if (bucket == null || bucket.isEmpty || path == null || path.isEmpty) {
      throw Exception('Aucun lien de téléchargement disponible pour ce document');
    }

    final seconds = validity.inSeconds;
    final signedUrl = await _client.storage.from(bucket).createSignedUrl(path, seconds);
    return signedUrl;
  }

  Future<void> copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
  }
}
