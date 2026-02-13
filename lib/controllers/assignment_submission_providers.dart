import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/assignment_submission_service.dart';

/// Provider pour les soumissions de l'étudiant connecté
final mySubmissionsProvider = FutureProvider<List<AssignmentSubmission>>((ref) async {
  return await AssignmentSubmissionService.getMySubmissions();
});

/// Provider pour une soumission spécifique
final submissionForAssignmentProvider = FutureProvider.family<AssignmentSubmission?, String>((ref, assignmentId) async {
  return await AssignmentSubmissionService.getSubmissionForAssignment(assignmentId);
});

/// Provider pour toutes les soumissions d'un devoir (enseignant)
final assignmentSubmissionsProvider = FutureProvider.family<List<AssignmentSubmission>, String>((ref, assignmentId) async {
  return await AssignmentSubmissionService.getSubmissionsForAssignment(assignmentId);
});

/// Controller pour gérer les actions sur les soumissions
class SubmissionController extends StateNotifier<AsyncValue<void>> {
  SubmissionController() : super(const AsyncValue.data(null));

  /// Soumettre un devoir
  Future<void> submitAssignment({
    required String assignmentId,
    required String fileUrl,
    required String fileName,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AssignmentSubmissionService.submitAssignment(
        assignmentId: assignmentId,
        fileUrl: fileUrl,
        fileName: fileName,
      );
      
      // Invalider les providers pour rafraîchir
      ref.invalidate(mySubmissionsProvider);
      ref.invalidate(submissionForAssignmentProvider(assignmentId));
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Noter une soumission
  Future<void> gradeSubmission({
    required String submissionId,
    required String assignmentId,
    required double score,
    String? feedback,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AssignmentSubmissionService.gradeSubmission(
        submissionId: submissionId,
        score: score,
        feedback: feedback,
      );
      
      // Invalider les providers
      ref.invalidate(assignmentSubmissionsProvider(assignmentId));
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Mettre à jour une soumission
  Future<void> updateSubmission({
    required String submissionId,
    required String assignmentId,
    required String fileUrl,
    required String fileName,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AssignmentSubmissionService.updateSubmission(
        submissionId: submissionId,
        fileUrl: fileUrl,
        fileName: fileName,
      );
      
      // Invalider les providers
      ref.invalidate(mySubmissionsProvider);
      ref.invalidate(submissionForAssignmentProvider(assignmentId));
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final submissionControllerProvider = StateNotifierProvider<SubmissionController, AsyncValue<void>>((ref) {
  return SubmissionController();
});
