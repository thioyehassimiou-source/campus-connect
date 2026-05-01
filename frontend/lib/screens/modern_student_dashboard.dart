import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/controllers/schedule_providers.dart';
import 'package:campusconnect/core/services/schedule_service.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/screens/modern_enhanced_announcements_screen.dart';
import 'package:campusconnect/screens/modern_enhanced_schedule_screen.dart';
import 'package:campusconnect/screens/modern_student_profile_screen.dart';
import 'package:campusconnect/screens/modern_services_screen.dart';
import 'package:campusconnect/core/services/profile_service.dart';
import 'package:campusconnect/core/services/theme_service.dart';
import 'package:campusconnect/core/services/announcement_service.dart';
import 'package:campusconnect/controllers/announcement_providers.dart';
import 'package:campusconnect/controllers/grade_providers.dart';
import 'package:campusconnect/controllers/attendance_providers.dart';
import 'package:campusconnect/widgets/theme_toggle_button.dart';
import 'package:campusconnect/controllers/profile_providers.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:campusconnect/controllers/notification_providers.dart';

class ModernStudentDashboard extends StatefulWidget {
  const ModernStudentDashboard({super.key});

  @override
  State<ModernStudentDashboard> createState() => _ModernStudentDashboardState();
}

class _ModernStudentDashboardState extends State<ModernStudentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardHome(),
    const ModernEnhancedAnnouncementsScreen(),
    const ModernEnhancedScheduleScreen(),
    const ModernServicesScreen(),
    const ModernStudentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0 
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/ai-assistant'),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.psychology, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign),
              label: 'Annonces',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Emploi du temps',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apps_outlined),
              activeIcon: Icon(Icons.apps),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHome extends ConsumerStatefulWidget {
  const DashboardHome({super.key});

  @override
  ConsumerState<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends ConsumerState<DashboardHome> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now);
    final dayName = _getDayName(now.weekday);
    final scheduleAsync = ref.watch(validatedScheduleProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        final fullName = profile?['nom'] ?? 'Étudiant';
        final roleStr = profile?['role']?.toString().toUpperCase() ?? 'ETUDIANT';
        final roleLabel = roleStr == 'ETUDIANT' ? 'Étudiant' : roleStr;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(validatedScheduleProvider);
              ref.invalidate(userProfileProvider);
              ref.invalidate(allAnnouncementsProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildPremiumHeader(context, fullName, roleLabel, greeting),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cartes de statistiques (Glassmorphism)
                        _buildPremiumStatsSection(context, ref),
                        
                        const SizedBox(height: 32),
                        
                        // Emploi du temps du jour
                        Text(
                          'Aujourd\'hui',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 16),
                        scheduleAsync.when(
                          data: (items) {
                            final todayItems = items.where((item) => 
                              item.startTime.day == now.day && 
                              item.startTime.month == now.month && 
                              item.startTime.year == now.year
                            ).toList();
                            return _buildPremiumScheduleCard(context, dayName, todayItems);
                          },
                          loading: () => const Center(child: LinearProgressIndicator()),
                          error: (e, st) => const Text('Erreur chargement planning'),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Accès rapide (iOS Style)
                        _buildPremiumQuickAccess(context),
                        
                        const SizedBox(height: 32),
                        
                        // Dernières annonces
                        _buildLatestAnnouncementsCard(context, ref),
                        
                        const SizedBox(height: 100), // Espace pour le FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Erreur profil: $e'))),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, String name, String role, String greeting) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: theme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Gradient & Pattern
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                    ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                    : [theme.primaryColor, const Color(0xFF818CF8)],
                ),
              ),
            ),
            // Subtles shapes for depth
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            // Header Content
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const ThemeToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$greeting,',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatsSection(BuildContext context, WidgetRef ref) {
    final averageAsync = ref.watch(studentAverageProvider);
    final attendanceAsync = ref.watch(studentAttendanceRateProvider);

    return Row(
      children: [
        Expanded(
          child: averageAsync.when(
            data: (avg) => _buildPremiumStatCard(
              context,
              'Moyenne',
              '${avg.toStringAsFixed(1)}',
              Icons.auto_graph_rounded,
              const Color(0xFF6366F1),
            ),
            loading: () => _buildPremiumStatCard(context, 'Moyenne', '--', Icons.auto_graph_rounded, Colors.grey),
            error: (_, __) => _buildPremiumStatCard(context, 'Moyenne', 'N/A', Icons.auto_graph_rounded, Colors.red),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: attendanceAsync.when(
            data: (rate) => _buildPremiumStatCard(
              context,
              'Présence',
              '${rate.toStringAsFixed(0)}%',
              Icons.verified_user_rounded,
              const Color(0xFF10B981),
            ),
            loading: () => _buildPremiumStatCard(context, 'Présence', '--', Icons.verified_user_rounded, Colors.grey),
            error: (_, __) => _buildPremiumStatCard(context, 'Présence', 'N/A', Icons.verified_user_rounded, Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumScheduleCard(BuildContext context, String day, List<ScheduleItem> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          if (items.isEmpty)
            _buildEmptyState(context, 'Aucun cours prévu aujourd\'hui', Icons.event_available_rounded)
          else
            ...items.take(3).map((item) => _buildPremiumScheduleItem(context, item)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/schedule'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Voir tout le planning', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 16, color: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumScheduleItem(BuildContext context, ScheduleItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 50,
            child: Column(
              children: [
                Text(
                  DateFormat('HH:mm').format(item.startTime),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Container(
                  height: 20,
                  width: 2,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.subject,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          'Salle ${item.room}',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _buildTypeTag(context, item.type),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTag(BuildContext context, String type) {
    Color color = Theme.of(context).primaryColor;
    if (type == 'TP') color = const Color(0xFF10B981);
    if (type == 'Exam') color = const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPremiumQuickAccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _buildQuickAction(context, 'Notes', Icons.auto_awesome_rounded, const Color(0xFF8B5CF6), '/student-grades'),
            _buildQuickAction(context, 'Examens', Icons.assignment_rounded, const Color(0xFFF59E0B), '/assignments'),
            _buildQuickAction(context, 'Cartes', Icons.map_rounded, const Color(0xFF10B981), '/campus-map'),
            _buildQuickAction(context, 'Chat', Icons.chat_bubble_rounded, const Color(0xFF0EA5E9), '/messages'),
            _buildQuickAction(context, 'Cours', Icons.book_rounded, const Color(0xFF6366F1), '/resources'),
            _buildQuickAction(context, 'Présence', Icons.fingerprint_rounded, const Color(0xFFEC4899), '/student-attendance'),
            _buildQuickAction(context, 'Agenda', Icons.event_rounded, const Color(0xFFF97316), '/schedule'),
            _buildQuickAction(context, 'Plus', Icons.more_horiz_rounded, const Color(0xFF64748B), '/services'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18), // iOS Squircle style
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: Colors.grey.withValues(alpha: 0.3), size: 48),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String subject, String time, String room, String type) {
    Color typeColor;
    switch (type) {
      case 'CM':
        typeColor = Theme.of(context).primaryColor;
        break;
      case 'TD':
        typeColor = Color(0xFF10B981);
        break;
      case 'TP':
        typeColor = Color(0xFFF59E0B);
        break;
      default:
        typeColor = Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$time • $room',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: typeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestAnnouncementsCard(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(allAnnouncementsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.campaign_outlined,
                  color: Theme.of(context).colorScheme.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dernières annonces',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      'Informations importantes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/news');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          announcementsAsync.when(
            data: (announcements) {
              if (announcements.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Aucune annonce pour le moment',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ),
                );
              }
              // Affichage des 2 dernières annonces
              final latest = announcements.take(2).toList();
              return Column(
                children: latest.map((a) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAnnouncementItem(
                      a.title,
                      a.content,
                      a.category,
                      _getCategoryColor(context, a.category),
                      a.timeAgo,
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Erreur: $e'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(BuildContext context, String category) {
    switch (category) {
      case 'Urgent': return Theme.of(context).colorScheme.error;
      case 'Examens': return const Color(0xFFF59E0B);
      case 'Cours': return Theme.of(context).primaryColor;
      default: return Theme.of(context).primaryColor;
    }
  }

  Widget _buildAnnouncementItem(String title, String description, String priority, Color priorityColor, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priorityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: priorityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accès rapide',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                context,
                'Emploi du temps',
                Icons.calendar_today_outlined,
                Color(0xFF2563EB),
                '/schedule',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                context,
                'Documents',
                Icons.folder_outlined,
                Color(0xFF10B981),
                '/documents',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                context,
                'Notes',
                Icons.grain_outlined,
                const Color(0xFFF59E0B),
                '/student-grades',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                context,
                'Devoirs',
                Icons.assignment_outlined,
                const Color(0xFF6366F1),
                '/assignments',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                context,
                'Présence',
                Icons.check_circle_outline,
                const Color(0xFF10B981),
                '/student-attendance',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                context,
                'Messagerie',
                Icons.forum,
                const Color(0xFF25D366),
                '/messages',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String _getDayName(int weekday) {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[weekday - 1];
  }
}
