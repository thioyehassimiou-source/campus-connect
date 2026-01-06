import 'package:equatable/equatable.dart';

enum AnnouncementPriority { low, medium, high, urgent }

enum AnnouncementTarget { all, students, teachers, specific }

class AnnouncementModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final AnnouncementPriority priority;
  final AnnouncementTarget target;
  final List<String> targetUserIds;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final List<String> attachments;
  final bool isActive;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.priority,
    required this.target,
    required this.targetUserIds,
    required this.createdAt,
    this.expiresAt,
    required this.attachments,
    required this.isActive,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      priority: AnnouncementPriority.values.firstWhere(
        (priority) => priority.name == map['priority'],
        orElse: () => AnnouncementPriority.medium,
      ),
      target: AnnouncementTarget.values.firstWhere(
        (target) => target.name == map['target'],
        orElse: () => AnnouncementTarget.all,
      ),
      targetUserIds: List<String>.from(map['targetUserIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: map['expiresAt']?.toDate(),
      attachments: List<String>.from(map['attachments'] ?? []),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'priority': priority.name,
      'target': target.name,
      'targetUserIds': targetUserIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'attachments': attachments,
      'isActive': isActive,
    };
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    AnnouncementPriority? priority,
    AnnouncementTarget? target,
    List<String>? targetUserIds,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? attachments,
    bool? isActive,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      priority: priority ?? this.priority,
      target: target ?? this.target,
      targetUserIds: targetUserIds ?? this.targetUserIds,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      attachments: attachments ?? this.attachments,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        authorId,
        authorName,
        priority,
        target,
        targetUserIds,
        createdAt,
        expiresAt,
        attachments,
        isActive,
      ];

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  String get priorityDisplayName {
    switch (priority) {
      case AnnouncementPriority.low:
        return 'Basse';
      case AnnouncementPriority.medium:
        return 'Moyenne';
      case AnnouncementPriority.high:
        return 'Haute';
      case AnnouncementPriority.urgent:
        return 'Urgente';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case AnnouncementPriority.low:
        return Colors.green;
      case AnnouncementPriority.medium:
        return Colors.orange;
      case AnnouncementPriority.high:
        return Colors.red;
      case AnnouncementPriority.urgent:
        return Colors.purple;
    }
  }
}
