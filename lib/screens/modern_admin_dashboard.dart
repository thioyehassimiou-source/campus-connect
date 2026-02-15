import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/screens/modern_enhanced_announcements_screen.dart';
import 'package:campusconnect/screens/modern_enhanced_schedule_screen.dart';
import 'package:campusconnect/screens/modern_academic_calendar_screen.dart';
import 'package:campusconnect/screens/modern_course_management_screen.dart';
import 'package:campusconnect/screens/modern_resources_screen.dart';
import 'package:campusconnect/widgets/theme_toggle_button.dart';
import 'package:campusconnect/controllers/admin_providers.dart';
import 'package:campusconnect/core/services/admin_service.dart';
import 'package:campusconnect/core/services/room_service.dart';
import 'package:campusconnect/controllers/announcement_providers.dart';
import 'package:campusconnect/core/services/announcement_service.dart';
import 'package:campusconnect/controllers/auth_providers.dart';
import 'package:campusconnect/controllers/profile_providers.dart';
import 'package:campusconnect/core/services/campus_service.dart';
import 'package:campusconnect/models/institutional_service.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusconnect/screens/modern_student_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/core/services/theme_service.dart';

class ModernAdminDashboard extends StatefulWidget {
  const ModernAdminDashboard({super.key});

  @override
  State<ModernAdminDashboard> createState() => _ModernAdminDashboardState();
}

class _ModernAdminDashboardState extends State<ModernAdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardHome(),
    const ModernEnhancedAnnouncementsScreen(isAdmin: true),
    const ModernAcademicCalendarScreen(),
    const ModernCourseManagementScreen(),
    const ModernResourcesScreen(),
    const AdminSettingsTab(),
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
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Tableau',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign),
              label: 'Annonces',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Calendrier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Cours',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Ressources',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboardHome extends ConsumerStatefulWidget {
  const AdminDashboardHome({super.key});

  @override
  ConsumerState<AdminDashboardHome> createState() => _AdminDashboardHomeState();
}

