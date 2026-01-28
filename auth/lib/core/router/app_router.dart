import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/models/app_user.dart';
import '../../features/dashboard/presentation/screens/role_redirect_screen.dart';
import '../../features/dashboard/presentation/screens/student_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/teacher_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../../features/schedule/presentation/screens/student_schedule_screen.dart';
import '../../features/announcements/presentation/screens/announcements_list_screen.dart';
import '../../features/announcements/presentation/screens/announcement_create_screen.dart';
import '../../features/documents/presentation/screens/documents_screen.dart';
import '../../features/documents/presentation/screens/teacher_publish_document_screen.dart';
import '../../features/schedule/presentation/screens/teacher_schedule_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/admin_infrastructure_screen.dart';

String _routeForRole(AuthState authState) {
  final role = authState.user?.role;
  switch (role) {
    case UserRole.enseignant:
      return '/teacher';
    case UserRole.admin:
      return '/admin';
    case UserRole.etudiant:
    default:
      return '/student';
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/redirect',
        name: 'redirect',
        builder: (context, state) => const RoleRedirectScreen(),
      ),
      GoRoute(
        path: '/student',
        name: 'student',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/teacher',
        name: 'teacher',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/student/schedule',
        name: 'student_schedule',
        builder: (context, state) => const StudentScheduleScreen(),
      ),
      GoRoute(
        path: '/announcements',
        name: 'announcements',
        builder: (context, state) => const AnnouncementsListScreen(),
      ),
      GoRoute(
        path: '/announcements/create',
        name: 'announcements_create',
        builder: (context, state) => const AnnouncementCreateScreen(),
      ),
      GoRoute(
        path: '/documents',
        name: 'documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/teacher/publish-document',
        name: 'teacher_publish_document',
        builder: (context, state) => const TeacherPublishDocumentScreen(),
      ),
      GoRoute(
        path: '/teacher/schedule',
        name: 'teacher_schedule',
        builder: (context, state) => const TeacherScheduleScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin_users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/infrastructure',
        name: 'admin_infrastructure',
        builder: (context, state) => const AdminInfrastructureScreen(),
      ),
    ],
    
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.user != null;
      final path = state.uri.path;

      final isAuthRoute = path == '/login' || path == '/register';
      final isProtectedRoute =
          path == '/redirect' ||
          path == '/student' ||
          path == '/teacher' ||
          path == '/admin' ||
          path == '/student/schedule' ||
          path == '/announcements' ||
          path == '/announcements/create' ||
          path == '/documents' ||
          path == '/teacher/publish-document' ||
          path == '/teacher/schedule' ||
          path == '/admin/users' ||
          path == '/admin/infrastructure';

      if (!isAuthenticated && isProtectedRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/redirect';
      }

      if (isAuthenticated && path == '/redirect') {
        return _routeForRole(authState);
      }

      if (isAuthenticated && (path == '/student' || path == '/teacher' || path == '/admin')) {
        final expected = _routeForRole(authState);
        if (path != expected) {
          return expected;
        }
      }

      return null;
    },
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Erreur: ${state.error}'),
      ),
    ),
  );
});
