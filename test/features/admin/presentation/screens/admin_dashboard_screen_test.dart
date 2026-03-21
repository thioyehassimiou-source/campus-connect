import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:campusconnect/features/admin/data/models/admin_stats_model.dart';
import 'package:campusconnect/features/admin/presentation/providers/admin_stats_provider.dart';
import 'package:campusconnect/features/admin/presentation/providers/admin_activity_provider.dart';
import 'package:campusconnect/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:campusconnect/features/admin/presentation/widgets/admin_activity_feed.dart';

void main() {
  group('Admin Dashboard Screen Tests', () {
    testWidgets('Dashboard displays loading state initially', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AdminDashboardScreen()),
        ),
      );

      // Verify CircularProgressIndicator is shown for stats and logs
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Dashboard displays stats and activity feed when data is loaded', (tester) async {
      // Create mock data
      final mockStats = AdminStatsModel(
        totalStudents: 1500,
        totalTeachers: 120,
        totalAdmins: 5,
        totalCourses: 300,
        totalRooms: 50,
        pendingSchedules: 12,
        totalAnnouncements: 8,
        activeServices: 4,
        usersByRole: {'Student': 1500, 'Teacher': 120, 'Admin': 5},
      );

      // Override providers with mock data
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminStatsProvider.overrideWith((ref) => mockStats),
            adminActivityLogsProvider.overrideWith((ref) => []), // Empty logs for simplicity
          ],
          child: const MaterialApp(home: AdminDashboardScreen()),
        ),
      );

      // Allow the FutureProvider to resolve
      await tester.pumpAndSettle();

      // DUMP APP TO SEE RENDERED TEXT
      debugDumpApp();

      // Verify that the title is displayed
      expect(find.text('Tableau de bord'), findsOneWidget);

      // Verify that the stats cards are populated correctly
      expect(find.text('1500'), findsOneWidget); // Students
      expect(find.text('120'), findsOneWidget); // Teachers
      expect(find.text('300'), findsOneWidget); // Courses
      expect(find.text('50'), findsOneWidget); // Rooms
      expect(find.text('8'), findsOneWidget); // Announcements
      expect(find.text('5'), findsOneWidget); // Admins
      
      // Verify that Quick Actions section is present (it renders independently of stats success/failure)
      expect(find.text('Actions rapides'), findsOneWidget);

      // Verify that Quick Actions section is present
      expect(find.text('Actions rapides'), findsOneWidget);
    });
  });
}
