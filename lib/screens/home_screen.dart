import 'package:flutter/material.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/shared/widgets/custom_button.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:campusconnect/screens/profile_screen.dart';
import 'package:campusconnect/screens/schedule_screen.dart';
import 'package:campusconnect/screens/grades_screen.dart';
import 'package:campusconnect/screens/announcements_screen.dart';
import 'package:campusconnect/screens/documents_screen.dart';
import 'package:campusconnect/screens/messages_screen.dart';
import 'package:campusconnect/screens/services_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(user: widget.user),
    ScheduleScreen(user: widget.user),
    GradesScreen(user: widget.user),
    ProfileScreen(user: widget.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CampusConnect - ${widget.user.fullName}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
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
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final UserModel user;

  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord',
            style: AppTheme.headingStyle,
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  'Emploi du temps',
                  Icons.schedule,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleScreen(user: user),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Notes',
                  Icons.grading,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GradesScreen(user: user),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Documents',
                  Icons.folder,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentsScreen(user: user),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Annonces',
                  Icons.announcement,
                  Colors.red,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnnouncementsScreen(user: user),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Messages',
                  Icons.message,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessagesScreen(user: user),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Services',
                  Icons.miscellaneous_services,
                  Colors.teal,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServicesScreen(user: user),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
}

