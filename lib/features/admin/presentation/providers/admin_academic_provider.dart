import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/features/admin/data/services/admin_academic_service.dart';

/// Provider de la liste des filières.
final filieresProvider = FutureProvider<List<FiliereModel>>((ref) async {
  return AdminAcademicService.getFilieres();
});

/// Provider de la liste des cours (avec enseignant associé).
final coursesAdminProvider = FutureProvider<List<CourseAdminModel>>((ref) async {
  return AdminAcademicService.getCourses();
});

/// Provider de la liste des enseignants (utilisé dans les dropdowns).
final teachersListProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  return AdminAcademicService.getTeachersList();
});
