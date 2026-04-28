import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  static final _supabase = Supabase.instance.client;
  static const String bucketName = 'assignments-submissions';

  /// Upload un fichier vers Supabase Storage
  /// Retourne l'URL publique du fichier uploadé
  static Future<String> uploadFile({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      final fileName = path.split('/').last;
      final fileExt = fileName.split('.').last;
      
      // Vérifier la taille du fichier (max 10 MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Le fichier est trop volumineux (max 10 MB)');
      }

      // Vérifier l'extension
      final allowedExtensions = ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'];
      if (!allowedExtensions.contains(fileExt.toLowerCase())) {
        throw Exception('Type de fichier non autorisé. Formats acceptés: ${allowedExtensions.join(", ")}');
      }

      // Upload le fichier
      await _supabase.storage
          .from(bucketName)
          .upload(
            path,
            file,
            fileOptions: FileOptions(
              upsert: true, // Remplacer si existe déjà
              contentType: _getContentType(fileExt),
            ),
          );

      // Récupérer l'URL publique
      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  /// Télécharge un fichier depuis Supabase Storage
  static Future<List<int>> downloadFile(String path) async {
    try {
      final bytes = await _supabase.storage
          .from(bucketName)
          .download(path);
      
      return bytes;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement: $e');
    }
  }

  /// Supprime un fichier de Supabase Storage
  static Future<void> deleteFile(String path) async {
    try {
      await _supabase.storage
          .from(bucketName)
          .remove([path]);
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  /// Liste les fichiers d'un dossier
  static Future<List<FileObject>> listFiles(String path) async {
    try {
      final files = await _supabase.storage
          .from(bucketName)
          .list(path: path);
      
      return files;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des fichiers: $e');
    }
  }

  /// Récupère l'URL publique d'un fichier
  static String getPublicUrl(String path) {
    return _supabase.storage
        .from(bucketName)
        .getPublicUrl(path);
  }

  /// Détermine le content-type selon l'extension
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  /// Crée le bucket s'il n'existe pas (à appeler au démarrage de l'app)
  static Future<void> ensureBucketExists() async {
    try {
      // Vérifier si le bucket existe
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((b) => b.name == bucketName);
      
      if (!bucketExists) {
        // Créer le bucket
        await _supabase.storage.createBucket(
          bucketName,
          BucketOptions(
            public: false, // Fichiers privés
            fileSizeLimit: (10 * 1024 * 1024).toString(), // 10 MB max
          ),
        );
        print('✅ Bucket $bucketName créé avec succès');
      }
    } catch (e) {
      print('⚠️ Erreur lors de la vérification du bucket: $e');
    }
  }
}
