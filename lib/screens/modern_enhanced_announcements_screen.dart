import 'package:flutter/material.dart';
import 'package:campusconnect/core/services/announcement_service.dart';
import 'package:campusconnect/services/ai_assistant_service.dart';

class ModernEnhancedAnnouncementsScreen extends StatefulWidget {
  final bool isTeacher;
  final bool isAdmin;
  
  const ModernEnhancedAnnouncementsScreen({
    super.key,
    this.isTeacher = false,
    this.isAdmin = false,
  });

  @override
  State<ModernEnhancedAnnouncementsScreen> createState() => _ModernEnhancedAnnouncementsScreenState();
}

class _ModernEnhancedAnnouncementsScreenState extends State<ModernEnhancedAnnouncementsScreen> {
  String _selectedCategory = 'Toutes';
  late Future<List<Announcement>> _announcementsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshAnnouncements();
  }

  void _refreshAnnouncements() {
    setState(() {
      _announcementsFuture = AnnouncementService.getAnnouncements();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canCreateAnnouncement = widget.isTeacher || widget.isAdmin;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Annonces',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
            onPressed: _refreshAnnouncements,
          ),
          if (canCreateAnnouncement)
            IconButton(
              icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
              onPressed: _showCreateAnnouncementDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filtres et Recherche
          _buildFilters(),

          // Liste des annonces
          Expanded(
            child: FutureBuilder<List<Announcement>>(
              future: _announcementsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  // Fallback silencieux ou message d'erreur
                  return Center(child: Text('Erreur chargement: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Aucune annonce pour le moment.", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)));
                }

                final announcements = _filterAnnouncements(snapshot.data!);

                if (announcements.isEmpty) {
                   return Center(child: Text("Aucune annonce ne correspond à votre recherche.", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    return _buildAnnouncementCard(announcements[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: canCreateAnnouncement
          ? FloatingActionButton.extended(
              onPressed: _showCreateAnnouncementDialog,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle annonce'),
            )
          : null,
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
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
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Toutes', 'General', 'Urgent', 'Cours', 'Examens']
                  .map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Theme.of(context).cardColor,
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Announcement> _filterAnnouncements(List<Announcement> list) {
    return list.where((a) {
      final matchessearch = _searchController.text.isEmpty ||
          a.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          a.content.toLowerCase().contains(_searchController.text.toLowerCase());
          
      final matchesCategory = _selectedCategory == 'Toutes' || a.category == _selectedCategory;
      
      return matchessearch && matchesCategory;
    }).toList();
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: announcement.category == 'Urgent' 
            ? Border.all(color: const Color(0xFFEF4444), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(announcement.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  announcement.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _getCategoryColor(announcement.category),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                announcement.timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            announcement.content,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                child: Icon(Icons.person, size: 12, color: Theme.of(context).iconTheme.color),
              ),
              const SizedBox(width: 8),
              Text(
                announcement.authorName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Urgent': return const Color(0xFFEF4444);
      case 'Examens': return const Color(0xFFF59E0B);
      case 'Cours': return const Color(0xFF2563EB);
      default: return const Color(0xFF64748B);
    }
  }

  void _showCreateAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String category = 'General';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Nouvelle annonce'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Titre'),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: ['General', 'Urgent', 'Cours', 'Examens']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setStateDialog(() => category = v!),
                      decoration: const InputDecoration(labelText: 'Catégorie'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Contenu',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final topicController = TextEditingController();
                          final shouldGenerate = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Générer avec l\'IA'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Décrivez brièvement le sujet de l\'annonce :'),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: topicController,
                                    decoration: const InputDecoration(
                                      hintText: 'Ex: Retard cours de Maths L2...',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Annuler'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(context, true),
                                  icon: const Icon(Icons.auto_awesome),
                                  label: const Text('Générer'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6366F1), // Indigo/IA
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (shouldGenerate == true && topicController.text.isNotEmpty) {
                            // Afficher chargement
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('L\'IA rédige votre annonce... 🤖')),
                              );
                            }

                            try {
                              final aiService = AIAssistantService();
                              final response = await aiService.sendMessage(
                                message: "Rédige une annonce universitaire claire, professionnelle et engageante pour des étudiants sur ce sujet : '${topicController.text}'. RETOURNE UNIQUEMENT LE CONTENU DU CORPS DE L'ANNONCE, SANS TITRE NI FORMULES DE POLITESSE TROP LONGUES.",
                                context: "Tu es un assistant administratif universitaire efficace.",
                              );

                              if (response['success'] == true && response['response'] != null) {
                                String generatedText = response['response'];
                                // Nettoyage basique si besoin
                                generatedText = generatedText.replaceAll('"', '').trim();
                                
                                setStateDialog(() {
                                  // Suggestion de titre simple basée sur le topic
                                  if (titleController.text.isEmpty) {
                                    titleController.text = "Information Importante"; // Fallback
                                  }
                                  contentController.text = generatedText;
                                });
                              } else {
                                throw Exception(response['error'] ?? 'Réponse vide');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erreur IA: $e')),
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('Rédiger avec l\'IA'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      // Fermer le dialogue d'abord
                      Navigator.pop(context);
                      
                      await AnnouncementService.createAnnouncement(
                        title: titleController.text,
                        content: contentController.text,
                        category: category,
                      );
                      
                      _refreshAnnouncements();
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Annonce publiée !')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Publier'),
              ),
            ],
          );
        }
      ),
    );
  }
}
