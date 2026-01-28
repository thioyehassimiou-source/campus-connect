class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String? authorName;
  final AnnouncementPriority priority;
  final List<AnnouncementTarget> targetAudience;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.authorName,
    required this.priority,
    required this.targetAudience,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['author_id'] ?? '',
      authorName: json['author_name'],
      priority: _parsePriority(json['priority']),
      targetAudience: _parseTargets(json['target_audience']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'author_id': authorId,
        'author_name': authorName,
        'priority': priority.toString().split('.').last,
        'target_audience':
            targetAudience.map((t) => t.toString().split('.').last).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'is_active': isActive,
      };

  static AnnouncementPriority _parsePriority(dynamic priorityValue) {
    if (priorityValue == null) return AnnouncementPriority.normal;
    final priorityStr = priorityValue.toString().toLowerCase();
    if (priorityStr.contains('high')) return AnnouncementPriority.high;
    if (priorityStr.contains('low')) return AnnouncementPriority.low;
    return AnnouncementPriority.normal;
  }

  static List<AnnouncementTarget> _parseTargets(dynamic targetsValue) {
    if (targetsValue == null) return [];
    if (targetsValue is List) {
      return targetsValue
          .map((t) {
            final targetStr = t.toString().toLowerCase();
            if (targetStr.contains('student')) return AnnouncementTarget.students;
            if (targetStr.contains('teacher')) return AnnouncementTarget.teachers;
            if (targetStr.contains('admin')) return AnnouncementTarget.admins;
            if (targetStr.contains('all')) return AnnouncementTarget.all;
            return AnnouncementTarget.all;
          })
          .toList();
    }
    return [];
  }
}

enum AnnouncementPriority {
  low,
  normal,
  high,
  medium,
  urgent,
}

enum AnnouncementTarget {
  students,
  teachers,
  admins,
  all,
  specific,
}
