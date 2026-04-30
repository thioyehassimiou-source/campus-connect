class Course {
  final String id;
  final String title;
  final String level;
  final int studentsCount;
  final String status;
  final String color;
  final String? scope;
  final String? departmentId;
  final String? facultyId;

  Course({
    required this.id,
    required this.title,
    required this.level,
    required this.studentsCount,
    required this.status,
    required this.color,
    this.scope,
    this.departmentId,
    this.facultyId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['subject'] ?? 'Cours sans titre',
      level: json['level'] ?? 'L1',
      studentsCount: json['students_count'] ?? 0,
      status: json['status'] ?? 'Actif',
      color: json['color'] ?? '#2563EB',
      scope: json['scope'],
      departmentId: json['department_id']?.toString(),
      facultyId: json['faculty_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'level': level,
      'students_count': studentsCount,
      'status': status,
      'color': color,
      'scope': scope,
      'department_id': departmentId,
      'faculty_id': facultyId,
    };
  }
}
