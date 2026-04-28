import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/assignment_service.dart';
import '../shared/models/assignment_model.dart';

/// Provider pour récupérer les devoirs de l'étudiant
final studentAssignmentsProvider = FutureProvider<List<Assignment>>((ref) async {
  return await AssignmentService.getStudentAssignments();
});

/// Provider pour récupérer les devoirs du professeur
final teacherAssignmentsProvider = FutureProvider<List<Assignment>>((ref) async {
  return await AssignmentService.getTeacherAssignments();
});

/// StateNotifier pour gérer les actions sur les devoirs
class AssignmentController extends StateNotifier<AsyncValue<void>> {
  AssignmentController() : super(const AsyncValue.data(null));

  Future<void> createAssignment({
    required String title,
    required String description,
    required DateTime dueDate,
    required String course,
    String priority = 'medium',
    String type = 'Devoir',
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AssignmentService.createAssignment(
        title: title,
        description: description,
        dueDate: dueDate,
        course: course,
        priority: priority,
        type: type,
      );
      ref.invalidate(teacherAssignmentsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitAssignment({
    required String assignmentId,
    required String content,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AssignmentService.submitAssignment(
        assignmentId: assignmentId,
        content: content,
      );
      ref.invalidate(studentAssignmentsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final assignmentControllerProvider = StateNotifierProvider<AssignmentController, AsyncValue<void>>((ref) {
  return AssignmentController();
});
