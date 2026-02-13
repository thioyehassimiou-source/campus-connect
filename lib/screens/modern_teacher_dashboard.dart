import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/controllers/schedule_providers.dart';
import 'package:campusconnect/core/services/schedule_service.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/screens/modern_enhanced_announcements_screen.dart';
import 'package:campusconnect/screens/modern_enhanced_schedule_screen.dart';
import 'package:campusconnect/screens/modern_teacher_profile_screen.dart';
import 'package:campusconnect/screens/modern_course_management_screen.dart';
import 'package:campusconnect/screens/modern_course_management_screen.dart';
import 'package:campusconnect/screens/modern_resources_screen.dart';
import 'package:campusconnect/screens/modern_rooms_screen.dart';
import 'package:campusconnect/screens/modern_assignments_screen.dart';
import 'package:campusconnect/widgets/theme_toggle_button.dart';
import 'package:campusconnect/controllers/resource_providers.dart';
import 'package:campusconnect/controllers/course_providers.dart';
import 'package:campusconnect/core/services/resource_service.dart';
import 'package:campusconnect/core/services/academic_service.dart';
import 'package:campusconnect/screens/modern_grades_screen.dart';
import 'package:campusconnect/screens/modern_services_screen.dart';
import 'package:campusconnect/controllers/notification_providers.dart';

import 'package:campusconnect/core/services/profile_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:campusconnect/core/services/resource_service.dart';

class ModernTeacherDashboard extends ConsumerStatefulWidget {
  const ModernTeacherDashboard({super.key});

  @override
  ConsumerState<ModernTeacherDashboard> createState() => _ModernTeacherDashboardState();
}

class _ModernTeacherDashboardState extends ConsumerState<ModernTeacherDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TeacherDashboardHome(),
    const ModernEnhancedAnnouncementsScreen(isTeacher: true),
    const ModernEnhancedScheduleScreen(isTeacher: true),
    const ModernCourseManagementScreen(),
    const ModernResourcesScreen(isTeacher: true),
    const ModernTeacherProfileScreen(),
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
          unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
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
              label: 'Emploi',
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

class TeacherDashboardHome extends ConsumerStatefulWidget {
  const TeacherDashboardHome({super.key});

  @override
  ConsumerState<TeacherDashboardHome> createState() => _TeacherDashboardHomeState();
}

class _TeacherDashboardHomeState extends ConsumerState<TeacherDashboardHome> {
  String _fullName = 'Enseignant';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await ProfileService.getCurrentUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _fullName = profile['nom'] ?? 'Enseignant';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    final scheduleAsync = ref.watch(teacherProposalsProvider);
    final resourcesAsync = ref.watch(teacherResourcesProvider);
    final coursesAsync = ref.watch(teacherCoursesProvider);

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
              greeting,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _fullName,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          const ThemeToggleButton(),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Consumer(
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aperçu emploi du temps
            scheduleAsync.when(
              data: (items) {
                // Pour l'enseignant, on montre les cours d'aujourd'hui
                final todayItems = items.where((item) => 
                  item.startTime.day == now.day && 
                  item.startTime.month == now.month && 
                  item.startTime.year == now.year
                ).toList();
                return _buildScheduleOverview(context, todayItems);
              },
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, st) => _buildScheduleOverview(context, []),
            ),
            
            const SizedBox(height: 24),
            
            // Boutons rapides
            _buildQuickActions(context),
            
            const SizedBox(height: 24),
            
            // Accès aux documents publiés
            _buildPublishedDocuments(context, resourcesAsync),
            
            const SizedBox(height: 24),
            
