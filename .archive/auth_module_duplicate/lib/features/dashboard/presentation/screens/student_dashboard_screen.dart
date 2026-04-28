import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends ConsumerState<StudentDashboardScreen> {
  int _tabIndex = 0;

  final List<_ScheduleItem> _todaySchedule = const [
    _ScheduleItem(
      title: 'Programmation Avancée',
      time: '08:00 - 10:00',
      room: 'B203',
      type: 'Cours',
    ),
    _ScheduleItem(
      title: 'Base de Données',
      time: '10:30 - 12:00',
      room: 'A105',
      type: 'TD',
    ),
    _ScheduleItem(
      title: 'Intelligence Artificielle',
      time: '14:00 - 16:00',
      room: 'B104',
      type: 'TP',
    ),
  ];

  final List<_AnnouncementItem> _latestAnnouncements = const [
    _AnnouncementItem(
      title: 'Nouveau devoir disponible',
      description: 'Programmation Avancée - À rendre le 30 janvier',
      timeAgo: 'Il y a 2h',
      kind: _AnnouncementKind.info,
    ),
    _AnnouncementItem(
      title: 'Note publiée',
      description: 'Base de Données - Examen partiel : 16/20',
      timeAgo: 'Il y a 5h',
      kind: _AnnouncementKind.success,
    ),
    _AnnouncementItem(
      title: 'Rappel',
      description: 'Inscription aux examens avant le 27 janvier',
      timeAgo: 'Hier',
      kind: _AnnouncementKind.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('CampusConnect'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _tabIndex,
          children: [
            _StudentHomeTab(
              userName: user?.fullName ?? 'Étudiant',
              schedulePreview: _todaySchedule,
              announcementsPreview: _latestAnnouncements,
              onNavigateToSchedule: () => context.go('/student/schedule'),
              onNavigateToAnnouncements: () => context.go('/announcements'),
              onNavigateToDocuments: () => context.go('/documents'),
              onNavigateToProfile: () => setState(() => _tabIndex = 4),
            ),
            _ScheduleTab(items: _todaySchedule),
            _AnnouncementsTab(items: _latestAnnouncements),
            const _DocumentsTab(),
            _ProfileTab(
              userName: user?.fullName ?? 'Étudiant',
              email: user?.email ?? '',
              roleLabel: user?.role.label ?? 'Étudiant',
              onLogout: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (idx) {
          if (idx == 1) {
            context.go('/student/schedule');
            return;
          }
          if (idx == 2) {
            context.go('/announcements');
            return;
          }
          if (idx == 3) {
            context.go('/documents');
            return;
          }
          setState(() => _tabIndex = idx);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Planning'),
          BottomNavigationBarItem(icon: Icon(Icons.announcement), label: 'Annonces'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Documents'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _StudentHomeTab extends StatelessWidget {
  final String userName;
  final List<_ScheduleItem> schedulePreview;
  final List<_AnnouncementItem> announcementsPreview;
  final VoidCallback onNavigateToSchedule;
  final VoidCallback onNavigateToAnnouncements;
  final VoidCallback onNavigateToDocuments;
  final VoidCallback onNavigateToProfile;

  const _StudentHomeTab({
    required this.userName,
    required this.schedulePreview,
    required this.announcementsPreview,
    required this.onNavigateToSchedule,
    required this.onNavigateToAnnouncements,
    required this.onNavigateToDocuments,
    required this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = _formatDateFr(now);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $userName !',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickNavCard(
                  title: 'Emploi du temps',
                  icon: Icons.calendar_month,
                  color: Colors.blue,
                  onTap: onNavigateToSchedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickNavCard(
                  title: 'Annonces',
                  icon: Icons.announcement,
                  color: Colors.orange,
                  onTap: onNavigateToAnnouncements,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickNavCard(
                  title: 'Documents',
                  icon: Icons.folder,
                  color: Colors.purple,
                  onTap: onNavigateToDocuments,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickNavCard(
                  title: 'Profil',
                  icon: Icons.person,
                  color: Colors.green,
                  onTap: onNavigateToProfile,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Emploi du temps - Aujourd\'hui',
            actionText: 'Voir tout',
            onAction: onNavigateToSchedule,
          ),
          const SizedBox(height: 8),
          ...schedulePreview.take(3).map((item) {
            return _SchedulePreviewCard(item: item);
          }),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Dernières annonces',
            actionText: 'Tout voir',
            onAction: onNavigateToAnnouncements,
          ),
          const SizedBox(height: 8),
          ...announcementsPreview.take(3).map((a) {
            return _AnnouncementCard(item: a);
          }),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _QuickNavCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickNavCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}

class _SchedulePreviewCard extends StatelessWidget {
  final _ScheduleItem item;

  const _SchedulePreviewCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.schedule, color: Colors.blue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.time} • ${item.room}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.type,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final _AnnouncementItem item;

  const _AnnouncementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dotColor = switch (item.kind) {
      _AnnouncementKind.info => Colors.blue,
      _AnnouncementKind.warning => Colors.orange,
      _AnnouncementKind.success => Colors.green,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                Text(
                  item.timeAgo,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  final List<_ScheduleItem> items;

  const _ScheduleTab({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Emploi du temps (Aujourd\'hui)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        ...items.map((e) => _SchedulePreviewCard(item: e)),
      ],
    );
  }
}

class _AnnouncementsTab extends StatelessWidget {
  final List<_AnnouncementItem> items;

  const _AnnouncementsTab({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Annonces',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        ...items.map((e) => _AnnouncementCard(item: e)),
      ],
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab();

  @override
  Widget build(BuildContext context) {
    final docs = const [
      ('Cours - Programmation Avancée', 'PDF', '2.4 MB'),
      ('TD - Base de Données', 'PDF', '1.1 MB'),
      ('TP - Intelligence Artificielle', 'PDF', '3.0 MB'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Documents',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        ...docs.map((d) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.purple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.$1,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${d.$2} • ${d.$3}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.download, color: Colors.grey.shade700),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final String userName;
  final String email;
  final String roleLabel;
  final VoidCallback onLogout;

  const _ProfileTab({
    required this.userName,
    required this.email,
    required this.roleLabel,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Profil',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.withOpacity(0.15),
                child: Text(
                  userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.blue,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        roleLabel,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatDateFr(DateTime date) {
  const days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  const months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  final dayName = days[date.weekday - 1];
  final monthName = months[date.month - 1];
  return '$dayName ${date.day} $monthName ${date.year}';
}

enum _AnnouncementKind { info, warning, success }

class _AnnouncementItem {
  final String title;
  final String description;
  final String timeAgo;
  final _AnnouncementKind kind;

  const _AnnouncementItem({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.kind,
  });
}

class _ScheduleItem {
  final String title;
  final String time;
  final String room;
  final String type;

  const _ScheduleItem({
    required this.title,
    required this.time,
    required this.room,
    required this.type,
  });
}
