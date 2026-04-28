import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/messaging_models.dart';
import '../controllers/messaging_providers.dart';
import '../services/messaging_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatConversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  ChatMessage? _repliedMessage;

  @override
  void initState() {
    super.initState();
    _markRead();
  }

  void _markRead() {
    MessagingService.markMessagesAsRead(widget.conversation.id);
  }

  void _handleSend(String text) {
    ref.read(messagingControllerProvider.notifier).sendMessage(
      conversationId: widget.conversation.id,
      content: text,
      replyToId: _repliedMessage?.id,
    );
    setState(() => _repliedMessage = null); // Clear reply after sending
  }

  void _handleReply(ChatMessage message) {
    setState(() => _repliedMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final messagesAsync = ref.watch(chatMessagesProvider(widget.conversation.id));
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark 
          ? const Color(0xFF0B141A) // WhatsApp Dark BG
          : const Color(0xFFE5DDD5), // WhatsApp Light BG
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark 
            ? const Color(0xFF1F2C33) 
            : theme.primaryColor,
        elevation: 0,
        leadingWidth: 70,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 4),
              const Icon(Icons.arrow_back, color: Colors.white),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                backgroundImage: widget.conversation.avatarUrl != null 
                    ? NetworkImage(widget.conversation.avatarUrl!) 
                    : null,
                child: widget.conversation.avatarUrl == null
                  ? Text(
                      widget.conversation.displayName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    )
                  : null,
              ),
            ],
          ),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conversation.displayName,
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              _getSubTitle(),
              style: const TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appels vidéo bientôt disponibles')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appels audio bientôt disponibles')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (value) async {
              if (value == 'clear') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Vider la discussion ?'),
                    content: const Text('Tous les messages seront supprimés.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULER')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true), 
                        child: const Text('VIDER', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await MessagingService.clearChat(widget.conversation.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Discussion vidée')),
                    );
                  }
                }
              } else if (value == 'view_contact') {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: widget.conversation.avatarUrl != null ? NetworkImage(widget.conversation.avatarUrl!) : null,
                          child: widget.conversation.avatarUrl == null ? Text(widget.conversation.displayName[0], style: const TextStyle(fontSize: 32)) : null,
                        ),
                        const SizedBox(height: 16),
                        Text(widget.conversation.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(_getSubTitle(), style: const TextStyle(color: Colors.grey)),
                        const Divider(),
                        ListTile(leading: const Icon(Icons.info_outline), title: const Text('Bio'), subtitle: const Text('Étudiant à l\'Université de Labé')),
                        ListTile(leading: const Icon(Icons.phone), title: const Text('Appeler'), onTap: () {}),
                      ],
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view_contact', child: Text('Voir le contact')),
              const PopupMenuItem(value: 'media', child: Text('Médias, liens et docs')),
              const PopupMenuItem(value: 'search', child: Text('Rechercher')),
              const PopupMenuItem(value: 'mute', child: Text('Silence')),
              const PopupMenuItem(value: 'clear', child: Text('Vider la discussion')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // WhatsApp Wallpaper Pattern
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.05 : 0.08,
              child: Image.network(
                'https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    });

                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucun message ici. Dites bonjour !',
                          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return MessageBubble(
                          messageId: message.id,
                          content: message.content,
                          timestamp: message.timestamp,
                          isMe: message.senderId == currentUserId,
                          isRead: message.status == MessageStatus.read,
                          senderName: widget.conversation.isGroup ? message.senderName : null,
                          onReply: () => _handleReply(message),
                          repliedMessageContent: message.repliedMessageContent,
                          repliedMessageSenderName: message.repliedMessageSenderName,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Erreur: $e')),
                ),
              ),
              ChatInput(
                onSend: _handleSend,
                readOnly: widget.conversation.type == ChatConversationType.announcement,
                onAttach: () {},
                repliedMessage: _repliedMessage,
                onCancelReply: () => setState(() => _repliedMessage = null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSubTitle() {
    switch (widget.conversation.type) {
      case ChatConversationType.announcement:
        return 'Annonces officielles';
      case ChatConversationType.group:
        return 'Groupe de discussion';
      case ChatConversationType.private:
        return 'En ligne';
    }
  }
}
