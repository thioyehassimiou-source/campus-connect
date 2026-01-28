class Note {
  final String id;
  final String courseId;
  final String studentId;
  final double value;
  final String session;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.courseId,
    required this.studentId,
    required this.value,
    required this.session,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      studentId: json['student_id'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      session: json['session'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'student_id': studentId,
        'value': value,
        'session': session,
        'created_at': createdAt.toIso8601String(),
      };
}

class EmploiDuTemps {
  final String id;
  final String courseId;
  final String courseName;
  final String? classroom;
  final String? instructor;
  final String heureDebut;
  final String heureFin;
  final String jour;
  final DateTime date;

  EmploiDuTemps({
    required this.id,
    required this.courseId,
    required this.courseName,
    this.classroom,
    this.instructor,
    required this.heureDebut,
    required this.heureFin,
    required this.jour,
    required this.date,
  });

  factory EmploiDuTemps.fromJson(Map<String, dynamic> json) {
    return EmploiDuTemps(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      courseName: json['course_name'] ?? '',
      classroom: json['classroom'],
      instructor: json['instructor'],
      heureDebut: json['heure_debut'] ?? '',
      heureFin: json['heure_fin'] ?? '',
      jour: json['jour'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'course_name': courseName,
        'classroom': classroom,
        'instructor': instructor,
        'heure_debut': heureDebut,
        'heure_fin': heureFin,
        'jour': jour,
        'date': date.toIso8601String(),
      };
}
