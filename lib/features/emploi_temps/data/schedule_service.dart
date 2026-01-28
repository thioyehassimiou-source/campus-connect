import 'package:campusconnect/shared/models/course_model.dart';

class ScheduleService {
  static final List<CourseModel> _mockCourses = [
    // Monday
    CourseModel(
      id: 'course_001',
      subject: 'Mathématiques Appliquées',
      teacher: 'Dr. Ahmed Sow',
      room: 'Salle A101',
      startTime: DateTime(2026, 1, 28, 8, 0),
      endTime: DateTime(2026, 1, 28, 9, 30),
      day: DayOfWeek.monday,
      color: '#1F77D2',
    ),
    CourseModel(
      id: 'course_002',
      subject: 'Programmation Dart',
      teacher: 'Prof. Fatou Ndiaye',
      room: 'Labo B205',
      startTime: DateTime(2026, 1, 28, 10, 0),
      endTime: DateTime(2026, 1, 28, 12, 0),
      day: DayOfWeek.monday,
      color: '#FF6B35',
    ),
    CourseModel(
      id: 'course_003',
      subject: 'Anglais Technique',
      teacher: 'Mme. Laura Smith',
      room: 'Salle C301',
      startTime: DateTime(2026, 1, 28, 13, 0),
      endTime: DateTime(2026, 1, 28, 14, 0),
      day: DayOfWeek.monday,
      color: '#2ECC71',
    ),

    // Tuesday
    CourseModel(
      id: 'course_004',
      subject: 'Bases de Données',
      teacher: 'Dr. Jean Dupont',
      room: 'Salle A205',
      startTime: DateTime(2026, 1, 29, 9, 0),
      endTime: DateTime(2026, 1, 29, 10, 30),
      day: DayOfWeek.tuesday,
      color: '#9B59B6',
    ),
    CourseModel(
      id: 'course_005',
      subject: 'Algorithmes',
      teacher: 'Prof. Mamadou Ba',
      room: 'Labo B305',
      startTime: DateTime(2026, 1, 29, 11, 0),
      endTime: DateTime(2026, 1, 29, 12, 30),
      day: DayOfWeek.tuesday,
      color: '#FF6B35',
    ),
    CourseModel(
      id: 'course_006',
      subject: 'Gestion de Projet',
      teacher: 'Dr. Sophie Martin',
      room: 'Amphi D001',
      startTime: DateTime(2026, 1, 29, 14, 0),
      endTime: DateTime(2026, 1, 29, 15, 30),
      day: DayOfWeek.tuesday,
      color: '#3498DB',
    ),

    // Wednesday
    CourseModel(
      id: 'course_007',
      subject: 'Architecture Logicielle',
      teacher: 'Prof. Sall Ousmane',
      room: 'Salle A102',
      startTime: DateTime(2026, 1, 30, 8, 30),
      endTime: DateTime(2026, 1, 30, 10, 0),
      day: DayOfWeek.wednesday,
      color: '#E74C3C',
    ),
    CourseModel(
      id: 'course_008',
      subject: 'Web Development',
      teacher: 'Prof. Aissatou Diallo',
      room: 'Labo B206',
      startTime: DateTime(2026, 1, 30, 10, 30),
      endTime: DateTime(2026, 1, 30, 12, 30),
      day: DayOfWeek.wednesday,
      color: '#3498DB',
    ),

    // Thursday
    CourseModel(
      id: 'course_009',
      subject: 'Séminaire Sécurité',
      teacher: 'Dr. Moussa Kone',
      room: 'Amphi D002',
      startTime: DateTime(2026, 1, 31, 9, 0),
      endTime: DateTime(2026, 1, 31, 11, 0),
      day: DayOfWeek.thursday,
      color: '#E74C3C',
    ),
    CourseModel(
      id: 'course_010',
      subject: 'Programmation Mobile',
      teacher: 'Prof. Fatou Ndiaye',
      room: 'Labo B207',
      startTime: DateTime(2026, 1, 31, 13, 0),
      endTime: DateTime(2026, 1, 31, 15, 0),
      day: DayOfWeek.thursday,
      color: '#FF6B35',
    ),

    // Friday
    CourseModel(
      id: 'course_011',
      subject: 'Systèmes d\'exploitation',
      teacher: 'Dr. Ahmed Sow',
      room: 'Salle A303',
      startTime: DateTime(2026, 2, 1, 8, 0),
      endTime: DateTime(2026, 2, 1, 9, 30),
      day: DayOfWeek.friday,
      color: '#9B59B6',
    ),
    CourseModel(
      id: 'course_012',
      subject: 'TP Réseaux',
      teacher: 'Prof. Aliou Sene',
      room: 'Labo C101',
      startTime: DateTime(2026, 2, 1, 10, 0),
      endTime: DateTime(2026, 2, 1, 12, 0),
      day: DayOfWeek.friday,
      color: '#1ABC9C',
      notes: 'Apporter cable réseau',
    ),

    // Saturday
    CourseModel(
      id: 'course_013',
      subject: 'Séminaire Recherche',
      teacher: 'Dr. Jean Dupont',
      room: 'Amphi D003',
      startTime: DateTime(2026, 2, 2, 9, 0),
      endTime: DateTime(2026, 2, 2, 11, 0),
      day: DayOfWeek.saturday,
      color: '#3498DB',
    ),
  ];

