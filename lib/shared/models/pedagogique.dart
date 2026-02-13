class Note {
  final String id;
  final String courseId;
  final String studentId;
  final double value;
  final String session;
  final DateTime createdAt;
  final String matiere; // Changed from courseId for cleaner display if needed, or keeping it

  Note({
    required this.id,
    required this.courseId,
    required this.studentId,
    required this.value,
    required this.session,
    required this.createdAt,
    this.matiere = '',
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      value: (json['valeur'] ?? json['value'] as num?)?.toDouble() ?? 0.0,
      session: json['session'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      matiere: json['subject'] ?? json['matiere'] ?? '', // Handling potential joins
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
  final String subject;
  final String? teacher;
  final String? teacherId;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final int dayIndex; // 0=Monday
  final String type;
  final String? color;
  final String? status; // 0, 1, 2 etc or text
  final String? niveau;
  final int? filiereId;

  EmploiDuTemps({
    required this.id,
    required this.subject,
    this.teacher,
    this.teacherId,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.dayIndex,
    this.type = 'CM',
    this.color,
    this.status,
    this.niveau,
    this.filiereId,
  });

  factory EmploiDuTemps.fromJson(Map<String, dynamic> json) {
    return EmploiDuTemps(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] ?? '',
      teacher: json['teacher'],
      teacherId: json['teacher_id']?.toString(),
      room: json['room'] ?? '',
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : DateTime.now(),
      dayIndex: (json['day'] as num?)?.toInt() ?? 0,
      type: json['type'] ?? 'CM',
      color: json['color'],
      status: json['status']?.toString(),
      niveau: json['niveau'],
      filiereId: (json['filiere_id'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'teacher': teacher,
        'teacher_id': teacherId,
        'room': room,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'day': dayIndex,
        'type': type,
        'color': color,
        'status': status,
        'niveau': niveau,
        'filiere_id': filiereId,
      };
  
  // Helpers
  String get heureDebut => "\${startTime.hour.toString().padLeft(2, '0')}:\${startTime.minute.toString().padLeft(2, '0')}";
  String get heureFin => "\${endTime.hour.toString().padLeft(2, '0')}:\${endTime.minute.toString().padLeft(2, '0')}";
  
  String get jour {
    const jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    if (dayIndex >= 0 && dayIndex < jours.length) return jours[dayIndex];
    return 'Inconnu';
  }
}
