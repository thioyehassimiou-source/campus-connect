import 'package:flutter/material.dart';

class ModernStudentMessagingScreen extends StatefulWidget {
  const ModernStudentMessagingScreen({super.key});

  @override
  State<ModernStudentMessagingScreen> createState() => _ModernStudentMessagingScreenState();
}

class _ModernStudentMessagingScreenState extends State<ModernStudentMessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _selectedConversation;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _loadConversations() {
    // Simulation de chargement des conversations pour un étudiant
    setState(() {
      _conversations = [
        {
          'id': '1',
          'name': 'Prof. Bernard',
          'avatar': null,
          'lastMessage': 'N\'hésitez pas si vous avez d\'autres questions',
          'time': '14:30',
          'unread': 1,
          'isOnline': false,
          'role': 'Enseignant',
          'course': 'Mathématiques',
        },
        {
          'id': '2',
          'name': 'Prof. Leroy',
          'avatar': null,
          'lastMessage': 'Le projet est à rendre pour vendredi',
          'time': '12:15',
          'unread': 0,
          'isOnline': true,
          'role': 'Enseignant',
          'course': 'Informatique',
        },
        {
          'id': '3',
          'name': 'Groupe L2 Info',
          'avatar': null,
          'lastMessage': 'Bob: Qui veut réviser ensemble pour l\'exam ?',
          'time': 'Hier',
          'unread': 5,
          'isOnline': true,
          'role': 'Groupe',
          'memberCount': 45,
        },
        {
          'id': '4',
          'name': 'Support Scolarité',
          'avatar': null,
          'lastMessage': 'Votre demande de bourse a été traitée',
          'time': 'Hier',
          'unread': 2,
          'isOnline': false,
          'role': 'Service',
        },
        {
          'id': '5',
          'name': 'Claire Dubois',
          'avatar': null,
          'lastMessage': 'Merci pour les notes de cours !',
          'time': '2 jours',
          'unread': 0,
          'isOnline': true,
          'role': 'Étudiant',
        },
      ];
      
      _selectedConversation = _conversations.first;
      _loadMessages(_selectedConversation!['id']);
    });
  }

  void _loadMessages(String conversationId) {
    // Simulation de chargement des messages
    setState(() {
      _messages = [
        {
          'id': '1',
          'sender': 'Prof. Bernard',
          'content': 'Bonjour Alice, j\'ai reçu votre devoir',
          'time': '14:00',
          'isMe': false,
          'avatar': null,
        },
        {
          'id': '2',
          'sender': 'Moi',
          'content': 'Bonjour Professeur ! J\'espère qu\'il est correct',
          'time': '14:05',
          'isMe': true,
          'avatar': null,
        },
        {
          'id': '3',
          'sender': 'Prof. Bernard',
          'content': 'Très bon travail ! Vous avez bien compris les concepts. J\'ai juste quelques petites remarques à améliorer.',
          'time': '14:10',
          'isMe': false,
          'avatar': null,
        },
        {
          'id': '4',
          'sender': 'Moi',
          'content': 'Merci beaucoup ! Quelles sont les remarques ?',
          'time': '14:15',
          'isMe': true,
          'avatar': null,
        },
        {
          'id': '5',
          'sender': 'Prof. Bernard',
          'content': 'Regardez les commentaires que j\'ai ajoutés dans le document. N\'hésitez pas si vous avez d\'autres questions',
          'time': '14:30',
          'isMe': false,
          'avatar': null,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Messages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${_conversations.where((c) => c['unread'] > 0).length} non lus',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF64748B)),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Row(
        children: [
          // Liste des conversations
          Container(
            width: 350,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Barre de recherche
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher une conversation...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Filtres rapides
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Tous',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Non lus',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Enseignants',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Liste des conversations
                Expanded(
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      final isSelected = _selectedConversation?['id'] == conversation['id'];
                      return _buildConversationCard(conversation, isSelected);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Zone de conversation
          Expanded(
            child: _selectedConversation != null
                ? _buildConversationArea()
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conversation, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedConversation = conversation;
          _loadMessages(conversation['id']);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFE2E8F0),
              width: isSelected ? 0 : 1,
            ),
            left: isSelected
                ? const BorderSide(color: Color(0xFF2563EB), width: 3)
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
                    color: _getRoleColor(conversation['role']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: conversation['avatar'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            conversation['avatar'],
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          _getRoleIcon(conversation['role']),
                          color: _getRoleColor(conversation['role']),
                          size: 24,
                        ),
                ),
                if (conversation['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        conversation['time'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (conversation['course'] != null)
                    Text(
                      conversation['course'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation['lastMessage'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation['unread'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation['unread'].toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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

  Widget _buildConversationArea() {
    return Column(
      children: [
        // Header de la conversation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getRoleColor(_selectedConversation!['role']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getRoleIcon(_selectedConversation!['role']),
                  color: _getRoleColor(_selectedConversation!['role']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedConversation!['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _selectedConversation!['role'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_selectedConversation!['course'] != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${_selectedConversation!['course']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                onPressed: _showConversationOptions,
              ),
            ],
          ),
        ),
        
        // Messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),
        
        // Zone de saisie
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file, color: Color(0xFF64748B)),
                onPressed: _attachFile,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Écrire un message...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF2563EB)),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF2563EB),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message['sender'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message['content'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message['time'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF10B981),
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFF2563EB),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sélectionnez une conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choisissez une conversation pour commencer à discuter',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Étudiant':
        return const Color(0xFF2563EB);
      case 'Enseignant':
        return const Color(0xFF10B981);
      case 'Groupe':
        return const Color(0xFFF59E0B);
      case 'Service':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Étudiant':
        return Icons.school;
      case 'Enseignant':
        return Icons.person;
      case 'Groupe':
        return Icons.groups;
      case 'Service':
        return Icons.business;
      default:
        return Icons.person;
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'id': (_messages.length + 1).toString(),
        'sender': 'Moi',
        'content': _messageController.text,
        'time': DateTime.now().toString().substring(11, 16),
        'isMe': true,
        'avatar': null,
      });
      _messageController.clear();
    });
  }

  void _attachFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de pièce jointe à implémenter'),
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rechercher'),
          content: const TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher des messages ou conversations...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Rechercher'),
            ),
          ],
        );
      },
    );
  }

  void _showConversationOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_selectedConversation!['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedConversation!['role'] == 'Enseignant')
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Voir le profil'),
                  subtitle: Text(_selectedConversation!['course'] ?? ''),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text('Désactiver les notifications'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              if (_selectedConversation!['role'] != 'Service')
                ListTile(
                  leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                  title: const Text('Supprimer la conversation', style: TextStyle(color: Color(0xFFEF4444))),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
