import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/core/services/resource_service.dart';
import 'package:campusconnect/controllers/resource_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class ModernResourcesScreen extends ConsumerStatefulWidget {
  final bool isTeacher;
  const ModernResourcesScreen({super.key, this.isTeacher = false});

  @override
  ConsumerState<ModernResourcesScreen> createState() => _ModernResourcesScreenState();
}

class _ModernResourcesScreenState extends ConsumerState<ModernResourcesScreen> {
  String _selectedCategory = 'Toutes';
  String _selectedType = 'Tous';
  late Future<List<Resource>> _resourcesFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Géré par Riverpod
  }

  void _refreshResources() {
    ref.invalidate(allResourcesProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ressources Pédagogiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Text(
              'Accès aux supports de cours',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.isTeacher)
            IconButton(
              icon: Icon(Icons.upload, color: Theme.of(context).primaryColor),
              onPressed: _showUploadDialog,
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
            onPressed: _refreshResources,
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Theme.of(context).textTheme.bodyMedium?.color),
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Rechercher une ressource...',
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).iconTheme.color,
                  size: 20,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
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
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
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
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedType,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                        items: ['Tous', 'PDF', 'VIDEO', 'LINK']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
          
          
          // Liste des ressources
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final resourcesAsync = ref.watch(allResourcesProvider);
                
                return resourcesAsync.when(
                  data: (data) {
                    var resources = List<Resource>.from(data);
                    
                    // Filtrage local
                    if (_searchController.text.isNotEmpty) {
                      final query = _searchController.text.toLowerCase();
                      resources = resources.where((r) => 
                        r.title.toLowerCase().contains(query) || 
                        r.description.toLowerCase().contains(query)).toList();
                    }
                    if (_selectedType != 'Tous') {
                      resources = resources.where((r) => r.type == _selectedType).toList();
                    }

                    if (resources.isEmpty) {
                      return const Center(child: Text('Aucune ressource trouvée.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: resources.length,
                      itemBuilder: (context, index) {
                        return _buildResourceCard(resources[index]);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Erreur: $e')),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isTeacher ? FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload),
        label: const Text('Ajouter'),
      ) : null,
    );
  }

  Widget _buildResourceCard(Resource resource) {
    Color color = const Color(0xFF2563EB); // Default blue
    if (resource.type == 'PDF') color = const Color(0xFFEF4444); // Red
    if (resource.type == 'VIDEO') color = const Color(0xFF8B5CF6); // Purple
    if (resource.type == 'LINK') color = const Color(0xFF10B981); // Green

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFileIcon(resource.type),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resource.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    resource.type,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    resource.subject,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${resource.uploadDate.day}/${resource.uploadDate.month}/${resource.uploadDate.year}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Footer
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.authorName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openUrl(resource.url),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: color),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Ouvrir',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
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
      case 'VIDEO':
        return Icons.videocam;
      case 'LINK':
        return Icons.link;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : L\'URL de ce document est vide.')),
      );
      return;
    }
    
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible d\'ouvrir $url')));
        }
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'ouverture : $e')));
      }
    }
  }

  void _showUploadDialog() {
    String title = '';
    String description = '';
    String url = '';
    String type = 'PDF';
    String subject = 'General';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une ressource'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Titre'),
                onChanged: (v) => title = v,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onChanged: (v) => description = v,
              ),
               const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'URL (Lien vers fichier/vidéo)'),
                onChanged: (v) => url = v,
              ),
              const SizedBox(height: 16),
               TextField(
                decoration: const InputDecoration(labelText: 'Matière'),
                onChanged: (v) => subject = v,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                items: ['PDF', 'VIDEO', 'LINK'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => type = v!,
                decoration: const InputDecoration(labelText: 'Type'),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (title.isNotEmpty && url.isNotEmpty) {
                 try {
                  await ref.read(resourceControllerProvider.notifier).addResource(
                    title: title,
                    description: description,
                    url: url,
                    type: type,
                    subject: subject,
                    ref: ref,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ressource ajoutée avec succès!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
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
}
