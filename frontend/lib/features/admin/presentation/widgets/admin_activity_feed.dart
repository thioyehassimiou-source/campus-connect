import 'package:flutter/material.dart';
import 'package:campusconnect/features/admin/data/models/activity_log_model.dart';

/// Widget de fil d'activité des administrateurs.
class AdminActivityFeed extends StatelessWidget {
  final List<ActivityLogModel> logs;

  const AdminActivityFeed({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 40, color: theme.iconTheme.color?.withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              Text('Aucune activité récente',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  )),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, i) => _ActivityTile(log: logs[i]),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityLogModel log;
  const _ActivityTile({required this.log});

  IconData get _icon {
    switch (log.action) {
      case 'create_user': return Icons.person_add;
      case 'update_user': return Icons.edit;
      case 'delete_user': return Icons.person_remove;
      case 'toggle_user_status': return Icons.toggle_on;
      case 'validate_schedule': return Icons.check_circle;
      case 'reject_schedule': return Icons.cancel;
      case 'create_announcement': return Icons.campaign;
      case 'create_filiere': return Icons.account_tree;
      case 'update_room': return Icons.meeting_room;
      default: return Icons.history;
    }
  }

  Color get _color {
    switch (log.action) {
      case 'create_user':
      case 'create_announcement':
      case 'create_filiere': return const Color(0xFF10B981);
      case 'delete_user':
      case 'reject_schedule': return const Color(0xFFEF4444);
      case 'validate_schedule': return const Color(0xFF3B82F6);
      default: return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.actionLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (log.details != null && log.details!.isNotEmpty)
                  Text(
                    log.details!.values.first?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
          Text(
            log.timeAgo,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
