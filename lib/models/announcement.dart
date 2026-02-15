class Announcement {
  final int id;
  final String title;
  final String content;
  final String category;
  final String priority;
  final String author;
  final bool isPinned;
  final DateTime createdAt;
  final String? serviceId;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.priority,
    required this.author,
    this.isPinned = false,
    required this.createdAt,
    this.serviceId,
  });

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'] ?? 'Général',
      priority: map['priority'] ?? 'Moyenne',
      author: map['author'] ?? 'Administration',
      isPinned: map['is_pinned'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      serviceId: map['service_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'priority': priority,
      'author': author,
      'is_pinned': isPinned,
      'created_at': createdAt.toIso8601String(),
      'service_id': serviceId,
    };
  }
}
