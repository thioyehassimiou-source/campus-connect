import 'package:flutter/material.dart';
import 'package:campusconnect/core/services/announcement_service.dart';
import 'package:campusconnect/core/services/profile_service.dart';

class ModernAnnouncementsScreen extends StatefulWidget {
  const ModernAnnouncementsScreen({super.key});

  @override
  State<ModernAnnouncementsScreen> createState() => _ModernAnnouncementsScreenState();
}

class _ModernAnnouncementsScreenState extends State<ModernAnnouncementsScreen> {
  String selectedCategory = 'Toutes';
  bool isTeacherOrAdmin = true; // Simuler le rôle de l'utilisateur
  late Future<List<Announcement>> _announcementsFuture;
  
  final List<String> categories = ['Toutes', 'Académique', 'Administratif', 'Vie Étudiante'];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    setState(() {
      _announcementsFuture = AnnouncementService.getAnnouncements();
    });
  }

  List<Announcement> _filterAnnouncements(List<Announcement> announcements) {
    if (selectedCategory == 'Toutes') {
      return announcements;
    }
    return announcements.where((a) => a.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Annonces',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Actualités du campus',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (isTeacherOrAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FloatingActionButton(
                onPressed: () {
                  _showCreateAnnouncementDialog();
                },
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                child: Icon(Icons.add, size: 20),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filtres par catégorie
          _buildCategoryFilter(),
          
          // Liste des annonces
          Expanded(
            child: FutureBuilder<List<Announcement>>(
              future: _announcementsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Erreur de chargement des annonces'),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadAnnouncements,
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                
                final allAnnouncements = snapshot.data ?? [];
                final filteredAnnouncements = _filterAnnouncements(allAnnouncements);
                
                if (filteredAnnouncements.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucune annonce disponible',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredAnnouncements.length,
                  itemBuilder: (context, index) {
                    final announcement = filteredAnnouncements[index];
                    return _buildAnnouncementCard(announcement);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catégories',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    final priority = announcement.priority;
    final category = announcement.category;
    final date = announcement.createdAt;
    final isPinned = announcement.isPinned;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isPinned ? Border.all(
          color: const Color(0xFF2563EB).withOpacity(0.3),
          width: 1,
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de l'annonce
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Première ligne : titre et badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isPinned)
                      Container(
                        margin: const EdgeInsets.only(right: 8, top: 2),
                        child: Icon(
                          Icons.push_pin,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Deuxième ligne : badges et métadonnées
                Row(
                  children: [
                    // Badge catégorie
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(category),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Badge priorité
                    if (priority != 'Basse')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getPriorityIcon(priority),
                              size: 10,
                              color: _getPriorityColor(priority),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              priority,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: _getPriorityColor(priority),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Contenu de l'annonce
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              announcement.content,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Pied de l'annonce
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                // Auteur
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      announcement.authorName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Actions
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                  onSelected: (value) {
                    if (value == 'pin') {
                      _togglePin(announcement.id, announcement.isPinned);
                    } else if (value == 'share') {
                      _shareAnnouncement(announcement);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'pin',
                      child: Row(
                        children: [
                          Icon(
                            isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                            size: 16,
                            color: const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPinned ? 'Désépingler' : 'Épingler',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 16, color: Color(0xFF2563EB)),
                          SizedBox(width: 8),
                          Text('Partager', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Académique':
        return const Color(0xFF2563EB);
      case 'Administratif':
        return const Color(0xFF10B981);
      case 'Vie Étudiante':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Urgente':
        return const Color(0xFFEF4444);
      case 'Haute':
        return const Color(0xFFF59E0B);
      case 'Moyenne':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'Urgente':
        return Icons.priority_high;
      case 'Haute':
        return Icons.warning;
      case 'Moyenne':
        return Icons.info;
      default:
        return Icons.info_outline;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _togglePin(String announcementId, bool currentStatus) async {
    try {
      await AnnouncementService.togglePin(announcementId, currentStatus);
      _loadAnnouncements(); // Reload to show updated status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentStatus ? 'Annonce désépinglée' : 'Annonce épinglée')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _shareAnnouncement(Announcement announcement) {
    // Implémenter le partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage en cours de développement'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCreateAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = 'Académique';
    String selectedPriority = 'Moyenne';
    String selectedScope = 'license'; // Par défaut à la licence
    String? selectedNiveau;
    
    // On récupère le profil pour présélectionner les valeurs
    ProfileService.getCurrentUserProfile().then((profile) {
      if (profile != null) {
        selectedNiveau = profile['niveau'];
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Créer une annonce'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Titre'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(labelText: 'Contenu'),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(labelText: 'Catégorie'),
                    items: categories.where((c) => c != 'Toutes').map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) => setDialogState(() => selectedCategory = value!),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: InputDecoration(labelText: 'Priorité'),
                    items: ['Basse', 'Moyenne', 'Haute', 'Urgente'].map((p) {
                      return DropdownMenuItem(value: p, child: Text(p));
                    }).toList(),
                    onChanged: (value) => setDialogState(() => selectedPriority = value!),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedScope,
                    decoration: InputDecoration(labelText: 'Visibilité (Scope)'),
                    items: [
                      DropdownMenuItem(value: 'license', child: Text('Ma licence')),
                      DropdownMenuItem(value: 'department', child: Text('Mon département')),
                      DropdownMenuItem(value: 'university', child: Text('Toute l\'université (Admin)')),
                    ],
                    onChanged: (value) => setDialogState(() => selectedScope = value!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty || contentController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez remplir tous les champs')),
                    );
                    return;
                  }

                  try {
                    final profile = await ProfileService.getCurrentUserProfile();
                    await AnnouncementService.createAnnouncement(
                      title: titleController.text,
                      content: contentController.text,
                      category: selectedCategory,
                      priority: selectedPriority,
                      scope: selectedScope,
                      departmentId: profile?['department_id']?.toString(),
                      niveau: selectedScope == 'license' ? (profile?['niveau']) : null,
                      facultyId: profile?['faculty_id']?.toString(),
                    );
                    Navigator.of(context).pop();
                    _loadAnnouncements(); // Reload to show new announcement
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Annonce créée avec succès')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e')),
                    );
                  }
                },
                child: Text('Créer'),
              ),
            ],
          ),
        );
      },
    );
  }
}
