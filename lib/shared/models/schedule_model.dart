import 'package:equatable/equatable.dart';

enum CourseType { lecture, tutorial, lab, exam, meeting }

class ScheduleModel extends Equatable {
  final String id;
  final String courseId;
  final String courseName;
  final String teacherId;
  final String teacherName;
  final String? classroom;
  final DateTime startTime;
  final DateTime endTime;
  final CourseType type;
  final String? description;
  final List<String> studentIds;

  const ScheduleModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.teacherId,
    required this.teacherName,
    this.classroom,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.description,
    required this.studentIds,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      classroom: map['classroom'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      type: CourseType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => CourseType.lecture,
      ),
      description: map['description'],
      studentIds: List<String>.from(map['studentIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'classroom': classroom,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'type': type.name,
      'description': description,
      'studentIds': studentIds,
    };
  }

  ScheduleModel copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? teacherId,
    String? teacherName,
    String? classroom,
    DateTime? startTime,
    DateTime? endTime,
    CourseType? type,
    String? description,
    List<String>? studentIds,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      classroom: classroom ?? this.classroom,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      description: description ?? this.description,
      studentIds: studentIds ?? this.studentIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseName,
        teacherId,
        teacherName,
        classroom,
        startTime,
        endTime,
        type,
        description,
        studentIds,
      ];

  String get typeDisplayName {
    switch (type) {
      case CourseType.lecture:
        return 'Cours';
      case CourseType.tutorial:
        return 'TD';
      case CourseType.lab:
        return 'TP';
      case CourseType.exam:
        return 'Examen';
      case CourseType.meeting:
        return 'Réunion';
    }
  }

  Duration get duration => endTime.difference(startTime);
}
