import 'package:flutter/material.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/shared/models/user.dart';
import 'package:campusconnect/screens/emploi_du_temps_screen.dart';
import 'package:campusconnect/screens/notes_screen.dart';
import 'package:campusconnect/screens/documents_screen.dart';
import 'package:campusconnect/screens/annonces_screen.dart';
import 'package:campusconnect/screens/services_screen.dart';
import 'package:campusconnect/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _setupPagesAndNavigation();
  }

  void _setupPagesAndNavigation() {
    switch (widget.user.role) {
      case UserRole.etudiant:
        _pages = [
          _buildStudentDashboard(),
          EmploiDuTempsScreen(user: widget.user),
          NotesScreen(user: widget.user),
          DocumentsScreen(user: widget.user),
          AnnoncesScreen(user: widget.user),
          ServicesScreen(user: widget.user),
          ProfileScreen(user: widget.user),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Emploi du temps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grading),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Annonces',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ];
        break;
        
      case UserRole.enseignant:
        _pages = [
          _buildTeacherDashboard(),
          EmploiDuTempsScreen(user: widget.user),
          DocumentsScreen(user: widget.user),
          AnnoncesScreen(user: widget.user),
          ProfileScreen(user: widget.user),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Emploi du temps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Annonces',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ];
        break;
        
      case UserRole.administrateur:
        _pages = [
          _buildAdminDashboard(),
          ProfileScreen(user: widget.user),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ];
        break;
    }
  }

  Widget _buildStudentDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue, ${widget.user.nom}',
            style: AppTheme.headingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Étudiant - ${widget.user.niveau ?? "N/A"}',
            style: AppTheme.bodyStyle.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  'Emploi du temps',
                  Icons.schedule,
                  Colors.blue,
                  () => _navigateToPage(1),
                ),
                _buildMenuCard(
                  'Mes notes',
                  Icons.grading,
                  Colors.green,
                  () => _navigateToPage(2),
                ),
                _buildMenuCard(
                  'Documents',
                  Icons.folder,
                  Colors.orange,
                  () => _navigateToPage(3),
                ),
                _buildMenuCard(
                  'Annonces',
                  Icons.announcement,
                  Colors.red,
                  () => _navigateToPage(4),
                ),
                _buildMenuCard(
                  'Services',
                  Icons.miscellaneous_services,
                  Colors.purple,
                  () => _navigateToPage(5),
                ),
                _buildMenuCard(
                  'Profil',
                  Icons.person,
                  Colors.teal,
                  () => _navigateToPage(6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue, ${widget.user.nom}',
            style: AppTheme.headingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Enseignant',
            style: AppTheme.bodyStyle.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  'Emploi du temps',
                  Icons.schedule,
                  Colors.blue,
                  () => _navigateToPage(1),
                ),
                _buildMenuCard(
                  'Publier documents',
                  Icons.upload_file,
                  Colors.green,
                  () => _navigateToPage(2),
                ),
                _buildMenuCard(
                  'Annonces',
                  Icons.announcement,
                  Colors.red,
                  () => _navigateToPage(3),
                ),
                _buildMenuCard(
                  'Profil',
                  Icons.person,
                  Colors.teal,
                  () => _navigateToPage(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord Administrateur',
            style: AppTheme.headingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Université de Labé',
            style: AppTheme.bodyStyle.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  'Gestion utilisateurs',
                  Icons.people,
                  Colors.blue,
                  () {},
                ),
                _buildMenuCard(
                  'Gestion blocs',
                  Icons.business,
                  Colors.green,
                  () {},
                ),
                _buildMenuCard(
                  'Gestion salles',
                  Icons.meeting_room,
                  Colors.orange,
                  () {},
                ),
                _buildMenuCard(
                  'Annonces officielles',
                  Icons.campaign,
                  Colors.red,
                  () {},
                ),
                _buildMenuCard(
                  'Emplois du temps',
                  Icons.schedule,
                  Colors.purple,
                  () {},
                ),
                _buildMenuCard(
                  'Rapports',
                  Icons.analytics,
                  Colors.teal,
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CampusConnect - ${widget.user.nom}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _showLogoutDialog();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToPage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: _navItems,
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (result == true) {
      // TODO: Implement logout with Supabase
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}
