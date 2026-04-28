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
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer la conversation ?'),
            content: const Text('Cette action est irréversible et supprimera tous les messages.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await ChatService.deleteConversation(conversation.id);
                    // Si c'était la conversation sélectionnée, on la désélectionne
                    if (isSelected) {
                      ref.read(selectedConversationProvider.notifier).state = null;
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Conversation supprimée')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    }
                  }
                },
                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
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
            Stack(
              children: [
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
                if (!conversation.isRead && !isSelected)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
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
                    conversation.displayLastMessage ?? 'Start a conversation',
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String searchQuery = '';
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nouvelle conversation'),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  children: [
                    // Barre de recherche
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un contact...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Liste des contacts
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: ref.read(chatControllerProvider.notifier).getAvailableContacts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Erreur: ${snapshot.error}'));
                          }
                          
                          final allContacts = snapshot.data ?? [];
                          
                          // Filtrage local
                          final contacts = allContacts.where((c) {
                            final name = (c['nom'] ?? '').toString().toLowerCase();
                            final role = (c['role'] ?? '').toString().toLowerCase();
                            return name.contains(searchQuery) || role.contains(searchQuery);
                          }).toList();

                          if (contacts.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_off_outlined, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    searchQuery.isEmpty ? 'Aucun contact disponible' : 'Aucun résultat',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return ListView.separated(
                            itemCount: contacts.length,
                            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                            itemBuilder: (context, index) {
                              final contact = contacts[index];
                              final avatarUrl = contact['avatar_url'];
                              final name = contact['nom'] ?? 'Utilisateur'; // Fallback already handled in service but good to be safe
                              final role = contact['role'] ?? 'Autre';
                              final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
                              
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                  child: avatarUrl == null 
                                      ? Text(initial, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))
                                      : null,
                                ),
                                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(role, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                onTap: () async {
                                  Navigator.pop(context);
                                  try {
                                    // Utiliser getOrCreateConversation au lieu de createConversation direct
                                    // méthode exposée via le notifier comme createConversation
                                    await ref.read(chatControllerProvider.notifier).createConversation(contact['id']);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );
      },
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
