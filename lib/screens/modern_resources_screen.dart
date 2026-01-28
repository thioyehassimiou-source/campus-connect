import 'package:flutter/material.dart';

class ModernResourcesScreen extends StatefulWidget {
  const ModernResourcesScreen({super.key});

  @override
  State<ModernResourcesScreen> createState() => _ModernResourcesScreenState();
}

class _ModernResourcesScreenState extends State<ModernResourcesScreen> {
  String _selectedCategory = 'Toutes';
  String _selectedType = 'Tous';
  List<Map<String, dynamic>> _resources = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadResources() {
    setState(() {
      _resources = [
        {
          'id': '1',
          'title': 'Cours d\'Analyse Numérique',
          'description': 'Support de cours complet avec exemples et exercices',
          'type': 'PDF',
          'category': 'Cours',
          'size': '15.2 MB',
          'uploadDate': '15/12/2024',
          'downloads': 234,
          'author': 'Prof. Bernard',
          'course': 'MAT201',
          'level': 'L2',
          'tags': ['analyse', 'numérique', 'mathématiques'],
          'rating': 4.8,
          'isFavorite': false,
          'color': const Color(0xFF2563EB),
        },
        {
          'id': '2',
          'title': 'Exercices Corrigés - Algèbre',
          'description': 'Série d\'exercices avec corrections détaillées',
          'type': 'PDF',
          'category': 'Exercices',
          'size': '8.5 MB',
          'uploadDate': '10/12/2024',
          'downloads': 156,
          'author': 'Prof. Martin',
          'course': 'MAT101',
          'level': 'L1',
          'tags': ['algèbre', 'exercices', 'corrigés'],
          'rating': 4.6,
          'isFavorite': true,
          'color': const Color(0xFF10B981),
        },
        {
          'id': '3',
          'title': 'Vidéo - Introduction au Machine Learning',
          'description': 'Tutoriel vidéo sur les concepts fondamentaux du ML',
          'type': 'Vidéo',
          'category': 'Tutoriel',
          'size': '125.8 MB',
          'uploadDate': '08/12/2024',
          'downloads': 89,
          'author': 'Prof. Leroy',
          'course': 'INF301',
          'level': 'L3',
          'tags': ['machine learning', 'IA', 'vidéo'],
          'rating': 4.9,
          'isFavorite': false,
          'color': const Color(0xFF8B5CF6),
        },
        {
          'id': '4',
          'title': 'Scripts Python pour Data Science',
          'description': 'Collection de scripts Python pour l\'analyse de données',
          'type': 'Code',
          'category': 'Code',
          'size': '2.3 MB',
          'uploadDate': '05/12/2024',
          'downloads': 178,
          'author': 'Prof. Dubois',
          'course': 'PHY301',
          'level': 'M1',
          'tags': ['python', 'data science', 'scripts'],
          'rating': 4.7,
          'isFavorite': true,
          'color': const Color(0xFFF59E0B),
        },
        {
          'id': '5',
          'title': 'Formulaire de Physique Quantique',
          'description': 'Résumé des formules et concepts clés de physique quantique',
          'type': 'PDF',
          'category': 'Résumé',
          'size': '1.2 MB',
          'uploadDate': '01/12/2024',
          'downloads': 267,
          'author': 'Prof. Petit',
          'course': 'PHY201',
          'level': 'L2',
          'tags': ['physique', 'quantique', 'formules'],
          'rating': 4.5,
          'isFavorite': false,
          'color': const Color(0xFFEF4444),
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
              'Ressources Pédagogiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${_resources.length} ressources disponibles',
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
            icon: const Icon(Icons.upload, color: Color(0xFF2563EB)),
            onPressed: _showUploadDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF64748B)),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une ressource...',
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
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          
          // Filtres rapides
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
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
                        items: ['Toutes', 'Cours', 'Exercices', 'Tutoriel', 'Code', 'Résumé']
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
                        value: _selectedType,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                        items: ['Tous', 'PDF', 'Vidéo', 'Code', 'Audio']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type,
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
                            _selectedType = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Statistiques
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
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    '${_resources.length}',
                    Icons.folder,
                    const Color(0xFF2563EB),
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Favoris',
                    '${_resources.where((r) => r['isFavorite']).length}',
                    Icons.favorite,
                    const Color(0xFFEF4444),
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Téléchargements',
                    '${_resources.fold<int>(0, (sum, r) => sum + (r['downloads'] as int))}',
                    Icons.download,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des ressources
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredResources.length,
              itemBuilder: (context, index) {
                final resource = _filteredResources[index];
                return _buildResourceCard(resource);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload),
        label: const Text('Ajouter'),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredResources {
    var filtered = _resources;
    
    // Filtrer par recherche
    if (_searchController.text.isNotEmpty) {
      final searchLower = _searchController.text.toLowerCase();
      filtered = filtered.where((r) =>
          r['title'].toString().toLowerCase().contains(searchLower) ||
          r['description'].toString().toLowerCase().contains(searchLower) ||
          r['tags'].any((tag) => tag.toString().toLowerCase().contains(searchLower))
      ).toList();
    }
    
    // Filtrer par catégorie
    if (_selectedCategory != 'Toutes') {
      filtered = filtered.where((r) => r['category'] == _selectedCategory).toList();
    }
    
    // Filtrer par type
    if (_selectedType != 'Tous') {
      filtered = filtered.where((r) => r['type'] == _selectedType).toList();
    }
    
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

  Widget _buildResourceCard(Map<String, dynamic> resource) {
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: resource['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFileIcon(resource['type']),
                    color: resource['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              resource['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              resource['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                              color: resource['isFavorite'] ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                resource['isFavorite'] = !resource['isFavorite'];
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resource['description'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Métadonnées
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: resource['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    resource['type'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: resource['color'],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    resource['category'],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  resource['size'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Tags
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (resource['tags'] as List<String>).take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // Footer
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource['author'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${resource['course']} • ${resource['level']}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: const Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text(
                      resource['rating'].toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(Icons.download, size: 14, color: const Color(0xFF64748B)),
                    const SizedBox(width: 2),
                    Text(
                      resource['downloads'].toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Text(
                  resource['uploadDate'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _previewResource(resource),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: resource['color']),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Aperçu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: resource['color'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _downloadResource(resource),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: resource['color'],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Télécharger',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'Vidéo':
        return Icons.videocam;
      case 'Code':
        return Icons.code;
      case 'Audio':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une ressource'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Titre'),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ressource ajoutée avec succès!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres avancés'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Favoris uniquement'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Mes ressources'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Récemment ajoutées'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  void _previewResource(Map<String, dynamic> resource) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aperçu de ${resource['title']}...'),
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  void _downloadResource(Map<String, dynamic> resource) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement de ${resource['title']}...'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}
