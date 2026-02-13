import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/chat_providers.dart';
import '../shared/models/message_model.dart';

class ModernMessagingScreen extends ConsumerStatefulWidget {
  const ModernMessagingScreen({super.key});

  @override
  ConsumerState<ModernMessagingScreen> createState() => _ModernMessagingScreenState();
}

class _ModernMessagingScreenState extends ConsumerState<ModernMessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final selectedConv = ref.read(selectedConversationProvider);
    if (selectedConv == null || _messageController.text.trim().isEmpty) return;

    ref.read(chatControllerProvider.notifier).sendMessage(
      conversationId: selectedConv.id,
      content: _messageController.text.trim(),
    );

    _messageController.clear();
    
    // Scroll vers le bas après envoi
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_messagesScrollController.hasClients) {
        _messagesScrollController.animateTo(
          _messagesScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsStreamProvider);
    final selectedConv = ref.watch(selectedConversationProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          'Messagerie',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment_outlined, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // TODO: Dialog pour créer une nouvelle conversation
              _showNewConversationDialog();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Panneau latéral des conversations
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                right: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
            ),
            child: Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                
                // Liste des conversations
                Expanded(
                  child: conversationsAsync.when(
                    data: (conversations) {
                      if (conversations.isEmpty) {
                        return Center(
                          child: Text(
                            'Aucune conversation',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          final isSelected = selectedConv?.id == conversation.id;
                          return _buildConversationCard(conversation, isSelected);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Erreur: $e')),
                  ),
                ),
              ],
            ),
          ),
          
          // Zone de conversation
          Expanded(
            child: selectedConv != null
                ? _buildConversationArea(selectedConv)
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(ConversationModel conversation, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedConversationProvider.notifier).state = conversation;
        ref.read(chatControllerProvider.notifier).markAsRead(conversation.id);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
            left: isSelected
                ? BorderSide(color: Theme.of(context).primaryColor, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                conversation.isGroup ? Icons.group : Icons.person,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            
            // Infos conversation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.displayLastMessage ?? 'Pas de message',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Heure
            Text(
              _formatTime(conversation.lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationArea(ConversationModel conversation) {
    final messagesAsync = ref.watch(messagesStreamProvider(conversation.id));

    return Column(
      children: [
        // En-tête de conversation
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  conversation.isGroup ? Icons.group : Icons.person,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: messagesAsync.when(
            data: (messages) {
              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun message',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                );
              }
              
              // Scroll automatique au dernier message
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_messagesScrollController.hasClients) {
                  _messagesScrollController.jumpTo(_messagesScrollController.position.maxScrollExtent);
                }
              });

              return ListView.builder(
                controller: _messagesScrollController,
                padding: const EdgeInsets.all(20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageBubble(message, conversation);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Erreur: $e')),
          ),
        ),

        // Zone de saisie
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Écrivez votre message...',
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _sendMessage,
                icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(MessageModel message, ConversationModel conversation) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isMe = message.senderId == currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe 
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.senderName ?? 'Inconnu',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            if (!isMe) const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isMe 
                    ? Colors.white.withOpacity(0.7)
                    : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Sélectionnez une conversation',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showNewConversationDialog() {
    // TODO: Implémenter le dialog pour créer une nouvelle conversation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle conversation'),
        content: const Text('Fonctionnalité en cours de développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}j';
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }
}
