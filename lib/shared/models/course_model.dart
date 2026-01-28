enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
}

enum CourseStatus {
  scheduled,
  cancelled,
  moved,
}

class CourseModel {
  final String id;
  final String subject;
  final String teacher;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final DayOfWeek day;
  final String color; // hex color
  final CourseStatus status;
  final String? notes;

  CourseModel({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.color,
    this.status = CourseStatus.scheduled,
    this.notes,
  });

  // Computed properties
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  String get startTimeFormatted {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get endTimeFormatted {
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  String get timeRange => '$startTimeFormatted - $endTimeFormatted';

  String get displayColor => color.isNotEmpty ? color : '#1F77D2';

  bool get isCancelled => status == CourseStatus.cancelled;

  bool get isMoved => status == CourseStatus.moved;

  // JSON serialization
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      subject: json['subject'] as String,
      teacher: json['teacher'] as String,
      room: json['room'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      day: DayOfWeek.values[json['day'] as int],
      color: json['color'] as String,
      status: CourseStatus.values[json['status'] as int],
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'teacher': teacher,
      'room': room,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'day': day.index,
      'color': color,
      'status': status.index,
      'notes': notes,
    };
  }
}