class _AdminDashboardHomeState extends ConsumerState<AdminDashboardHome> {

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);
    final usersAsync = ref.watch(allUsersProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        final roleStr = profile?['role']?.toString().toUpperCase() ?? 'ETUDIANT';
        final isSuperAdmin = roleStr == 'SUPER_ADMIN';
        final isServiceAdmin = roleStr == 'ADMIN_SERVICE';
        final serviceType = profile?['service_type']?.toString().toUpperCase();
        
        String roleLabel = 'Administrateur';
        if (isSuperAdmin) roleLabel = 'Super Administrateur';
        if (isServiceAdmin) {
          roleLabel = 'Admin ${serviceType ?? 'Service'}';
        }

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
                  color: isSuperAdmin ? Colors.red.shade700 : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSuperAdmin ? Icons.security : Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panneau d\'administration',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  roleLabel,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            actions: [
              const ThemeToggleButton(),
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminStatsProvider);
              ref.invalidate(allUsersProvider);
              ref.invalidate(userProfileProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistiques générales
                  statsAsync.when(
                    data: (stats) => _buildStatsOverview(stats),
                    loading: () => const Center(child: LinearProgressIndicator()),
                    error: (e, st) => Text('Erreur stats: $e'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Gestion des utilisateurs (SUPER_ADMIN uniquement)
                  if (isSuperAdmin) ...[
                    usersAsync.when(
                      data: (users) => _buildUserManagement(context, users),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text('Erreur utilisateurs: $e'),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Gestion des annonces (SUPER_ADMIN ou Service COMMUNICATION)
                  if (isSuperAdmin || (isServiceAdmin && serviceType == 'COMMUNICATION')) ...[
                    Consumer(
                      builder: (context, ref, child) {
                        final announcementsAsync = ref.watch(allAnnouncementsProvider);
                        return announcementsAsync.when(
                          data: (announcements) => _buildAnnouncementManagement(context, announcements),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, st) => Text('Erreur annonces: $e'),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Gestion des blocs et salles (SUPER_ADMIN ou Service SALLES)
                  if (isSuperAdmin || (isServiceAdmin && serviceType == 'SALLES')) ...[
                    _buildRoomManagement(context),
                    const SizedBox(height: 24),
                  ],
                  
                  // Supervision des services (SUPER_ADMIN uniquement ou Service SCOLARITE)
                  if (isSuperAdmin || (isServiceAdmin && serviceType == 'SCOLARITE')) ...[
                    _buildServiceSupervision(context),
                  ],
                  
                  if (isServiceAdmin && serviceType == 'DEPARTEMENT') ...[
                    _buildDepartmentManagementPreview(context),
                  ],
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

  Widget _buildDepartmentManagementPreview(BuildContext context) {
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
              Icon(Icons.school, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Gestion du Département',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Accès rapide aux outils de gestion du département.'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/schedule'),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('Emploi du temps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to course management tab (index 3)
                    // Since we can't easily switch tabs from here without passing a controller, 
                    // we'll push the screen directly or use a named route if available.
                    // Assuming no named route for just the tab, we'll keep it simple for now or better, 
                    // check if we can simulate tab switch.
                    // For now let's just push the CourseManagementScreen if possible, or leave as future improvement.
                    // Actually, let's just link to the generic schedule for now as primary action.
                    // Or add a secondary button for "Classes".
                  }, 
                  icon: const Icon(Icons.class_outlined, size: 16),
                  label: const Text('Cours'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(AdminStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Utilisateurs', stats.totalUsers.toString(), 'Total', const Color(0xFF2563EB), Icons.people),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Annonces', stats.totalAnnouncements.toString(), 'Ce mois', const Color(0xFF10B981), Icons.campaign),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Salles', stats.totalRooms.toString(), 'Disponibles', const Color(0xFFF59E0B), Icons.meeting_room),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Services', stats.activeServices.toString(), 'Actifs', const Color(0xFF8B5CF6), Icons.settings),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color, IconData icon) {
    // Determine if this card should be clickable (specifically for Services)
    final isServicesCard = title == 'Services';
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isServicesCard 
            ? () => Navigator.pushNamed(context, '/services')
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserManagement(BuildContext context, List<Map<String, dynamic>> users) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(
                Icons.people,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gestion des utilisateurs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddUserDialog(context);
                },
                icon: const Icon(Icons.add, size: 16),
                label: Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 700),
                child: SingleChildScrollView(
                  child: _buildUserTable(700, users),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable(double totalWidth, List<Map<String, dynamic>> users) {
    double colName = totalWidth * 0.25;
    double colEmail = totalWidth * 0.35;
    double colRole = totalWidth * 0.15;
    double colStatus = totalWidth * 0.15;
    double colActions = totalWidth * 0.1;

    return Column(
      children: [
        // En-tête du tableau
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(width: colName, child: Text('Nom', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
              SizedBox(width: colEmail, child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
              SizedBox(width: colRole, child: Text('Rôle', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
              SizedBox(width: colStatus, child: Text('Statut', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
              SizedBox(width: colActions, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Lignes du tableau
        if (users.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: Text('Aucun utilisateur trouvé')),
          )
        else
          ...users.map((user) => _buildUserRow(
                user['nom'] ?? 'Inconnu',
                user['email'] ?? '-',
                user['role'] ?? 'Étudiant',
                'Actif', // Statut par défaut car non présent dans profile par défaut
                true,
                totalWidth,
                user['id'],
              )),
      ],
    );
  }

  Widget _buildUserRow(String name, String email, String role, String status, bool isActive, double totalWidth, String userId) {
    double colName = totalWidth * 0.25;
    double colEmail = totalWidth * 0.35;
    double colRole = totalWidth * 0.15;
    double colStatus = totalWidth * 0.15;
    double colActions = totalWidth * 0.1;
    Color statusColor = isActive ? const Color(0xFF10B981) : Theme.of(context).colorScheme.error;
    Color roleColor = role == 'Admin' ? Theme.of(context).colorScheme.error : 
                     role == 'Enseignant' ? Theme.of(context).primaryColor : 
                     const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(width: colName, child: Text(name, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
          SizedBox(width: colEmail, child: Text(email, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
          SizedBox(width: colRole, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(role, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: roleColor), textAlign: TextAlign.center),
          )),
          SizedBox(width: colStatus, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor), textAlign: TextAlign.center),
          )),
          SizedBox(width: colActions, child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 16, color: Color(0xFF2563EB)),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 16, color: Color(0xFFEF4444)),
                onPressed: () => _confirmDeleteUser(userId),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          )),
        ],
      ),
    );
  }


  Widget _buildAnnouncementManagement(BuildContext context, List<Announcement> announcements) {
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
              const Icon(
                Icons.campaign,
                color: Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Annonces officielles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  _showCreateAnnouncementDialog(context);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nouvelle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnnouncementList(announcements.take(3).toList()),
        ],
      ),
    );
  }

  Widget _buildAnnouncementList(List<Announcement> announcements) {
    if (announcements.isEmpty) {
      return const Center(child: Text('Aucune annonce récente'));
    }
    return Column(
      children: announcements.map((a) => _buildAnnouncementItem(
        a.title, 
        a.content, 
        a.category, 
        _getCategoryColor(a.category), 
        a.timeAgo
      )).toList(),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'urgent': return const Color(0xFFEF4444);
      case 'important': return const Color(0xFFF59E0B);
      case 'information': return const Color(0xFF2563EB);
      default: return const Color(0xFF10B981);
    }
  }

  Widget _buildAnnouncementItem(String title, String description, String priority, Color priorityColor, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(2),
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
                          fontSize: 13,
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
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
            onSelected: (value) {
              // Gérer les actions
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Text('Modifier', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Color(0xFFEF4444)),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomManagement(BuildContext context) {
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
              Icon(
                Icons.meeting_room,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gestion des blocs et salles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin-rooms');
                },
                icon: Icon(Icons.settings, size: 16),
                label: Text('Gérer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRoomGrid(ref),
        ],
      ),
    );
  }

  Widget _buildRoomGrid(WidgetRef ref) {
    final roomStatsAsync = ref.watch(roomStatsProvider);

    return roomStatsAsync.when(
      data: (stats) {
        if (stats.isEmpty) {
          return const Center(child: Text("Aucune salle trouvée"));
        }
        
        // Convert map to list of entries and sort by name
        final entries = stats.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
          
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: entries.map((entry) {
            return _buildRoomCard(
              entry.key, 
              '${entry.value} salle${entry.value > 1 ? 's' : ''}', 
              _getBlocColor(entry.key)
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Erreur: $e')),
    );
  }

  Color _getBlocColor(String blocName) {
    // Generate a consistent color based on the bloc name
    final colors = [
      const Color(0xFF2563EB), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEF4444), // Red
      const Color(0xFF6366F1), // Indigo
    ];
    
    // Use hash code to pick a color
    final index = blocName.hashCode.abs() % colors.length;
    return colors[index];
  }

  Widget _buildRoomCard(String name, String rooms, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.meeting_room, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  rooms,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSupervision(BuildContext context) {
    return FutureBuilder<List<InstitutionalService>>(
      future: CampusService.getInstitutionalServices(),
      builder: (context, snapshot) {
        final services = snapshot.data ?? [];
        final activeCount = services.where((s) => s.isActive).length;

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
                  Icon(
                    Icons.settings,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Supervision des services',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$activeCount actifs',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: LinearProgressIndicator())
              else if (snapshot.hasError)
                Text('Erreur: ${snapshot.error}')
              else if (services.isEmpty)
                const Text('Aucun service actif')
              else
                Column(
                  children: services.take(5).map((service) {
                    return _buildServiceItem(
                      service.nom, 
                      service.isActive ? 'Actif' : 'Inactif', 
                      service.isActive ? const Color(0xFF10B981) : Colors.grey, 
                      '100%' // Simulation uptime
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }
    );
  }

  // Helper method removed (was _buildServiceList) as logic is now inline

  Widget _buildServiceItem(String name, String status, Color statusColor, String uptime) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            uptime,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer l\'utilisateur'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cet utilisateur ? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ref.read(adminControllerProvider.notifier).deleteUser(userId, ref);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Utilisateur supprimé avec succès')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la suppression: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String category = 'Information';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Créer une annonce'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Titre'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(labelText: 'Contenu'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Catégorie'),
                      items: ['Information', 'Important', 'Urgent']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => category = v!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty || contentController.text.isEmpty) return;
                    Navigator.of(context).pop();
                    try {
                      await ref.read(announcementControllerProvider.notifier).createAnnouncement(
                        title: titleController.text,
                        content: contentController.text,
                        category: category,
                        ref: ref,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Annonce publiée')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    String role = 'Étudiant';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter un utilisateur'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'Prénom')),
                    TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Nom')),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                    TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mot de passe'), obscureText: true),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(labelText: 'Rôle'),
                      items: ['Étudiant', 'Enseignant', 'Admin']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setState(() => role = v!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () async {
                    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;
                    Navigator.pop(context);
                    try {
                      await ref.read(adminControllerProvider.notifier).createUser(
                        email: emailController.text,
                        password: passwordController.text,
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        role: role,
                        ref: ref,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Utilisateur créé')));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                      }
                    }
                  },
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();
    String selectedBloc = 'Bloc A';
    String selectedType = 'Cours';
    String status = 'Disponible';
    
    // Equipements
    bool hasProjector = false;
    bool hasAC = false;
    bool hasComputer = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter une salle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nom de la salle (ex: A101)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedBloc,
                      decoration: const InputDecoration(labelText: 'Bloc'),
                      items: ['Bloc A', 'Bloc B', 'Bloc C', 'Bloc D', 'Autre']
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedBloc = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: capacityController,
                      decoration: const InputDecoration(labelText: 'Capacité'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Type de salle'),
                      items: ['Cours', 'TP', 'Conférence', 'Labo']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedType = v!),
                    ),
                    const SizedBox(height: 16),
                    const Text('Équipements :', style: TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: const Text('Vidéoprojecteur'),
                      value: hasProjector,
                      onChanged: (v) => setState(() => hasProjector = v ?? false),
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('Climatisation'),
                      value: hasAC,
                      onChanged: (v) => setState(() => hasAC = v ?? false),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || capacityController.text.isEmpty) return;
                    
                    final equipments = <String>[];
                    if (hasProjector) equipments.add('Projecteur');
                    if (hasAC) equipments.add('Climatisation');
                    
                    Navigator.of(context).pop();
                    try {
                      await RoomService.upsertRoom({
                        'nom': nameController.text,
                        'bloc': selectedBloc,
                        'capacite': int.tryParse(capacityController.text) ?? 30,
                        'type': selectedType,
                        'equipements': equipments,
                        'statut': status,
                      });
                      
                      ref.invalidate(roomStatsProvider);
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Salle ajoutée avec succès')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class AdminUsersTab extends ConsumerWidget {
  const AdminUsersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Gestion des utilisateurs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allUsersProvider),
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(user['nom']?[0] ?? 'U', style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
                title: Text(user['nom'] ?? 'Utilisateur inconnu'),
                subtitle: Text('${user['email']}\n${user['role']}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDeleteUser(context, ref, user['id']),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text('Voulez-vous vraiment supprimer cet utilisateur ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Non')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminControllerProvider.notifier).deleteUser(userId, ref);
            }, 
            child: const Text('Oui', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}

class AdminAnnouncementsTab extends ConsumerWidget {
  const AdminAnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(allAnnouncementsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Gestion des annonces',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allAnnouncementsProvider),
          ),
        ],
      ),
      body: announcementsAsync.when(
        data: (announcements) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final a = announcements[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${a.category} • ${a.timeAgo}\n${a.content}'),
                isThreeLine: true,
                leading: Icon(Icons.campaign, color: _getCategoryColor(a.category)),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'urgent': return const Color(0xFFEF4444);
      case 'important': return const Color(0xFFF59E0B);
      case 'information': return const Color(0xFF2563EB);
      default: return const Color(0xFF10B981);
    }
  }
}

class AdminSettingsTab extends ConsumerStatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  ConsumerState<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends ConsumerState<AdminSettingsTab> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value ? 'Notifications activées' : 'Notifications désactivées')),
      );
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              leading: const Radio(value: 'fr', groupValue: 'fr', onChanged: null),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Anglais'),
              leading: const Radio(value: 'en', groupValue: 'fr', onChanged: null),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Traduction anglaise à venir')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer mot de passe'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final newPassword = passwordController.text;
              if (newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le mot de passe doit faire au moins 6 caractères')),
                );
                return;
              }
              Navigator.pop(context);
              try {
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(password: newPassword),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mot de passe mis à jour avec succès')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Paramètres',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeService.themeModeNotifier,
        builder: (context, themeMode, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSettingsGroup(context, 'Compte', [
                _buildSettingsItem(
                  context, 
                  Icons.person_outline, 
                  'Profil', 
                  'Gérer vos informations',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ModernStudentProfileScreen()),
                    );
                  },
                ),
                _buildSettingsItem(
                  context, 
                  Icons.security, 
                  'Sécurité', 
                  'Mot de passe et authentification',
                  onTap: _showChangePasswordDialog,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSettingsGroup(context, 'Application', [
                _buildSettingsItem(
                  context, 
                  Icons.notifications_outlined, 
                  'Notifications', 
                  'Alertes et messages',
                  onTap: () => _toggleNotifications(!_notificationsEnabled),
                  trailing: Switch(
                    value: _notificationsEnabled, 
                    onChanged: _toggleNotifications,
                    activeColor: Theme.of(context).primaryColor,
                  ), 
                ),
                _buildSettingsItem(
                  context, 
                  Icons.language, 
                  'Langue', 
                  'Français',
                  onTap: _showLanguageDialog,
                ),
                _buildSettingsItem(
                  context, 
                  themeService.themeIcon, 
                  'Apparence', 
                  'Mode ${themeService.themeLabel}',
                  onTap: () async {
                    await themeService.toggleTheme();
                  },
                  trailing: Icon(
                    Icons.brightness_6, 
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSettingsGroup(context, 'Support', [
                _buildSettingsItem(context, Icons.help_outline, 'Aide', 'Centre d\'assistance'),
                _buildSettingsItem(context, Icons.info_outline, 'À propos', 'Version 1.0.0'),
              ]),
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: () async {
                  await ref.read(supabaseAuthProvider.notifier).signOut();
                  // La navigation sera gérée par le listener d'état auth dans main.dart ou le router
                  // Mais pour forcer :
                  if (context.mounted) {
                     Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
                icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                label: const Text('Se déconnecter', style: TextStyle(color: Color(0xFFEF4444))),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    String subtitle, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      trailing: trailing ?? Icon(Icons.chevron_right, size: 20, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
      onTap: onTap,
    );
  }
}
