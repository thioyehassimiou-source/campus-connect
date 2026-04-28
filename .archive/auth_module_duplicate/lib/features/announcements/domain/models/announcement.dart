enum AnnouncementTarget {
  tous,
  etudiants,
  enseignants;

  static AnnouncementTarget fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'etudiants':
      case 'étudiants':
      case 'students':
        return AnnouncementTarget.etudiants;
      case 'enseignants':
      case 'teachers':
        return AnnouncementTarget.enseignants;
      case 'tous':
      case 'all':
      default:
        return AnnouncementTarget.tous;
    }
  }

  String get value {
    switch (this) {
      case AnnouncementTarget.tous:
        return 'tous';
      case AnnouncementTarget.etudiants:
        return 'etudiants';
      case AnnouncementTarget.enseignants:
        return 'enseignants';
    }
  }

  String get label {
    switch (this) {
      case AnnouncementTarget.tous:
        return 'Tous';
      case AnnouncementTarget.etudiants:
        return 'Étudiants';
      case AnnouncementTarget.enseignants:
        return 'Enseignants';
    }
  }
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final AnnouncementTarget target;
  final String? authorId;
  final DateTime createdAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.target,
    required this.createdAt,
    this.authorId,
  });

  factory Announcement.fromMap(Map<String, dynamic> map) {
    final createdRaw = map['created_at'] ?? map['createdAt'];
    final createdAt = createdRaw is String
        ? (DateTime.tryParse(createdRaw) ?? DateTime.now())
        : (createdRaw is DateTime ? createdRaw : DateTime.now());

    return Announcement(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? map['titre'] ?? '').toString(),
      content: (map['content'] ?? map['contenu'] ?? '').toString(),
      target: AnnouncementTarget.fromString(
        (map['target'] ?? map['cible'])?.toString(),
      ),
      authorId: (map['author_id'] ?? map['created_by'] ?? map['auteur_id'])?.toString(),
      createdAt: createdAt,
    );
  }
}
