import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/core/services/supabase_service.dart';

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
import 'package:campusconnect/screens/test_profile_screen.dart';
import 'package:campusconnect/screens/modern_teacher_dashboard.dart';
import 'package:campusconnect/screens/ai_assistant_screen.dart';
import 'package:campusconnect/screens/messages_screen.dart';
import 'package:campusconnect/screens/modern_rooms_screen.dart';
import 'package:campusconnect/screens/modern_assignments_screen.dart';
import 'package:campusconnect/screens/modern_notifications_screen.dart';
import 'package:campusconnect/messaging/screens/messaging_list_screen.dart';
import 'package:campusconnect/shared/models/user_model.dart';

import 'package:campusconnect/core/services/theme_service.dart';
import 'package:campusconnect/core/theme/app_theme.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation Supabase via le service centralisé
  await SupabaseService.initialize();

  // Initialisation du formatage de date pour le français
  await initializeDateFormatting('fr_FR', null);

  // Initialisation du service de thème
  final themeService = ThemeService();
  await themeService.init();
  
  runApp(
    const ProviderScope(
      child: CampusConnectApp(),
    ),
  );
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
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr', 'FR'),
          ],
          locale: const Locale('fr', 'FR'),
          initialRoute: '/splash',
          routes: {
            '/test': (context) => const TestSupabaseScreen(),
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const ModernLoginScreen(),
            '/student-dashboard': (context) => const ModernStudentDashboard(),
            '/schedule': (context) => const ModernScheduleScreen(),
            '/documents': (context) => const ModernDocumentsScreen(),
            '/news': (context) => const ModernEnhancedAnnouncementsScreen(),
            '/profile': (context) => const ModernProfileScreen(),
            '/services': (context) => const ModernServicesScreen(),
            '/campus-map': (context) => const ModernCampusMapScreen(),
            '/grades': (context) => const ModernGradesScreen(),
            '/attendance': (context) => const ModernAttendanceScreen(),
            '/student-grades': (context) => const ModernStudentGradesScreen(),
            '/student-attendance': (context) => const ModernStudentAttendanceScreen(),
            '/student-messaging': (context) => const ModernStudentMessagingScreen(),
            '/messages': (context) => const MessagingListScreen(),
            '/enhanced-announcements': (context) => const ModernEnhancedAnnouncementsScreen(),
            '/enhanced-schedule': (context) => const ModernEnhancedScheduleScreen(),
            '/student-profile-enhanced': (context) => const ModernStudentProfileScreen(),
            '/course-management': (context) => const ModernCourseManagementScreen(),
            '/resources': (context) => const ModernResourcesScreen(),
            '/academic-calendar': (context) => const ModernAcademicCalendarScreen(),
            '/admin-dashboard': (context) => const ModernAdminDashboard(),
            '/teacher-dashboard': (context) => const ModernTeacherDashboard(),
            '/test-profile': (context) => const TestProfileScreen(),
            '/ai-assistant': (context) => const AIAssistantScreen(),
            '/admin-rooms': (context) => const ModernRoomsScreen(),
            '/assignments': (context) {
              final currentUser = Supabase.instance.client.auth.currentUser;
              final metadata = currentUser?.userMetadata ?? {};
              final isTeacher = metadata['role'] == 'Enseignant';
              return ModernAssignmentsScreen(isTeacher: isTeacher);
            },
            '/notifications': (context) => const ModernNotificationsScreen(),
          },
        );
      },
    );
  }
}