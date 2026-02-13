import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_providers.dart';
import '../shared/models/notification_model.dart';

class ModernNotificationsScreen extends ConsumerWidget {
  const ModernNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tout marquer comme lu',
            onPressed: () => ref.read(notificationControllerProvider.notifier).markAllAsRead(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune notification pour le moment',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(notification: notification);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(notificationControllerProvider.notifier).deleteNotification(notification.id);
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            ref.read(notificationControllerProvider.notifier).markAsRead(notification.id);
          }
          // Navigation selon le type
          _handleNavigation(context, notification);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          color: notification.isRead ? null : Theme.of(context).primaryColor.withOpacity(0.05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(context),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(notification.createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.content,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(notification.createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData;
    Color color;

    switch (notification.type) {
      case 'assignment':
        iconData = Icons.assignment;
        color = Colors.blue;
        break;
      case 'grade':
        iconData = Icons.grade;
        color = Colors.orange;
        break;
      case 'message':
        iconData = Icons.message;
        color = Colors.green;
        break;
      case 'announcement':
        iconData = Icons.campaign;
        color = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void _handleNavigation(BuildContext context, NotificationModel notification) {
    switch (notification.type) {
      case 'assignment':
        Navigator.pushNamed(context, '/assignments');
        break;
      case 'grade':
        // Navigation vers l'écran des notes
        break;
      case 'announcement':
        Navigator.pushNamed(context, '/announcements');
        break;
      case 'message':
        Navigator.pushNamed(context, '/messages');
        break;
    }
  }
}
