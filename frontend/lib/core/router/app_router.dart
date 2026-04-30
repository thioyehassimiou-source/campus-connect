import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/controllers/auth_providers.dart';
import 'package:campusconnect/controllers/profile_providers.dart';
import 'package:campusconnect/screens/modern_login_screen.dart';
import 'package:campusconnect/screens/modern_register_screen.dart';

import 'package:campusconnect/screens/modern_student_dashboard.dart';
import 'package:campusconnect/screens/modern_teacher_dashboard.dart';
import 'package:campusconnect/screens/modern_admin_dashboard.dart';
import 'package:campusconnect/models/user_model.dart';

import 'package:campusconnect/screens/modern_schedule_screen.dart';
import 'package:campusconnect/screens/modern_resources_screen.dart';
import 'package:campusconnect/screens/modern_notifications_screen.dart';
import 'package:campusconnect/messaging/screens/messaging_list_screen.dart';
import 'package:campusconnect/screens/modern_announcements_screen.dart';
import 'package:campusconnect/screens/modern_profile_screen.dart';
import 'package:campusconnect/screens/modern_grades_screen.dart';
import 'package:campusconnect/screens/modern_services_screen.dart';
import 'package:campusconnect/screens/modern_campus_map_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userProfile = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      // 1. Unauthenticated flow
      if (!isLoggedIn) {
        if (isLoggingIn || isRegistering) return null;
        return '/login';
      }

      // 2. Profile loading flow
      if (userProfile.isLoading) return null; // Wait for profile

      final userMap = userProfile.value;
      if (userMap == null && isLoggedIn && !isLoggingIn && !isRegistering) {
        return null; 
      }

      // 3. Authenticated & Profile Loaded flow
      if (isLoggedIn && (isLoggingIn || isRegistering || state.uri.toString() == '/')) {
        if (userMap == null) return null;
        
        final role = userMap['role'] as String?;
        if (role == 'etudiant') return '/student';
        if (role == 'enseignant') return '/teacher';
        if (role == 'administrateur') return '/admin';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const ModernLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const ModernRegisterScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const ModernStudentDashboard(),
      ),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const ModernTeacherDashboard(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const ModernAdminDashboard(),
      ),
      // Student Features
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ModernScheduleScreen(),
      ),
      GoRoute(
        path: '/announcements',
        builder: (context, state) => const ModernAnnouncementsScreen(),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const ModernResourcesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ModernProfileScreen(),
      ),
      GoRoute(
        path: '/grades',
        builder: (context, state) => const ModernGradesScreen(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ModernServicesScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const ModernCampusMapScreen(),
      ),
      // Messages
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagingListScreen(),
      ),
      // Notifications
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const ModernNotificationsScreen(),
      ),
    ],
  );
});
