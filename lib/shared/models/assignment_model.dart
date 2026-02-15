class Assignment {
  final String id;
  final String title;
  final String course;
  final String teacher;
  final String description;
  final String type;
  final DateTime dueDate;
  final String status;
  final String priority;
  final bool submitted;
  final double? grade;
  final double maxGrade;
  final List<String> attachments;
  final int submissionCount;
  final int maxSubmissions;
  final String? feedback;

  Assignment({
    required this.id,
    required this.title,
    required this.course,
    required this.teacher,
    required this.description,
    required this.type,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.submitted,
    this.grade,
    required this.maxGrade,
    required this.attachments,
    required this.submissionCount,
    required this.maxSubmissions,
    this.feedback,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      course: json['course'],
      teacher: json['teacher_name'] ?? 'Professeur',
      description: json['description'] ?? '',
      type: json['type'] ?? 'Devoir',
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      submitted: json['submitted'] ?? false,
      grade: json['grade'] != null ? (json['grade'] as num).toDouble() : null,
      maxGrade: (json['max_grade'] as num?)?.toDouble() ?? 20.0,
      attachments: List<String>.from(json['attachments'] ?? []),
      submissionCount: json['submission_count'] ?? 0,
      maxSubmissions: json['max_submissions'] ?? 45,
      feedback: json['feedback'],
    );
  }
}
