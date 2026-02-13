import 'package:flutter/material.dart';
import '../services/messaging_service.dart';
import 'chat_screen.dart';
import '../models/messaging_models.dart';

class ContactSelectionScreen extends StatefulWidget {
  const ContactSelectionScreen({super.key});

  @override
  State<ContactSelectionScreen> createState() => _ContactSelectionScreenState();
}

class _ContactSelectionScreenState extends State<ContactSelectionScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await MessagingService.getAvailableContacts();
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _startChat(Map<String, dynamic> contact) async {
    try {
      final conversationId = await MessagingService.getOrCreateConversation(contact['id']);
      
      if (!mounted) return;

      final conversation = ChatConversation(
        id: conversationId,
        displayName: contact['nom'] ?? 'Chat',
        participantIds: [], // Will be fetched in chat screen if needed
        lastMessageTime: DateTime.now(),
        avatarUrl: contact['avatar_url'],
        type: ChatConversationType.private,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(conversation: conversation),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de démarrer la discussion: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredContacts = _contacts.where((c) {
      final nom = (c['nom'] ?? '').toString().toLowerCase();
      return nom.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sélectionner un contact', style: TextStyle(fontSize: 18)),
            if (!_isLoading)
              Text(
                '${_contacts.length} contacts',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_contacts.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('Aucun contact disponible'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredContacts.length + 2, // New contact options
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildActionTile(
                            icon: Icons.group_add,
                            label: 'Nouveau groupe',
                            onTap: () {},
                          );
                        }
                        if (index == 1) {
                          return _buildActionTile(
                            icon: Icons.person_add,
                            label: 'Nouveau contact',
                            onTap: () {},
                          );
                        }

                        final contact = filteredContacts[index - 2];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.primaryColor.withOpacity(0.1),
                            backgroundImage: contact['avatar_url'] != null
                                ? NetworkImage(contact['avatar_url'])
                                : null,
                            child: contact['avatar_url'] == null
                                ? Text(
                                    (contact['nom'] ?? 'U')[0].toUpperCase(),
                                    style: TextStyle(color: theme.primaryColor),
                                  )
                                : null,
                          ),
                          title: Text(
                            contact['nom'] ?? 'Utilisateur',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            contact['role'] ?? 'Étudiant',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          onTap: () => _startChat(contact),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF25D366),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }
}
