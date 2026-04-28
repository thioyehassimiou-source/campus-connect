import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/messaging_models.dart';

class ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = _formatTime(conversation.lastMessageTime);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            _buildAvatar(theme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.displayName,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: conversation.unreadCount > 0
                              ? const Color(0xFF25D366)
                              : (isDark ? Colors.white60 : Colors.black54),
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (conversation.lastMessageSenderId == Supabase.instance.client.auth.currentUser?.id) ...[
                              Icon(
                                conversation.isLastMessageRead ? Icons.done_all : Icons.done,
                                size: 16,
                                color: conversation.isLastMessageRead ? Colors.blue : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                conversation.displayLastMessage ?? 'Appuyez pour discuter',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF25D366),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
          backgroundImage: conversation.avatarUrl != null
              ? NetworkImage(conversation.avatarUrl!)
              : null,
          child: conversation.avatarUrl == null
              ? Text(
                  conversation.displayName[0].toUpperCase(),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                )
              : null,
        ),
        if (conversation.type == ChatConversationType.announcement)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF0B141A) : Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.campaign,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time).inDays;
    
    if (difference == 0 && time.day == now.day) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1 || (difference == 0 && time.day != now.day)) {
      return 'Hier';
    } else if (difference < 7) {
      // Return day name (simplified)
      return '${time.day}/${time.month}';
    }
    return '${time.day}/${time.month}/${time.year.toString().substring(2)}';
  }
}
