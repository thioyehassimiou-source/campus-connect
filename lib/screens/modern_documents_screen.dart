import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/core/services/resource_service.dart';
import 'package:campusconnect/core/services/download_service.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/controllers/resource_providers.dart';
import 'package:intl/intl.dart';

class ModernDocumentsScreen extends ConsumerStatefulWidget {
  const ModernDocumentsScreen({super.key});

  @override
  ConsumerState<ModernDocumentsScreen> createState() => _ModernDocumentsScreenState();
}

class _ModernDocumentsScreenState extends ConsumerState<ModernDocumentsScreen> {
  String selectedMatiere = 'Toutes';
  String selectedFiliere = 'Toutes';
  String searchQuery = '';
  // Removed local data
  
  // List used for upload dialog
  final List<String> matieres = [
    'Toutes', 'Mathématiques', 'Physique', 'Informatique', 'Chimie', 
    'Anglais', 'Économie', 'Sport', 'Projet'
  ];
  
  final List<String> filieres = [
    'Toutes', 'L1 Info', 'L2 Info', 'L3 Info', 'M1 Info', 'M2 Info',
    'L1 Maths', 'L2 Maths', 'L3 Maths'
  ];

  // Hardcoded documents removed


  @override
  void initState() {
    super.initState();
  }

  void _refreshData() {
    ref.invalidate(allResourcesProvider);
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
              'Documents Pédagogiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Text(
              'Bibliothèque numérique',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final resourcesAsync = ref.watch(allResourcesProvider);
          
          return resourcesAsync.when(
            data: (data) {
              // Extraire les matières uniques des données
              final uniqueSubjects = data.map((r) => r.subject).toSet().toList()..sort();
              final availableMatieres = ['Toutes', ...uniqueSubjects];

              var docs = List<Resource>.from(data);
              
              // Filtrage local
              if (selectedMatiere != 'Toutes') {
                docs = docs.where((d) => d.subject == selectedMatiere).toList();
              }
              if (searchQuery.isNotEmpty) {
                final query = searchQuery.toLowerCase();
                docs = docs.where((d) => 
                  d.title.toLowerCase().contains(query) || 
                  d.description.toLowerCase().contains(query)
                ).toList();
              }

              return Column(
                children: [
                  // Filtres dynamiques
                  Container(
                    color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterSection('Matière', availableMatieres, selectedMatiere, (value) {
                          setState(() {
                            selectedMatiere = value;
                          });
                        }),
                        const SizedBox(height: 16),
                         // Note: Filières est toujours statique car non présent dans Resource, 
                         // mais on pourrait l'ajouter si dispo dans le futur.
                         // Pour l'instant on garde la liste statique ou on la retire si inutile.
                        _buildFilterSection('Filière', filieres, selectedFiliere, (value) {
                          setState(() {
                            selectedFiliere = value;
                          });
                        }),
                      ],
                    ),
                  ),
                  
                  // Liste des documents
                  Expanded(
                    child: docs.isEmpty 
                      ? _buildEmptyState() 
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            return _buildDocumentCard(docs[index]);
                          },
                        ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Erreur: $e')),
          );
        },
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget? _buildAddButton() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    
    final metadata = user.userMetadata ?? {};
    final role = metadata['role'] ?? 'Étudiant';
    
    if (role != 'Enseignant' && role != 'Admin' && role != 'Directeur') return null;

    return FloatingActionButton(
      onPressed: _showUploadDialog,
      backgroundColor: const Color(0xFF2563EB),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Future<void> _showUploadDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? tempSelectedMatiere = matieres[1];
    String? fileName;
    List<int>? fileBytes;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Publier un document'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titre du document'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description (Optionnel)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tempSelectedMatiere,
                  items: matieres.where((m) => m != 'Toutes').map((m) => 
                    DropdownMenuItem(value: m, child: Text(m))
                  ).toList(),
                  onChanged: (val) => setDialogState(() => tempSelectedMatiere = val),
                  decoration: const InputDecoration(labelText: 'Matière'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await file_picker.FilePicker.platform.pickFiles();
                    if (result != null) {
                      setDialogState(() {
                        fileName = result.files.first.name;
                        fileBytes = result.files.first.bytes;
                      });
                    }
                  },
                  icon: const Icon(Icons.attach_file),
                  label: Text(fileName ?? 'Choisir un fichier'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: (fileName == null || titleController.text.isEmpty) ? null : () async {
                final nav = Navigator.of(context);
                final scaffold = ScaffoldMessenger.of(context);
                
                try {
                  nav.pop(); // Fermer le dialogue
                  scaffold.showSnackBar(const SnackBar(content: Text('Publication en cours...')));
                  
                  // 1. Upload vers le stockage
                  final url = await ResourceService.uploadResourceFile(fileName!, fileBytes!);
                  
                  // 2. Enregistrement en base de données
                  await ResourceService.addResource(
                    title: titleController.text,
                    description: descController.text,
                    url: url,
                    type: fileName!.split('.').last.toUpperCase(),
                    subject: tempSelectedMatiere!,
                  );

                  _refreshData();
                  scaffold.showSnackBar(const SnackBar(content: Text('Document publié avec succès !')));
                } catch (e) {
                  scaffold.showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtre par matière
          _buildFilterSection('Matière', matieres, selectedMatiere, (value) {
            setState(() {
              selectedMatiere = value;
            });
          }),
          
          const SizedBox(height: 16),
          
          // Filtre par filière
          _buildFilterSection('Filière', filieres, selectedFiliere, (value) {
            setState(() {
              selectedFiliere = value;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options, String selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = selectedValue == option;
              
              return GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildDocumentCard(Resource document) {
    final type = document.type;
    final date = document.date;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du document
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône du type de fichier
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getFileTypeColor(type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFileTypeIcon(type),
                    color: _getFileTypeColor(type),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Informations principales
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        document.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Métadonnées
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Type
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getFileTypeColor(type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getFileTypeColor(type),
                    ),
                  ),
                ),
                
                // Matière
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
                  ),
                  child: Text(
                    document.subject,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Pied du document
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Auteur et date
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              document.authorName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bouton
                ElevatedButton.icon(
                  onPressed: () {
                    _downloadDocument(document);
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Télécharger'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.folder_open,
              size: 40,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun document trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres ou votre recherche',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'DOC':
        return Icons.description;
      case 'PPT':
        return Icons.slideshow;
      case 'XLS':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileTypeColor(String type) {
    switch (type) {
      case 'PDF':
        return const Color(0xFFEF4444);
      case 'DOC':
        return const Color(0xFF2563EB);
      case 'PPT':
        return const Color(0xFFF59E0B);
      case 'XLS':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
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

  void _downloadDocument(Resource document) async {
    if (document.url == null || document.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun fichier disponible pour ce document')),
      );
      return;
    }

    try {
      await DownloadService.downloadFile(
        document.url,
        '${document.title}.${_getFileExtension(document.type)}',
        context,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de téléchargement: $e')),
        );
      }
    }
  }

  String _getFileExtension(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return 'pdf';
      case 'word':
      case 'doc':
        return 'docx';
      case 'excel':
      case 'xls':
        return 'xlsx';
      case 'powerpoint':
      case 'ppt':
        return 'pptx';
      default:
        return 'pdf';
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rechercher un document'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Entrez le nom du document...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
