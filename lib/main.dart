import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:campusconnect/screens/test_supabase_screen.dart';
import 'package:campusconnect/screens/splash_screen.dart';
import 'package:campusconnect/screens/modern_login_screen.dart';
import 'package:campusconnect/screens/modern_student_dashboard.dart';
import 'package:campusconnect/screens/modern_schedule_screen.dart';
import 'package:campusconnect/screens/modern_documents_screen.dart';
import 'package:campusconnect/screens/modern_announcements_screen.dart';
import 'package:campusconnect/screens/modern_profile_screen.dart';
import 'package:campusconnect/screens/modern_services_screen.dart';
import 'package:campusconnect/screens/modern_campus_map_screen.dart';
import 'package:campusconnect/screens/modern_grades_screen.dart';
import 'package:campusconnect/screens/modern_attendance_screen.dart';
import 'package:campusconnect/screens/modern_student_grades_screen.dart';
import 'package:campusconnect/screens/modern_student_attendance_screen.dart';
import 'package:campusconnect/screens/modern_student_messaging_screen.dart';
import 'package:campusconnect/screens/modern_enhanced_announcements_screen.dart';
import 'package:campusconnect/screens/modern_enhanced_schedule_screen.dart';
import 'package:campusconnect/screens/modern_student_profile_screen.dart';
import 'package:campusconnect/screens/modern_course_management_screen.dart';
import 'package:campusconnect/screens/modern_resources_screen.dart';
import 'package:campusconnect/screens/modern_academic_calendar_screen.dart';
import 'package:campusconnect/screens/modern_admin_dashboard.dart';
import 'package:campusconnect/screens/create_profile_screen.dart';
import 'package:campusconnect/screens/test_profile_screen.dart';
import 'package:campusconnect/screens/modern_teacher_dashboard.dart';

import 'package:campusconnect/core/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation Supabase
  await Supabase.initialize(
    url: 'https://oecmtlkkklpbzhlajysz.supabase.co',
    anonKey: 'sb_publishable_vlC5kvt8eBqQLuCDhM_1FQ_c9BvqTX6',
    debug: true,
  );

  // Initialisation du service de thème
  final themeService = ThemeService();
  await themeService.init();
  
  runApp(const CampusConnectApp());
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'CampusConnect',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          // Thème Clair (Design Actuel)
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: const Color(0xFF2563EB),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            cardColor: Colors.white,
            fontFamily: 'Lexend',
            useMaterial3: true,
            iconTheme: const IconThemeData(
              color: Color(0xFF64748B),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF0F172A)), // Primary Text
              bodyMedium: TextStyle(color: Color(0xFF64748B)), // Secondary Text
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF64748B)),
              titleTextStyle: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lexend',
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.transparent,
              selectedItemColor: Color(0xFF2563EB),
              unselectedItemColor: Color(0xFF64748B),
            ),
          ),
          // Thème Sombre (Nouveau Design Premium)
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: const Color(0xFF3B82F6), // Bleu plus clair pour le contraste
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
            cardColor: const Color(0xFF1E293B), // Slate 800
            fontFamily: 'Lexend',
            useMaterial3: true,
            iconTheme: const IconThemeData(
              color: Color(0xFF94A3B8), // Slate 400
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFFF8FAFC)), // Slate 50
              bodyMedium: TextStyle(color: Color(0xFF94A3B8)), // Slate 400
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF94A3B8)),
              titleTextStyle: TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lexend',
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.transparent,
              selectedItemColor: Color(0xFF3B82F6), // Bleu plus vif
              unselectedItemColor: Color(0xFF64748B),
            ),
          ),
          initialRoute: '/splash',
          routes: {
            '/test': (context) => const TestSupabaseScreen(),
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const ModernLoginScreen(),
            '/student-dashboard': (context) => const ModernStudentDashboard(),
            '/schedule': (context) => const ModernScheduleScreen(),
            '/documents': (context) => const ModernDocumentsScreen(),
            '/news': (context) => const ModernAnnouncementsScreen(),
            '/profile': (context) => const ModernProfileScreen(),
            '/services': (context) => const ModernServicesScreen(),
            '/campus-map': (context) => const ModernCampusMapScreen(),
            '/grades': (context) => const ModernGradesScreen(),
            '/attendance': (context) => const ModernAttendanceScreen(),
            '/student-grades': (context) => const ModernStudentGradesScreen(),
            '/student-attendance': (context) => const ModernStudentAttendanceScreen(),
            '/student-messaging': (context) => const ModernStudentMessagingScreen(),
            '/enhanced-announcements': (context) => const ModernEnhancedAnnouncementsScreen(),
            '/enhanced-schedule': (context) => const ModernEnhancedScheduleScreen(),
            '/student-profile-enhanced': (context) => const ModernStudentProfileScreen(),
            '/course-management': (context) => const ModernCourseManagementScreen(),
            '/resources': (context) => const ModernResourcesScreen(),
            '/academic-calendar': (context) => const ModernAcademicCalendarScreen(),
            '/admin-dashboard': (context) => const ModernAdminDashboard(),
            '/teacher-dashboard': (context) => const ModernTeacherDashboard(),
            '/test-profile': (context) => const TestProfileScreen(),
            '/create-profile': (context) => const CreateProfileScreen(),
          },
        );
      },
    );
  }
}