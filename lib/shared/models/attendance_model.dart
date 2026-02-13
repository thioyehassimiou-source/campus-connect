class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String? studentPhoto;
  final String course;
  final String teacherId;
  final DateTime date;
  final String status; // present, absent, late
  final String? room;
  final bool justified;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentPhoto,
    required this.course,
    required this.teacherId,
    required this.date,
    required this.status,
    this.room,
    this.justified = false,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      studentId: json['student_id'],
      studentName: json['profiles']?['full_name'] ?? 'Étudiant',
      studentPhoto: json['profiles']?['avatar_url'],
      course: json['course'],
      teacherId: json['teacher_id'],
      date: DateTime.parse(json['date']),
      status: json['status'] ?? 'present',
      room: json['room'],
      justified: json['justified'] ?? false,
    );
  }
}

class AttendanceStats {
  final int totalClasses;
  final int presentClasses;
  final int absentClasses;
  final int lateClasses;
  final double attendanceRate;

  AttendanceStats({
    required this.totalClasses,
    required this.presentClasses,
    required this.absentClasses,
    required this.lateClasses,
    required this.attendanceRate,
  });
}
