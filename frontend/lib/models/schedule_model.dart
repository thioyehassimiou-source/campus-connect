class ScheduleItem {
  final String id;
  final String subject;
  final String teacher;
  final String teacherId; 
  final DateTime startTime;
  final DateTime endTime;
  final String room;
  final int day;
  final String type; // CM, TD, TP
  final String color;
  final int status; // 0=Scheduled, 1=Cancelled, 2=Moved, 3=Pending, 4=Rejected
  final String? notes;
  final String? niveau;
  final int? departmentId;
  final String? scope;
  final String? facultyId;

  ScheduleItem({
    required this.id,
    required this.subject,
    required this.teacher,
    String? teacherId,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.day,
    this.type = 'CM',
    this.color = '#1F77D2',
    this.status = 0,
    this.notes,
    this.niveau,
    this.departmentId,
    this.scope,
    this.facultyId,
  }) : teacherId = teacherId ?? teacher;

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] ?? 'Sans titre',
      teacher: json['teacher'] ?? 'Inconnu',
      teacherId: json['teacher_id']?.toString() ?? json['teacher'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      room: json['room'] ?? 'N/A',
      day: json['day'] ?? 0,
      type: json['type'] ?? 'CM',
      color: json['color'] ?? '#1F77D2',
      status: json['status'] is int ? json['status'] : 0,
      notes: json['notes'],
      niveau: json['niveau'],
      departmentId: json['department_id'] is int ? json['department_id'] : null,
      scope: json['scope'],
      facultyId: json['faculty_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'teacher': teacher,
      'teacher_id': teacherId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'room': room,
      'day': day,
      'type': type,
      'color': color,
      'status': status,
      'notes': notes,
      'niveau': niveau,
      'department_id': departmentId,
      'scope': scope,
      'faculty_id': facultyId,
    };
  }
}
