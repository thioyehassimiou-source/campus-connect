import 'package:flutter/material.dart';
import 'package:campusconnect/services/auth_service.dart';
import 'package:campusconnect/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:campusconnect/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:campusconnect/features/admin/presentation/screens/admin_academic_screen.dart';
import 'package:campusconnect/features/admin/presentation/screens/admin_schedule_screen.dart';
import 'package:campusconnect/features/admin/presentation/screens/admin_announcements_screen.dart';
import 'package:campusconnect/features/admin/presentation/screens/admin_rooms_admin_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _selectedIndex = 0;
  bool _isAuthorized = false;
  bool _loading = true;

  static const _destinations = [
    _NavDest(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    _NavDest(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Utilisateurs'),
    _NavDest(icon: Icons.school_outlined, activeIcon: Icons.school, label: 'Académique'),
    _NavDest(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today, label: 'Planning'),
    _NavDest(icon: Icons.campaign_outlined, activeIcon: Icons.campaign, label: 'Annonces'),
    _NavDest(icon: Icons.meeting_room_outlined, activeIcon: Icons.meeting_room, label: 'Salles'),
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    try {
      final user = await AuthService.getStoredUser();
      if (user == null) {
        _redirect('/login');
        return;
      }

      final role = user.role.toUpperCase();
      final isAdmin = role.contains('ADMIN');

      if (!isAdmin) {
        _redirect('/student-dashboard');
        return;
      }

      if (mounted) setState(() { _isAuthorized = true; _loading = false; });
    } catch (e) {
      _redirect('/login');
    }
  }

  void _redirect(String route) {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  Widget _buildScreen() {
    switch (_selectedIndex) {
      case 0: return const AdminDashboardScreen();
      case 1: return const AdminUsersScreen();
      case 2: return const AdminAcademicScreen();
      case 3: return const AdminScheduleScreen();
      case 4: return const AdminAnnouncementsScreen();
      case 5: return const AdminRoomsAdminScreen();
      default: return const AdminDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_isAuthorized) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 600;

    if (isWide) {
      return _buildWideLayout(theme);
    } else {
      return _buildNarrowLayout(theme);
    }
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Scaffold(
      body: Row(
        children: [
          _AdminRail(
            selectedIndex: _selectedIndex,
            destinations: _destinations,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildScreen()),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return Scaffold(
      body: _buildScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: _destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.activeIcon),
                  label: d.label,
                ))
            .toList(),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }
}

class _AdminRail extends StatelessWidget {
  final int selectedIndex;
  final List<_NavDest> destinations;
  final ValueChanged<int> onTap;

  const _AdminRail({
    required this.selectedIndex,
    required this.destinations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 220,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CampusConnect',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      Text('Administration',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.blue)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('  NAVIGATION',
                style: TextStyle(letterSpacing: 1.2, fontSize: 10, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 4),
          ...destinations.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            final isSelected = selectedIndex == i;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? d.activeIcon : d.icon,
                        size: 20,
                        color: isSelected
                            ? colorScheme.primary
                            : theme.iconTheme.color,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        d.label,
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.primary
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          const Spacer(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () async {
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.red.shade400),
                    const SizedBox(width: 12),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavDest {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavDest({required this.icon, required this.activeIcon, required this.label});
}
