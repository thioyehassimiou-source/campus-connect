import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/shared/models/message_model.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:campusconnect/core/services/firebase_service.dart';
import 'package:campusconnect/screens/chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  final UserModel user;

  const MessagesScreen({super.key, required this.user});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ConversationModel> _conversations = [];
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _loadUsers();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);

    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('conversations')
          .where('participants', arrayContains: widget.user.id)
          .orderBy('lastMessageTime', descending: true)
          .get();

      final conversations = querySnapshot.docs
          .map((doc) => ConversationModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadUsers() async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('users')
          .where('id', isNotEqualTo: widget.user.id)
          .get();

      final users = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _users = users;
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  List<ConversationModel> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;

    return _conversations.where((conversation) {
      final displayName = conversation.displayName.toLowerCase();
      final lastMessage = conversation.displayLastMessage.toLowerCase();
      return displayName.contains(_searchQuery.toLowerCase()) ||
             lastMessage.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<UserModel> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;

    return _users.where((user) {
      final fullName = user.fullName.toLowerCase();
      final email = user.email.toLowerCase();
      return fullName.contains(_searchQuery.toLowerCase()) ||
             email.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _createConversation(UserModel otherUser) async {
    try {
      // Check if conversation already exists
      final existingConversation = _conversations.firstWhere(
        (conv) => !conv.isGroup && 
                 conv.participants.contains(widget.user.id) && 
                 conv.participants.contains(otherUser.id),
        orElse: () => ConversationModel(
          id: '',
          participants: [widget.user.id, otherUser.id],
          unreadCount: 0,
          isGroup: false,
        ),
      );

      if (existingConversation.id.isNotEmpty) {
        // Conversation already exists, navigate to it
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              user: widget.user,
              conversation: existingConversation,
              otherUser: otherUser,
            ),
          ),
        );
        return;
      }

      // Create new conversation
      final conversationId = DateTime.now().millisecondsSinceEpoch.toString();
      final conversation = ConversationModel(
        id: conversationId,
        userId1: widget.user.id,
        userId2: otherUser.id,
        participants: [widget.user.id, otherUser.id],
        unreadCount: 0,
        isGroup: false,
      );

      await FirebaseService.firestore
          .collection('conversations')
          .doc(conversationId)
          .set(conversation.toMap());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            user: widget.user,
            conversation: conversation,
            otherUser: otherUser,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher des conversations ou utilisateurs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchQuery.isEmpty
                    ? _buildConversationsList()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    if (_conversations.isEmpty) {
      return _buildNewUsersList();
    }

    return Column(
      children: [
        // Existing Conversations
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: _conversations.length,
            itemBuilder: (context, index) {
              final conversation = _conversations[index];
              return _buildConversationCard(conversation);
            },
          ),
        ),

        const Divider(height: 32),

        // New Conversations
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Nouvelles conversations',
                style: AppTheme.subheadingStyle,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),

        Expanded(
          flex: 1,
          child: ListView.builder(
            itemCount: _users.length > 3 ? 3 : _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return _buildUserCard(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Conversations'),
              Tab(text: 'Utilisateurs'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _filteredConversations.isEmpty
                    ? const Center(child: Text('Aucune conversation trouvée'))
                    : ListView.builder(
                        itemCount: _filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conversation = _filteredConversations[index];
                          return _buildConversationCard(conversation);
                        },
                      ),
                _filteredUsers.isEmpty
                    ? const Center(child: Text('Aucun utilisateur trouvé'))
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserCard(user);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewUsersList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Commencer une nouvelle conversation',
            style: AppTheme.subheadingStyle,
          ),
        ),
        Expanded(
          child: _users.isEmpty
              ? const Center(child: Text('Aucun utilisateur disponible'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return _buildUserCard(user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildConversationCard(ConversationModel conversation) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            conversation.displayName.isNotEmpty
                ? conversation.displayName[0].toUpperCase()
                : 'C',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          conversation.displayName,
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          conversation.displayLastMessage,
          style: AppTheme.captionStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (conversation.lastMessageTime != null)
              Text(
                _formatTime(conversation.lastMessageTime!),
                style: AppTheme.captionStyle,
              ),
            const SizedBox(height: 4),
            if (conversation.unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to chat screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat bientôt disponible')),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Text(
                  user.firstName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          user.fullName,
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          user.role.name.toUpperCase(),
          style: AppTheme.captionStyle,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.message),
          onPressed: () => _createConversation(user),
        ),
        onTap: () => _createConversation(user),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE', 'fr_FR').format(dateTime);
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
