import 'package:campusconnect/shared/models/course_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get full week schedule from Supabase
  static Future<List<CourseModel>> getWeekSchedule() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Récupérer le profil pour voir si c'est student ou teacher (pour filtrer la validation)
      // Optimisation: On pourrait stocker le role en local storage/state pour éviter ce call à chaque fois
      final profileResponse = await _supabase.from('profiles').select('role').eq('id', user.id).single();
      final isStudent = profileResponse['role'] == 'Student';

      // Start with select() which returns PostgrestFilterBuilder
      var query = _supabase.from('schedules').select();

      // Apply filters FIRST
      if (isStudent) {
        query = query.eq('status', 0); // 0 = Scheduled
      }

      // Apply ordering LAST
      final response = await query.order('start_time', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      
      return data.map((json) => CourseModel.fromJson({
        'id': json['id'],
        'subject': json['subject'],
        'teacher': json['teacher'],
        'room': json['room'],
        'startTime': json['start_time'], 
        'endTime': json['end_time'],
        'day': json['day'],
        'color': json['color'] ?? '#1F77D2',
        'status': json['status'].toString(), // Convertit l'entier en string pour le modèle
        'notes': json['notes'],
      })).toList();

    } catch (e) {
      print('❌ Erreur récupération emploi du temps: $e');
      return []; 
    }
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

  /// Add a new course (Teacher only)
  static Future<void> addCourse(CourseModel course) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _supabase.from('schedules').insert({
        'subject': course.subject,
        'teacher': course.teacher,
        'room': course.room,
        'start_time': course.startTime.toIso8601String(),
        'end_time': course.endTime.toIso8601String(),
        'day': course.day.index,
        'color': course.color,
        'status': 0, // Scheduled par défaut
        'notes': course.notes,
      });
    } catch (e) {
      print('❌ Erreur ajout cours: $e');
      rethrow;
    }
  }

  /// Delete a course (Teacher only)
  static Future<void> deleteCourse(String courseId) async {
    try {
      await _supabase.from('schedules').delete().eq('id', courseId);
    } catch (e) {
      print('❌ Erreur suppression cours: $e');
      rethrow;
    }
  }

  /// Validate a course (DP/Admin only)
  static Future<void> validateCourse(String courseId) async {
    try {
      await _supabase.from('schedules').update({'status': 'validated'}).eq('id', courseId);
    } catch (e) {
      print('❌ Erreur validation cours: $e');
      rethrow;
    }
  }

  /// Reject a course (DP/Admin only)
  static Future<void> rejectCourse(String courseId) async {
    try {
      await _supabase.from('schedules').update({'status': 'rejected'}).eq('id', courseId);
    } catch (e) {
      print('❌ Erreur rejet cours: $e');
      rethrow;
    }
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
