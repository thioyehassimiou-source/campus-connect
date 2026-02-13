import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/grade_service.dart';

/// Provider pour récupérer les notes de l'étudiant connecté
final studentGradesProvider = FutureProvider<List<Grade>>((ref) async {
  return await GradeService.getMyGrades();
});

/// Provider pour calculer la moyenne générale de l'étudiant
final studentAverageProvider = FutureProvider<double>((ref) async {
  final grades = await ref.watch(studentGradesProvider.future);
  if (grades.isEmpty) return 0.0;
  
  double totalWeighted = 0;
  double totalCoeff = 0;
  for (final grade in grades) {
    totalWeighted += grade.value * grade.coefficient;
    totalCoeff += grade.coefficient;
  }
  
  return totalCoeff > 0 ? (totalWeighted / totalCoeff) : 0.0;
});

/// Provider pour récupérer les notes données par l'enseignant connecté
final teacherGradesProvider = FutureProvider<List<Grade>>((ref) async {
  return await GradeService.getTeacherGrades();
});

/// StateNotifier pour gérer les actions sur les notes
class GradeController extends StateNotifier<AsyncValue<void>> {
  GradeController() : super(const AsyncValue.data(null));

  Future<void> addGrade({
    required String studentId,
    required String subject,
    required double value,
    required double coefficient,
    required String type,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await GradeService.addGrade(
        studentId: studentId,
        subject: subject,
        value: value,
        coefficient: coefficient,
        type: type,
      );
      ref.invalidate(teacherGradesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final gradeControllerProvider = StateNotifierProvider<GradeController, AsyncValue<void>>((ref) {
  return GradeController();
});
