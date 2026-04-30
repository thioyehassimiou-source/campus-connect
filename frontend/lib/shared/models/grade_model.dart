class GradeModel {
  final String id;
  final String studentId;
  final String courseId;
  final String courseName;
  final double? value;
  final double? maxValue;
  final double? weightedValue;
  final double? weightedMaxValue;
  final GradeType? type;
  final DateTime assignedDate;

  GradeModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.courseName,
    this.value,
    this.maxValue,
    this.weightedValue,
    this.weightedMaxValue,
    this.type,
    required this.assignedDate,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      courseId: json['course_id'] ?? '',
      courseName: json['course_name'] ?? '',
      value: (json['value'] as num?)?.toDouble(),
      maxValue: (json['max_value'] as num?)?.toDouble(),
      weightedValue: (json['weighted_value'] as num?)?.toDouble(),
      weightedMaxValue: (json['weighted_max_value'] as num?)?.toDouble(),
      type: _parseGradeType(json['type']),
      assignedDate: json['assigned_date'] != null
          ? DateTime.parse(json['assigned_date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'course_id': courseId,
        'course_name': courseName,
        'value': value,
        'max_value': maxValue,
        'weighted_value': weightedValue,
        'weighted_max_value': weightedMaxValue,
        'type': type?.toString().split('.').last,
        'assigned_date': assignedDate.toIso8601String(),
      };

  static GradeType _parseGradeType(dynamic typeValue) {
    if (typeValue == null) return GradeType.exam;
    final typeStr = typeValue.toString().toLowerCase();
    if (typeStr.contains('participation')) return GradeType.participation;
    if (typeStr.contains('assignment')) return GradeType.assignment;
    if (typeStr.contains('project')) return GradeType.project;
    if (typeStr.contains('exam')) return GradeType.exam;
    return GradeType.exam;
  }
}

enum GradeType {
  exam,
  assignment,
  participation,
  project,
  quiz,
}
