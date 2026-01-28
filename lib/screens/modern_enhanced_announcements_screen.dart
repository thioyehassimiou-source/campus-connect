import 'package:flutter/material.dart';

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
  String _selectedPriority = 'Toutes';
  List<Map<String, dynamic>> _announcements = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAnnouncements() {
    // Simulation de chargement des annonces selon le rôle
    setState(() {
      _announcements = [
        {
          'id': '1',
          'title': 'Réunion d\'information sur les stages',
          'content': 'Une réunion importante aura lieu le 15 janvier à 14h en amphi A pour présenter les opportunités de stage pour le semestre prochain. Tous les étudiants de L2 et L3 sont invités.',
          'author': 'Prof. Bernard',
          'authorRole': 'Enseignant',
          'authorAvatar': null,
          'category': 'Académique',
          'priority': 'Élevée',
          'date': '05/01/2025',
          'time': '10:30',
          'attachments': ['presentation_stages.pdf', 'entreprises_partenaires.pdf'],
          'likes': 45,
          'comments': 12,
          'views': 234,
          'isPinned': true,
          'targetAudience': ['L2', 'L3'],
          'tags': ['stage', 'carrière', 'L2', 'L3'],
        },
        {
          'id': '2',
          'title': 'Maintenance système informatique',
          'content': 'Le système informatique sera indisponible ce samedi de 8h à 12h pour maintenance. Veuillez sauvegarder votre travail régulièrement.',
          'author': 'Support Technique',
          'authorRole': 'Service',
          'authorAvatar': null,
          'category': 'Technique',
          'priority': 'Moyenne',
          'date': '04/01/2025',
          'time': '16:45',
          'attachments': [],
          'likes': 8,
          'comments': 3,
          'views': 156,
          'isPinned': false,
          'targetAudience': ['Tous'],
          'tags': ['maintenance', 'informatique'],
        },
        {
          'id': '3',
          'title': 'Nouvelles ressources bibliothèque',
          'content': 'La bibliothèque vient d\'acquérir 50 nouveaux ouvrages en informatique et mathématiques. Consultez le catalogue en ligne pour plus de détails.',
          'author': 'Bibliothèque',
          'authorRole': 'Service',
          'authorAvatar': null,
          'category': 'Ressources',
          'priority': 'Basse',
          'date': '03/01/2025',
          'time': '09:15',
          'attachments': ['catalogue_nouveautes.pdf'],
          'likes': 23,
          'comments': 5,
          'views': 89,
          'isPinned': false,
          'targetAudience': ['Tous'],
          'tags': ['bibliothèque', 'livres', 'ressources'],
        },
        {
          'id': '4',
          'title': 'Examen de Mathématiques reporté',
          'content': 'L\'examen de Mathématiques prévu le 20 janvier est reporté au 25 janvier même heure en raison d\'un conflit d\'emploi du temps.',
          'author': 'Administration',
          'authorRole': 'Service',
          'authorAvatar': null,
          'category': 'Académique',
          'priority': 'Élevée',
          'date': '02/01/2025',
          'time': '14:20',
          'attachments': ['nouvel_horaire.pdf'],
          'likes': 67,
          'comments': 18,
          'views': 445,
          'isPinned': true,
          'targetAudience': ['L1', 'L2'],
          'tags': ['examen', 'mathématiques', 'report'],
        },
        {
          'id': '5',
          'title': 'Appel à communications - Conférence étudiante',
          'content': 'Soumettez vos propositions pour la conférence étudiante annuelle qui se tiendra en mars. Thème : "Innovation et Technologie". Date limite : 31 janvier.',
          'author': 'BDE',
          'authorRole': 'Association',
          'authorAvatar': null,
          'category': 'Événement',
          'priority': 'Moyenne',
          'date': '01/01/2025',
          'time': '11:00',
          'attachments': ['appel_communications.pdf', 'formulaire_inscription.docx'],
          'likes': 34,
          'comments': 8,
          'views': 178,
          'isPinned': false,
          'targetAudience': ['Tous'],
          'tags': ['conférence', 'BDE', 'communication'],
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final canCreateAnnouncement = widget.isTeacher || widget.isAdmin;
    
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
              'Annonces',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${_announcements.length} publications',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (canCreateAnnouncement)
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
              onPressed: _showCreateAnnouncementDialog,
            ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF64748B)),
            onPressed: _showNotificationSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
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
            ),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une annonce...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
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
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Filtres
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                            items: ['Toutes', 'Académique', 'Technique', 'Ressources', 'Événement']
                                .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(
                                        category,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPriority,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                            items: ['Toutes', 'Élevée', 'Moyenne', 'Basse']
                                .map((priority) => DropdownMenuItem(
                                      value: priority,
                                      child: Text(
                                        priority,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPriority = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Statistiques rapides
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
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
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Épinglées',
                    '${_announcements.where((a) => a['isPinned']).length}',
                    Icons.push_pin,
                    const Color(0xFF2563EB),
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Urgentes',
                    '${_announcements.where((a) => a['priority'] == 'Élevée').length}',
                    Icons.priority_high,
                    const Color(0xFFEF4444),
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Non lues',
                    '${_announcements.where((a) => a['views'] < 100).length}',
                    Icons.mark_as_unread,
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des annonces
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredAnnouncements.length,
              itemBuilder: (context, index) {
                final announcement = _filteredAnnouncements[index];
                return _buildAnnouncementCard(announcement);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: canCreateAnnouncement
          ? FloatingActionButton.extended(
              onPressed: _showCreateAnnouncementDialog,
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle annonce'),
            )
          : null,
    );
  }

  List<Map<String, dynamic>> get _filteredAnnouncements {
    var filtered = _announcements;
    
    // Filtrer par recherche
    if (_searchController.text.isNotEmpty) {
      final searchLower = _searchController.text.toLowerCase();
      filtered = filtered.where((a) =>
          a['title'].toString().toLowerCase().contains(searchLower) ||
          a['content'].toString().toLowerCase().contains(searchLower) ||
          a['author'].toString().toLowerCase().contains(searchLower)
      ).toList();
    }
    
    // Filtrer par catégorie
    if (_selectedCategory != 'Toutes') {
      filtered = filtered.where((a) => a['category'] == _selectedCategory).toList();
    }
    
    // Filtrer par priorité
    if (_selectedPriority != 'Toutes') {
      filtered = filtered.where((a) => a['priority'] == _selectedPriority).toList();
    }
    
    // Trier : épinglées d'abord, puis par date
    filtered.sort((a, b) {
      if (a['isPinned'] && !b['isPinned']) return -1;
      if (!a['isPinned'] && b['isPinned']) return 1;
      return b['date'].compareTo(a['date']);
    });
    
    return filtered;
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
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
        border: announcement['isPinned']
            ? Border.all(color: const Color(0xFF2563EB), width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                if (announcement['isPinned'])
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.push_pin,
                      color: Color(0xFF2563EB),
                      size: 16,
                    ),
                  ),
                if (announcement['isPinned']) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    announcement['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: announcement['isPinned']
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(announcement['priority']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    announcement['priority'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getPriorityColor(announcement['priority']),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Métadonnées
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getRoleColor(announcement['authorRole']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getRoleIcon(announcement['authorRole']),
                    color: _getRoleColor(announcement['authorRole']),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement['author'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${announcement['authorRole']} • ${announcement['category']}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${announcement['date']} • ${announcement['time']}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Contenu
            Text(
              announcement['content'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Tags
            if (announcement['tags'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: (announcement['tags'] as List<String>).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            
            // Pièces jointes
            if (announcement['attachments'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.attach_file,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${announcement['attachments'].length} pièce(s) jointe(s)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Actions et statistiques
            Row(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.visibility,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      announcement['views'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      announcement['likes'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      announcement['comments'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _viewAnnouncementDetails(announcement),
                  child: const Text(
                    'Lire la suite',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Élevée':
        return const Color(0xFFEF4444);
      case 'Moyenne':
        return const Color(0xFFF59E0B);
      case 'Basse':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Enseignant':
        return const Color(0xFF10B981);
      case 'Service':
        return const Color(0xFF2563EB);
      case 'Association':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Enseignant':
        return Icons.person;
      case 'Service':
        return Icons.business;
      case 'Association':
        return Icons.groups;
      default:
        return Icons.person;
    }
  }

  void _showCreateAnnouncementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Créer une annonce'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Contenu',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Annonce créée avec succès!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              child: const Text('Publier'),
            ),
          ],
        );
      },
    );
  }

  void _viewAnnouncementDetails(Map<String, dynamic> announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AnnouncementDetailsScreen(announcement: announcement),
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Paramètres de notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Annonces épinglées'),
                subtitle: const Text('Recevoir une notification pour les annonces importantes'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Nouvelles annonces'),
                subtitle: const Text('Être notifié des nouvelles publications'),
                value: true,
                onChanged: (value) {},
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

class _AnnouncementDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const _AnnouncementDetailsScreen({super.key, required this.announcement});

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
        title: const Text(
          'Détails de l\'annonce',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte principale
            Container(
              padding: const EdgeInsets.all(20),
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et priorité
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          announcement['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          announcement['priority'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Métadonnées
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement['author'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '${announcement['authorRole']} • ${announcement['category']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${announcement['date']} • ${announcement['time']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Contenu
                  const Text(
                    'Contenu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    announcement['content'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  
                  // Tags
                  if (announcement['tags'].isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (announcement['tags'] as List<String>).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  // Pièces jointes
                  if (announcement['attachments'].isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Pièces jointes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(announcement['attachments'] as List<String>).map((file) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.insert_drive_file,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                file,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download, color: Color(0xFF2563EB)),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Statistiques
            Container(
              padding: const EdgeInsets.all(16),
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.visibility,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        announcement['views'].toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Text(
                        'Vues',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.thumb_up,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        announcement['likes'].toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Text(
                        'J\'aime',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.chat_bubble,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        announcement['comments'].toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Text(
                        'Commentaires',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
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
}
