import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/auth/presentation/login_screen.dart';
import 'package:campusconnect/features/auth/presentation/register_screen.dart';

import 'package:campusconnect/features/home/presentation/student_dashboard.dart';
import 'package:campusconnect/features/home/presentation/teacher_dashboard.dart';
import 'package:campusconnect/features/home/presentation/admin_dashboard.dart';
import 'package:campusconnect/features/auth/domain/user_model.dart';

import 'package:campusconnect/features/academic/presentation/schedule_screen.dart';
import 'package:campusconnect/features/academic/presentation/documents_screen.dart';
import 'package:campusconnect/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:campusconnect/messaging/screens/messaging_list_screen.dart';
import 'package:campusconnect/features/documents/presentation/screens/documents_screen.dart' as new_docs;
import 'package:campusconnect/features/documents/presentation/screens/upload_document_screen.dart';
import 'package:campusconnect/features/communication/presentation/announcements_screen.dart';
import 'package:campusconnect/features/communication/presentation/create_announcement_screen.dart';
import 'package:campusconnect/features/auth/presentation/profile_screen.dart';
import 'package:campusconnect/features/academic/presentation/grades_screen.dart';
import 'package:campusconnect/screens/services_screen.dart';
import 'package:campusconnect/features/campus/presentation/campus_map_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userProfile = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value?.session != null;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      // 1. Unauthenticated flow
      if (!isLoggedIn) {
        if (isLoggingIn || isRegistering) return null;
        return '/login';
      }

      // 2. Profile loading flow
      if (userProfile.isLoading) return null; // Wait for profile

      final user = userProfile.value;
      if (user == null && isLoggedIn && !isLoggingIn && !isRegistering) {
        return null; 
      }

      // 3. Authenticated & Profile Loaded flow
      if (isLoggedIn && (isLoggingIn || isRegistering || state.uri.toString() == '/')) {
        if (user == null) return null;
        
        switch (user.role) {
          case UserRole.etudiant: return '/student';
          case UserRole.enseignant: return '/teacher';
          case UserRole.administrateur: return '/admin';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      // Student Features
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/announcements',
        builder: (context, state) => const AnnouncementsScreen(),
      ),
      GoRoute(
        path: '/announcements/create',
        builder: (context, state) => const CreateAnnouncementScreen(),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/grades',
        builder: (context, state) => const GradesScreen(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const CampusMapScreen(),
      ),
      // Messages
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagingListScreen(),
      ),
      // Notifications
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      // New Documents
      GoRoute(
        path: '/documents-new',
        builder: (context, state) => const new_docs.DocumentsScreen(),
      ),
      GoRoute(
        path: '/documents/upload',
        builder: (context, state) => const UploadDocumentScreen(),
      ),
    ],
  );
});
