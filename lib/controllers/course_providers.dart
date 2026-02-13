import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/academic_service.dart';

/// Provider pour récupérer les cours de l'enseignant connecté
final teacherCoursesProvider = FutureProvider<List<Course>>((ref) async {
  return await AcademicService.getTeacherCourses();
});

/// StateNotifier pour gérer les actions sur les cours
class CourseController extends StateNotifier<AsyncValue<void>> {
  CourseController() : super(const AsyncValue.data(null));

  Future<void> createCourse({
    required String title,
    required String level,
    required String color,
    String? description,
    String scope = 'license',
    String? departmentId,
    String? facultyId,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AcademicService.createCourse(
        title: title,
        level: level,
        color: color,
        description: description,
        scope: scope,
        departmentId: departmentId,
        facultyId: facultyId,
      );
      ref.invalidate(teacherCoursesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCourse({
    required String id,
    required String title,
    required String level,
    required String color,
    String? description,
    String? status,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AcademicService.updateCourse(
        id: id,
        title: title,
        level: level,
        color: color,
        description: description,
        status: status,
      );
      ref.invalidate(teacherCoursesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCourse(String id, {required WidgetRef ref}) async {
    state = const AsyncValue.loading();
    try {
      await AcademicService.deleteCourse(id);
      ref.invalidate(teacherCoursesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final courseControllerProvider = StateNotifierProvider<CourseController, AsyncValue<void>>((ref) {
  return CourseController();
});
