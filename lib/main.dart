import 'package:flutter/material.dart';
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
import 'package:campusconnect/screens/modern_teacher_dashboard.dart';

void main() {
  runApp(const CampusConnectApp());
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Lexend',
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
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
      },
    );
  }
}