  /// Get full week schedule
  static Future<List<CourseModel>> getWeekSchedule() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockCourses;
  }

  /// Get courses for a specific day, sorted by start time
  static List<CourseModel> getCoursesByDay(
    List<CourseModel> courses,
    DayOfWeek day,
  ) {
    final daysCourses = courses.where((c) => c.day == day).toList();
    daysCourses.sort((a, b) => a.startTime.compareTo(b.startTime));
    return daysCourses;
  }

  /// Get today's courses
  static List<CourseModel> getTodaysCourses(
    List<CourseModel> courses,
    DateTime today,
  ) {
    final dayOfWeek = _dateTimeToDayOfWeek(today);
    return getCoursesByDay(courses, dayOfWeek);
  }

  /// Get courses in next 24 hours
  static List<CourseModel> getUpcomingCourses(
    List<CourseModel> courses,
    DateTime from,
  ) {
    final to = from.add(const Duration(hours: 24));
    return courses
        .where((c) => c.startTime.isAfter(from) && c.startTime.isBefore(to))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Get course count for each day
  static Map<DayOfWeek, int> getCoursesCountByDay(List<CourseModel> courses) {
    final counts = <DayOfWeek, int>{};
    for (final day in DayOfWeek.values) {
      counts[day] = getCoursesByDay(courses, day).length;
    }
    return counts;
  }

  /// Get days with at least one course
  static List<DayOfWeek> getDaysWithCourses(List<CourseModel> courses) {
    return DayOfWeek.values
        .where((day) => getCoursesByDay(courses, day).isNotEmpty)
        .toList();
  }

  /// Format day to French name
  static String formatDay(DayOfWeek day) {
    const names = {
      DayOfWeek.monday: 'Lundi',
      DayOfWeek.tuesday: 'Mardi',
      DayOfWeek.wednesday: 'Mercredi',
      DayOfWeek.thursday: 'Jeudi',
      DayOfWeek.friday: 'Vendredi',
      DayOfWeek.saturday: 'Samedi',
    };
    return names[day] ?? '';
  }

  /// Format day to short French name
  static String formatDayShort(DayOfWeek day) {
    const names = {
      DayOfWeek.monday: 'Lun',
      DayOfWeek.tuesday: 'Mar',
      DayOfWeek.wednesday: 'Mer',
      DayOfWeek.thursday: 'Jeu',
      DayOfWeek.friday: 'Ven',
      DayOfWeek.saturday: 'Sam',
    };
    return names[day] ?? '';
  }

  /// Helper: Convert DateTime to DayOfWeek
  static DayOfWeek _dateTimeToDayOfWeek(DateTime date) {
    const dayMap = {
      1: DayOfWeek.monday,
      2: DayOfWeek.tuesday,
      3: DayOfWeek.wednesday,
      4: DayOfWeek.thursday,
      5: DayOfWeek.friday,
      6: DayOfWeek.saturday,
      7: DayOfWeek.monday, // Sunday maps to Monday for simplicity
    };
    return dayMap[date.weekday] ?? DayOfWeek.monday;
  }
}