            // Statistiques rapides
            _buildQuickStats(coursesAsync, resourcesAsync, scheduleAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleOverview(BuildContext context, List<ScheduleItem> items) {
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
                Icons.calendar_today,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Aperçu emploi du temps',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigation vers l'onglet emploi du temps gérée par le parent
                },
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('Aucun cours aujourd\'hui', style: TextStyle(fontStyle: FontStyle.italic))
          else
            ...items.take(3).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildScheduleItem(
                item.subject, 
                '${DateFormat('HH:mm').format(item.startTime)} - ${DateFormat('HH:mm').format(item.endTime)}', 
                item.room, 
                item.type, 
                0 // On n'a pas le nombre d'étudiants dans ScheduleItem par défaut
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String subject, String time, String room, String type, int students) {
    Color typeColor;
    switch (type) {
      case 'CM':
        typeColor = Theme.of(context).primaryColor;
        break;
      case 'TD':
        typeColor = const Color(0xFF10B981);
        break;
      case 'TP':
        typeColor = const Color(0xFFF59E0B);
        break;
      default:
        typeColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 32,
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
                Text(
                  '$time • $room • $students étudiants',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
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

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Publier document',
                Icons.upload_file,
                const Color(0xFF2563EB),
                () {
                  _showPublishDocumentDialog(context);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                context,
                'Devoirs',
                Icons.assignment,
                const Color(0xFF6366F1),
                () {
                  Navigator.pushNamed(context, '/assignments');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                context,
                'Réserver salle',
                Icons.meeting_room,
                const Color(0xFFF59E0B),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModernRoomsScreen(isTeacher: true),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Publier annonce',
                Icons.campaign,
                const Color(0xFFEF4444),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModernEnhancedAnnouncementsScreen(isTeacher: true),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                context,
                'Gestion Notes',
                Icons.grade,
                const Color(0xFF10B981),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModernGradesScreen(isTeacher: true),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                context,
                'Messagerie',
                Icons.forum,
                const Color(0xFF25D366),
                () {
                  Navigator.pushNamed(context, '/messages');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildPublishedDocuments(BuildContext context, AsyncValue<List<Resource>> resourcesAsync) {
    return resourcesAsync.when(
      data: (resources) {
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
                    Icons.folder_open,
                    color: const Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Documents publiés',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
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
                      '${resources.length} documents',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (resources.isEmpty)
                const Center(child: Text('Aucun document publié'))
              else
                ...resources.take(3).map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildDocumentItem(r.title, r.type, 'Support', 'Fait le ${DateFormat('dd/MM').format(r.date)}'),
                )).toList(),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text('Erreur: $e'),
    );
  }

  Widget _buildDocumentItem(String title, String type, String size, String time) {
    Color typeColor;
    switch (type) {
      case 'PDF':
        typeColor = const Color(0xFFEF4444);
        break;
      case 'PPT':
        typeColor = const Color(0xFFF59E0B);
        break;
      default:
        typeColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: typeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  '$size • $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_vert,
            size: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AsyncValue<List<Course>> coursesAsync, AsyncValue<List<Resource>> resourcesAsync, AsyncValue<List<ScheduleItem>> scheduleAsync) {
    final studentsCount = coursesAsync.when(
      data: (courses) => courses.fold(0, (sum, c) => sum + c.studentsCount).toString(),
      loading: () => '...',
      error: (_, __) => '0',
    );

    final sessionsCount = scheduleAsync.when(
      data: (items) {
        final now = DateTime.now();
        return items.where((i) => i.startTime.month == now.month).length.toString();
      },
      loading: () => '...',
      error: (_, __) => '0',
    );

    final docsCount = resourcesAsync.when(
      data: (res) => res.length.toString(),
      loading: () => '...',
      error: (_, __) => '0',
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Total étudiants', studentsCount, 'Ce semestre', Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Cours ce mois', sessionsCount, 'Sessions', const Color(0xFF10B981)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Documents', docsCount, 'Publiés', const Color(0xFFF59E0B)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showPublishDocumentDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final subjectController = TextEditingController();
    String selectedType = 'PDF';
    bool isUploading = false;
    PlatformFile? selectedFile;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Publier un document'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre du document',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Matière (ex: Mathématiques)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type de fichier',
                      border: OutlineInputBorder(),
                    ),
                    items: ['PDF', 'PPT', 'DOC', 'AUTRE']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) => setStateDialog(() => selectedType = value!),
                  ),
                  const SizedBox(height: 16),
                  
                  // Zone de sélection de fichier
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      children: [
                        if (selectedFile != null) ...[
                          Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 32),
                          const SizedBox(height: 8),
                          Text(
                            selectedFile!.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => setStateDialog(() => selectedFile = null),
                            icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                            label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ),
                        ] else
                          TextButton.icon(
                            onPressed: () async {
                              try {
                                final result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt'],
                                  withData: true, // Important pour le web/mobile si on veut les bytes immédiatement
                                );

                                if (result != null) {
                                  setStateDialog(() {
                                    selectedFile = result.files.first;
                                    // Auto-detect type roughly
                                    final ext = selectedFile!.extension?.toLowerCase();
                                    if (ext == 'pdf') selectedType = 'PDF';
                                    else if (['ppt', 'pptx'].contains(ext)) selectedType = 'PPT';
                                    else if (['doc', 'docx'].contains(ext)) selectedType = 'DOC';
                                  });
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur sélection fichier: $e')),
                                );
                              }
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Sélectionner un fichier'),
                          ),
                      ],
                    ),
                  ),

                  if (isUploading) ...[
                    const SizedBox(height: 20),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    const Center(child: Text('Téléversement en cours...')),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: (isUploading || selectedFile == null || titleController.text.isEmpty || subjectController.text.isEmpty)
                    ? null
                    : () async {
                        setStateDialog(() => isUploading = true);
                        try {
                          // 1. Upload file to Storage
                          // Note: ResourceService.uploadResourceFile expects bytes
                          if (selectedFile?.bytes == null && selectedFile?.path == null) {
                            throw Exception("Impossible de lire le fichier");
                          }

                          // If we have bytes (web/memory), use them. If path (mobile/desktop), read them.
                          List<int> fileBytes;
                          if (selectedFile!.bytes != null) {
                            fileBytes = selectedFile!.bytes!;
                          } else {
                            // This requires dart:io but we might be on web. 
                            // Fortunately FilePicker withData:true usually gives bytes.
                            // However, let's assume valid bytes for now.
                            // If strictly mobile without withData:true, we'd need File(path).readAsBytesSync()
                            // But keeping it simple with withData:true assumed/configured or handled.
                            // For this snippet, assuming bytes are present or we handle io import elsewhere.
                            // Let's rely on FilePicker returning bytes if available, or error.
                            if (selectedFile!.bytes == null) {
                                throw Exception("Erreur de lecture du fichier (bytes null). Réessayez.");
                            }
                            fileBytes = selectedFile!.bytes!;
                          }

                          final url = await ResourceService.uploadResourceFile(
                            selectedFile!.name,
                            fileBytes,
                          );

                          // 2. Create Resource record in DB
                          final profile = await ProfileService.getCurrentUserProfile();
                          await ResourceService.addResource(
                            title: titleController.text,
                            description: descriptionController.text,
                            url: url,
                            type: selectedType,
                            subject: subjectController.text,
                            scope: 'license',
                            departmentId: profile?['department_id']?.toString(),
                            facultyId: profile?['faculty_id']?.toString(),
                            niveau: profile?['niveau'],
                          );

                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Document publié avec succès !')),
                            );
                            // Refresh logic if needed, e.g. ref.refresh(teacherResourcesProvider)
                            ref.refresh(teacherResourcesProvider);
                          }
                        } catch (e) {
                          setStateDialog(() => isUploading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        }
                      },
                child: const Text('Publier'),
              ),
            ],
          );
        },
      ),
    );
  }



  String _getGreeting(int hour) {
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }
}

class TeacherScheduleTab extends StatelessWidget {
  const TeacherScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Emploi du temps',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Emploi du temps - En cours de développement',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class TeacherDocumentsTab extends StatelessWidget {
  const TeacherDocumentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Documents',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Documents - En cours de développement',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class TeacherProfileTab extends StatelessWidget {
  const TeacherProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Profil - En cours de développement',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
