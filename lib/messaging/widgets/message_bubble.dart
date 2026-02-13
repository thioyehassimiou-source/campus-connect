import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final bool isRead;
  final String? senderName;

  const MessageBubble({
    super.key,
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.isRead = false,
    this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // WhatsApp-inspired colors
    final sentColor = isDark ? const Color(0xFF056162) : const Color(0xFFDCF8C6);
    final receivedColor = isDark ? const Color(0xFF1F2C33) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final timeColor = isDark ? Colors.white60 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () => _showMessageMenu(context),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? sentColor : receivedColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (senderName != null && !isMe)
                          Text(
                            senderName!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.only(right: 30), // Space for time
                          child: Text(
                            content,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 10,
                            color: timeColor,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: isRead ? Colors.blue[400] : timeColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Répondre'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copier'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.forward),
            title: const Text('Transférer'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Supprimer pour moi', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
