import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/features/admin/data/models/admin_stats_model.dart';
import 'package:campusconnect/features/admin/data/models/activity_log_model.dart';
import 'package:campusconnect/features/admin/presentation/providers/admin_stats_provider.dart';
import 'package:campusconnect/features/admin/presentation/providers/admin_activity_provider.dart';
import 'package:campusconnect/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:campusconnect/features/admin/presentation/widgets/admin_activity_feed.dart';

/// Dashboard principal de l'administrateur.
/// Affiche les KPIs globaux, les créneaux en attente et l'activité récente.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final logsAsync = ref.watch(adminActivityLogsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminStatsProvider);
          ref.invalidate(adminActivityLogsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── AppBar ─────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 100,
              automaticallyImplyLeading: false,
              backgroundColor: theme.scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                title: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tableau de bord',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            _greetingTime(),
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref.invalidate(adminStatsProvider);
                        ref.invalidate(adminActivityLogsProvider);
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Actualiser',
                    ),
                  ],
                ),
              ),
            ),

            // ── Stats KPI ──────────────────────────────────────
            SliverToBoxAdapter(
              child: statsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => _ErrorBanner(message: e.toString()),
                data: (stats) => _StatsGrid(stats: stats),
              ),
            ),

            // ── Alerte créneaux en attente ─────────────────────
            SliverToBoxAdapter(
              child: statsAsync.maybeWhen(
                data: (stats) => stats.pendingSchedules > 0
                    ? _PendingBanner(count: stats.pendingSchedules)
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),
            ),

            // ── Actions rapides ────────────────────────────────
            const SliverToBoxAdapter(child: _QuickActions()),

            // ── Activité récente ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  'Activité récente',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: logsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const AdminActivityFeed(logs: []),
                data: (logs) => AdminActivityFeed(logs: logs),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  String _greetingTime() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour, bonne matinée ☀️';
    if (h < 18) return 'Bon après-midi 🌤';
    return 'Bonne soirée 🌙';
  }
}

// ─── Grille des stats ──────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final AdminStatsModel stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      AdminStatCardData(
        label: 'Étudiants',
        value: stats.totalStudents.toString(),
        icon: Icons.school,
        color: const Color(0xFF3B82F6),
        subtitle: 'inscrits',
      ),
      AdminStatCardData(
        label: 'Enseignants',
        value: stats.totalTeachers.toString(),
        icon: Icons.person_pin,
        color: const Color(0xFF8B5CF6),
        subtitle: 'actifs',
      ),
      AdminStatCardData(
        label: 'Cours',
        value: stats.totalCourses.toString(),
        icon: Icons.menu_book,
        color: const Color(0xFF10B981),
        subtitle: 'au total',
      ),
      AdminStatCardData(
        label: 'Salles',
        value: stats.totalRooms.toString(),
        icon: Icons.meeting_room,
        color: const Color(0xFFF59E0B),
        subtitle: 'disponibles',
      ),
      AdminStatCardData(
        label: 'Annonces',
        value: stats.totalAnnouncements.toString(),
        icon: Icons.campaign,
        color: const Color(0xFFEF4444),
        subtitle: 'publiées',
      ),
      AdminStatCardData(
        label: 'Admins',
        value: stats.totalAdmins.toString(),
        icon: Icons.manage_accounts,
        color: const Color(0xFF06B6D4),
        subtitle: 'équipe',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => AdminStatCard(data: items[i]),
      ),
    );
  }
}

// ─── Bannière créneaux en attente ───────────────────────────────────────────

class _PendingBanner extends StatelessWidget {
  final int count;
  const _PendingBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border.all(color: Colors.orange.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.pending_actions, color: Colors.orange.shade700, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$count créneau${count > 1 ? 'x' : ''} en attente de validation',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Voir', style: TextStyle(color: Colors.orange.shade800)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Actions rapides ────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = [
      _QuickAction(icon: Icons.person_add, label: 'Nouvel\nutilisateur', color: const Color(0xFF3B82F6)),
      _QuickAction(icon: Icons.campaign, label: 'Nouvelle\nannonce', color: const Color(0xFFEF4444)),
      _QuickAction(icon: Icons.event, label: 'Planning', color: const Color(0xFF8B5CF6)),
      _QuickAction(icon: Icons.bar_chart, label: 'Rapport', color: const Color(0xFF10B981)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions rapides',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: actions
                .map((a) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _QuickActionButton(action: a),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: action.color.withValues(alpha: isDark ? 0.15 : 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(action.icon, color: action.color, size: 24),
              const SizedBox(height: 6),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: action.color,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction({required this.icon, required this.label, required this.color});
}

// ─── Bannière d'erreur ──────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Erreur: $message',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
