import 'package:equatable/equatable.dart';

enum GradeType { exam, assignment, project, participation, quiz }

class GradeModel extends Equatable {
  final String id;
  final String studentId;
  final String courseId;
  final String courseName;
  final String teacherId;
  final String teacherName;
  final String title;
  final GradeType type;
  final double value;
  final double maxValue;
  final double coefficient;
  final DateTime date;
  final String? description;
  final String? feedback;

  const GradeModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.courseName,
    required this.teacherId,
    required this.teacherName,
    required this.title,
    required this.type,
    required this.value,
    required this.maxValue,
    required this.coefficient,
    required this.date,
    this.description,
    this.feedback,
  });

  factory GradeModel.fromMap(Map<String, dynamic> map) {
    return GradeModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      title: map['title'] ?? '',
      type: GradeType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => GradeType.exam,
      ),
      value: (map['value'] ?? 0).toDouble(),
      maxValue: (map['maxValue'] ?? 0).toDouble(),
      coefficient: (map['coefficient'] ?? 1).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'],
      feedback: map['feedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'courseId': courseId,
      'courseName': courseName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'title': title,
      'type': type.name,
      'value': value,
      'maxValue': maxValue,
      'coefficient': coefficient,
      'date': Timestamp.fromDate(date),
      'description': description,
      'feedback': feedback,
    };
  }

  GradeModel copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? courseName,
    String? teacherId,
    String? teacherName,
    String? title,
    GradeType? type,
    double? value,
    double? maxValue,
    double? coefficient,
    DateTime? date,
    String? description,
    String? feedback,
  }) {
    return GradeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      title: title ?? this.title,
      type: type ?? this.type,
      value: value ?? this.value,
      maxValue: maxValue ?? this.maxValue,
      coefficient: coefficient ?? this.coefficient,
      date: date ?? this.date,
      description: description ?? this.description,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        courseId,
        courseName,
        teacherId,
        teacherName,
        title,
        type,
        value,
        maxValue,
        coefficient,
        date,
        description,
        feedback,
      ];

  double get percentage => maxValue > 0 ? (value / maxValue) * 100 : 0;
  
  double get weightedValue => value * coefficient;
  
  double get weightedMaxValue => maxValue * coefficient;

  String get typeDisplayName {
    switch (type) {
      case GradeType.exam:
        return 'Examen';
      case GradeType.assignment:
        return 'Devoir';
      case GradeType.project:
        return 'Projet';
      case GradeType.participation:
        return 'Participation';
      case GradeType.quiz:
        return 'Interrogation';
    }
  }

  String get gradeDisplay => '$value/$maxValue';
}
