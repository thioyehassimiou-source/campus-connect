import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/shared/models/message_model.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:campusconnect/core/services/chat_service.dart';
import 'package:campusconnect/screens/chat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  // ignore: unused_field
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _subscribeToConversations();
    _loadUsers();
  }

  void _subscribeToConversations() {
    ChatService.getConversations().listen((conversations) {
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    }, onError: (error) {
      print('Error loading conversations: $error');
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _loadUsers() async {
    try {
      // Fetch profiles excluding current user
      final response = await _supabase
          .from('profiles')
          .select()
          .neq('id', widget.user.id); // Assuming widget.user.id is the current auth id

      final List<dynamic> data = response as List<dynamic>;
      
      final users = data.map((json) {
         // Map Supabase profile to UserModel
         // UserModel expects 'full_name', but DB has 'nom'
         final Map<String, dynamic> map = Map.from(json);
         map['full_name'] = (json['nom'] ?? 'Utilisateur').toString().trim();
         // Handle role mapping if needed, UserModel expects lowercase 'student', 'teacher', etc or Enum string
         // DB has 'Student', 'Teacher' usually capped.
         // UserModel._parseRole handles it.
         return UserModel.fromMap(map);
      }).toList().cast<UserModel>();

      // Filter: If current user is student, remove other students
      if (widget.user.role == UserRole.student || widget.user.role == UserRole.etudiant) {
         users.removeWhere((u) => u.role == UserRole.student || u.role == UserRole.etudiant);
      }

      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  List<ConversationModel> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;

    return _conversations.where((conversation) {
      final displayName = conversation.displayName.toLowerCase();
      final lastMessage = (conversation.displayLastMessage ?? '').toLowerCase();
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
      // Check if conversation already exists in local list
      // Note: This logic assumes 1-on-1 and we have participants loaded.
      // Current ChatService.getConversations returns empty participants list for now to save bandwidth/logic
      // So checking internally might require fetching.
      // However, ChatService.createConversation handles creation cleanly.
      
      // Let's just create/get the conversation ID
      final conversationId = await ChatService.createConversation(otherUser.id);
      
      // Construct a temporary ConversationModel to navigate immediately
      // knowing that the stream will eventually update the list.
      final conversation = ConversationModel(
        id: conversationId,
        displayName: otherUser.fullName,
        participantIds: [widget.user.id, otherUser.id],
        isGroup: false,
        lastMessageTime: DateTime.now(),
      );

      if (!mounted) return;

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
      print('Error creating conversation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
               setState(() => _isLoading = true);
               _subscribeToConversations();
               _loadUsers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: TextField(
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        // Conversations List
        Expanded(
          flex: 2,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: _conversations.length,
            itemBuilder: (context, index) {
              final conversation = _conversations[index];
              return _buildConversationCard(conversation);
            },
          ),
        ),

        Divider(height: 1, color: Theme.of(context).dividerColor),

        // New Conversations (Users)
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              Text(
                'Nouvelles discussions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),

        Expanded(
          flex: 1,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _users.length > 5 ? 5 : _users.length, // Limit to 5 suggestions
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
          Container(
            color: Theme.of(context).cardColor,
            child: TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Conversations'),
                Tab(text: 'Utilisateurs'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _filteredConversations.isEmpty
                    ? Center(child: Text('Aucune conversation trouvée', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))
                    : ListView.builder(
                        itemCount: _filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conversation = _filteredConversations[index];
                          return _buildConversationCard(conversation);
                        },
                      ),
                _filteredUsers.isEmpty
                    ? Center(child: Text('Aucun utilisateur trouvé', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        Expanded(
          child: _users.isEmpty
              ? Center(child: Text('Aucun utilisateur disponible', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))
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
    // Determine if unread (mock logic for now as ConversationModel doesn't strictly have unreadCount mapped yet in ChatService)
    // We can add unreadCount logic later.
    const unreadCount = 0; 
    
    // Determine title color based on theme
    final titleColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            conversation.displayName.isNotEmpty
                ? conversation.displayName[0].toUpperCase()
                : 'C',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          conversation.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        subtitle: Text(
          conversation.displayLastMessage ?? 'Aucun message',
          style: TextStyle(color: subtitleColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(conversation.lastMessageTime),
              style: TextStyle(color: subtitleColor, fontSize: 12),
            ),
            const SizedBox(height: 4),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                user: widget.user,
                conversation: conversation,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final titleColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF10B981), // Green for new contacts
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Text(
                  user.fullName.isEmpty ? 'U' : user.fullName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          user.fullName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        subtitle: Text(
          _getRoleLabel(user.role),
          style: TextStyle(color: subtitleColor, fontSize: 12),
        ),
        trailing: IconButton(
          icon: Icon(Icons.message, color: Theme.of(context).primaryColor),
          onPressed: () => _createConversation(user),
        ),
        onTap: () => _createConversation(user),
      ),
    );
  }
  
  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
      case UserRole.etudiant:
        return 'Étudiant';
      case UserRole.teacher:
      case UserRole.enseignant:
        return 'Enseignant';
      case UserRole.admin:
      case UserRole.administrateur:
        return 'Administrateur';
      default:
        return 'Utilisateur';
    }
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
