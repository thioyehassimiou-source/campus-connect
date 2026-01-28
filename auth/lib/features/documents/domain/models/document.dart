import '../../../auth/domain/models/app_user.dart';

enum DocumentTarget {
  tous,
  etudiants,
  enseignants;

  static DocumentTarget fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'etudiants':
      case 'étudiants':
      case 'students':
        return DocumentTarget.etudiants;
      case 'enseignants':
      case 'teachers':
        return DocumentTarget.enseignants;
      case 'tous':
      case 'all':
      default:
        return DocumentTarget.tous;
    }
  }

  String get value {
    switch (this) {
      case DocumentTarget.tous:
        return 'tous';
      case DocumentTarget.etudiants:
        return 'etudiants';
      case DocumentTarget.enseignants:
        return 'enseignants';
    }
  }

  String get label {
    switch (this) {
      case DocumentTarget.tous:
        return 'Tous';
      case DocumentTarget.etudiants:
        return 'Étudiants';
      case DocumentTarget.enseignants:
        return 'Enseignants';
    }
  }
}

class PedagogicDocument {
  final String id;
  final String title;
  final String? description;
  final String filiere;
  final String? authorId;

  // Either a direct URL (public) OR a storage reference (bucket/path)
  final String? fileUrl;
  final String? storageBucket;
  final String? storagePath;

  final String? fileName;
  final int? fileSize;
  final DateTime createdAt;

  // Access control
  final bool isPublic;
  final DocumentTarget target;

  const PedagogicDocument({
    required this.id,
    required this.title,
    required this.filiere,
    required this.createdAt,
    this.description,
    this.authorId,
    this.fileUrl,
    this.storageBucket,
    this.storagePath,
    this.fileName,
    this.fileSize,
    required this.isPublic,
    required this.target,
  });

  factory PedagogicDocument.fromMap(Map<String, dynamic> map) {
    final createdRaw = map['created_at'] ?? map['createdAt'];
    final createdAt = createdRaw is String
        ? (DateTime.tryParse(createdRaw) ?? DateTime.now())
        : (createdRaw is DateTime ? createdRaw : DateTime.now());

    return PedagogicDocument(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? map['titre'] ?? '').toString(),
      description: map['description']?.toString() ?? map['desc']?.toString(),
      filiere: (map['filiere'] ?? '').toString(),
      authorId: (map['author_id'] ?? map['uploaded_by'] ?? map['auteur_id'])?.toString(),
      fileUrl: (map['file_url'] ?? map['url'] ?? map['public_url'])?.toString(),
      storageBucket: (map['storage_bucket'] ?? map['bucket'])?.toString(),
      storagePath: (map['storage_path'] ?? map['path'])?.toString(),
      fileName: (map['file_name'] ?? map['filename'])?.toString(),
      fileSize: map['file_size'] is int
          ? map['file_size'] as int
          : int.tryParse((map['file_size'] ?? '').toString()),
      isPublic: map['is_public'] == true || map['public'] == true,
      target: DocumentTarget.fromString((map['target'] ?? map['cible'])?.toString()),
      createdAt: createdAt,
    );
  }

  bool canBeSeenBy(UserRole role) {
    if (isPublic) return true;
    switch (target) {
      case DocumentTarget.tous:
        return true;
      case DocumentTarget.etudiants:
        return role == UserRole.etudiant || role == UserRole.admin;
      case DocumentTarget.enseignants:
        return role == UserRole.enseignant || role == UserRole.admin;
    }
  }
}
