class Announcement {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final DateTime createdAt;
  final String category;
  final String priority;
  final bool isPinned;
  final String? scope;
  final String? departmentId;
  final String? niveau;
  final String? facultyId;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
    required this.category,
    required this.priority,
    required this.isPinned,
    this.scope,
    this.departmentId,
    this.niveau,
    this.facultyId,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['author'] ?? json['author_name'] ?? 'Administration',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? 'Toutes',
      priority: json['priority'] ?? 'Moyenne',
      isPinned: json['is_pinned'] ?? false,
      scope: json['scope'],
      departmentId: json['department_id']?.toString(),
      niveau: json['niveau'],
      facultyId: json['faculty_id']?.toString(),
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}
