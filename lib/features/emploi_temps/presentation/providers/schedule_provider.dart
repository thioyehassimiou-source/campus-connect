import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/shared/models/course_model.dart';
import '../data/schedule_service.dart';

// Selected day for viewing
final selectedDayProvider = StateProvider<DayOfWeek>((ref) {
  return DayOfWeek.monday;
});

// Full week schedule
final weekScheduleProvider = FutureProvider<List<CourseModel>>((ref) async {
  return await ScheduleService.getWeekSchedule();
});

// Daily schedule (filtered by selected day)
final dailyScheduleProvider = FutureProvider<List<CourseModel>>((ref) async {
  final courses = await ref.watch(weekScheduleProvider.future);
  final selectedDay = ref.watch(selectedDayProvider);
  return ScheduleService.getCoursesByDay(courses, selectedDay);
});

// Course count by day
final coursesCountProvider = FutureProvider<Map<DayOfWeek, int>>((ref) async {
  final courses = await ref.watch(weekScheduleProvider.future);
  return ScheduleService.getCoursesCountByDay(courses);
});

// Days with courses
final daysWithCoursesProvider = FutureProvider<List<DayOfWeek>>((ref) async {
  final courses = await ref.watch(weekScheduleProvider.future);
  return ScheduleService.getDaysWithCourses(courses);
});

// Upcoming courses (next 24 hours)
final upcomingCoursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  final courses = await ref.watch(weekScheduleProvider.future);
  return ScheduleService.getUpcomingCourses(courses, DateTime.now());
});
