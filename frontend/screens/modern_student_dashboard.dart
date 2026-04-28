import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
              color: Colors.black.withOpacity(0.1),
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Transform.scale(
                    scale: 1.35,
                    child: Image.asset(
                      'assets/logo/app_logo.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $roleLabel',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  fullName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ThemeToggleButton(),
                    Consumer(
                      builder: (context, ref, child) {
                        final unreadCount = ref.watch(unreadNotificationsCountProvider);
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/notifications'),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(validatedScheduleProvider);
              ref.invalidate(userProfileProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte Emploi du temps du jour
                  scheduleAsync.when(
                    data: (items) {
                      final todayItems = items.where((item) => 
                        item.startTime.day == now.day && 
                        item.startTime.month == now.month && 
                        item.startTime.year == now.year
                      ).toList();
                      return _buildTodayScheduleCard(context, dayName, todayItems);
                    },
                    loading: () => const Center(child: LinearProgressIndicator()),
                    error: (e, st) => _buildTodayScheduleCard(context, dayName, []),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Carte Dernières annonces
                  _buildLatestAnnouncementsCard(context, ref),
                  
                  const SizedBox(height: 24),
                  
                  // Accès rapide
                  _buildQuickAccessSection(context),
                  
                  const SizedBox(height: 24),
                  
                  // Cartes additionnelles - Dynamiques
                  _buildStatsCards(context, ref),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Erreur profil: $e'))),
    );
  }

  Widget _buildStatsCards(BuildContext context, WidgetRef ref) {
    final averageAsync = ref.watch(studentAverageProvider);
    final attendanceAsync = ref.watch(studentAttendanceRateProvider);

    return Row(
      children: [
        Expanded(
          child: averageAsync.when(
            data: (avg) => _buildInfoCard(
              'Notes',
              '${avg.toStringAsFixed(1)}/20',
              'Moyenne générale',
              const Color(0xFF10B981),
              Icons.trending_up,
            ),
            loading: () => _buildInfoCard(
              'Notes',
              '...',
              'Moyenne générale',
              const Color(0xFF10B981),
              Icons.trending_up,
            ),
            error: (_, __) => _buildInfoCard(
              'Notes',
              '--',
              'Moyenne générale',
              const Color(0xFF10B981),
              Icons.trending_up,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: attendanceAsync.when(
            data: (rate) => _buildInfoCard(
              'Présence',
              '${rate.toStringAsFixed(0)}%',
              'Ce semestre',
              const Color(0xFFF59E0B),
              Icons.check_circle,
            ),
            loading: () => _buildInfoCard(
              'Présence',
              '...',
              'Ce semestre',
              const Color(0xFFF59E0B),
              Icons.check_circle,
            ),
            error: (_, __) => _buildInfoCard(
              'Présence',
              '--',
              'Ce semestre',
              const Color(0xFFF59E0B),
              Icons.check_circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayScheduleCard(BuildContext context, String dayName, List<ScheduleItem> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emploi du temps du jour',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      dayName,
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
                  // Accéder à l'onglet Emploi du temps (index 2 dans le dashboard)
                  // Ce n'est pas idéal ici car on change le state du parent
                  // Mais Navigator.pushNamed('/schedule') marche si défini
                  Navigator.pushNamed(context, '/schedule');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('Aucun cours aujourd\'hui', style: TextStyle(fontStyle: FontStyle.italic))
          else
            ...items.take(3).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildScheduleItem(
                item.subject, 
                '${DateFormat('HH:mm').format(item.startTime)} - ${DateFormat('HH:mm').format(item.endTime)}', 
                item.room, 
                item.type
              ),
            )),
        ],
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
              color: typeColor.withOpacity(0.1),
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
            color: Colors.black.withOpacity(0.05),
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
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
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
                        color: priorityColor.withOpacity(0.1),
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
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
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
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
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
                color: color.withOpacity(0.1),
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
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
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
                  color: color.withOpacity(0.1),
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
