import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/messaging_models.dart';
import '../controllers/messaging_providers.dart';
import '../widgets/conversation_tile.dart';
import 'chat_screen.dart';
import 'contact_selection_screen.dart';

class MessagingListScreen extends ConsumerStatefulWidget {
  const MessagingListScreen({super.key});

  @override
  ConsumerState<MessagingListScreen> createState() => _MessagingListScreenState();
}

class _MessagingListScreenState extends ConsumerState<MessagingListScreen> {
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final conversationsAsync = ref.watch(chatConversationsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1F2C33) : theme.primaryColor,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text(
                'CampusConnect Chat',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'settings') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ouverture des paramètres...')),
                );
              } else if (value == 'group') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Création de groupe bientôt disponible')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'group', child: Text('Nouveau groupe')),
              const PopupMenuItem(value: 'broadcast', child: Text('Nouvelle diffusion')),
              const PopupMenuItem(value: 'settings', child: Text('Paramètres')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: isDark ? const Color(0xFF111B21) : Colors.white,
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Rechercher une discussion',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: isDark ? const Color(0xFF202C33) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                final filtered = conversations.where((c) {
                  return c.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune conversation trouvée',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final conversation = filtered[index];
                    return ConversationTile(
                      conversation: conversation,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(conversation: conversation),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactSelectionScreen()),
          );
        },
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
