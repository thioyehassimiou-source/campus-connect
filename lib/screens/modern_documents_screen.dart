import 'package:flutter/material.dart';

class ModernDocumentsScreen extends StatefulWidget {
  const ModernDocumentsScreen({super.key});

  @override
  State<ModernDocumentsScreen> createState() => _ModernDocumentsScreenState();
}

class _ModernDocumentsScreenState extends State<ModernDocumentsScreen> {
  String selectedMatiere = 'Toutes';
  String selectedFiliere = 'Toutes';
  String searchQuery = '';
  
  final List<String> matieres = [
    'Toutes', 'Mathématiques', 'Physique', 'Informatique', 'Chimie', 
    'Anglais', 'Économie', 'Sport', 'Projet'
  ];
  
  final List<String> filieres = [
    'Toutes', 'L1 Info', 'L2 Info', 'L3 Info', 'M1 Info', 'M2 Info',
    'L1 Maths', 'L2 Maths', 'L3 Maths'
  ];

  final List<Map<String, dynamic>> documents = [
    {
      'id': 1,
      'title': 'Cours de Mathématiques - Analyse',
      'description': 'Support de cours complet pour le semestre 1',
      'matiere': 'Mathématiques',
      'filiere': 'L1 Info',
      'type': 'PDF',
      'size': '2.5 MB',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'downloads': 145,
      'author': 'Dr. Martin',
    },
    {
      'id': 2,
      'title': 'TP de Physique Quantique',
      'description': 'Énoncés des travaux pratiques et corrigés',
      'matiere': 'Physique',
      'filiere': 'L2 Info',
      'type': 'PDF',
      'size': '1.8 MB',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'downloads': 89,
      'author': 'Prof. Dubois',
    },
    {
      'id': 3,
      'title': 'Exercices d\'Algorithmique',
      'description': 'Série d\'exercices avec solutions détaillées',
      'matiere': 'Informatique',
      'filiere': 'L1 Info',
      'type': 'DOC',
      'size': '3.2 MB',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'downloads': 234,
      'author': 'Dr. Robert',
    },
    {
      'id': 4,
      'title': 'Présentation - Machine Learning',
      'description': 'Support de présentation pour le cours de ML',
      'matiere': 'Informatique',
      'filiere': 'M1 Info',
      'type': 'PPT',
      'size': '5.7 MB',
      'date': DateTime.now().subtract(const Duration(hours: 6)),
      'downloads': 67,
      'author': 'M. Bernard',
    },
    {
      'id': 5,
      'title': 'Formulaire de Chimie Organique',
      'description': 'Résumé des formules et réactions importantes',
      'matiere': 'Chimie',
      'filiere': 'L2 Maths',
      'type': 'PDF',
      'size': '0.8 MB',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'downloads': 156,
      'author': 'Prof. Laurent',
    },
    {
      'id': 6,
      'title': 'Business Plan Template',
      'description': 'Modèle de plan d\'affaires pour projets étudiants',
      'matiere': 'Économie',
      'filiere': 'L3 Info',
      'type': 'XLS',
      'size': '1.2 MB',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'downloads': 98,
      'author': 'Dr. Petit',
    },
    {
      'id': 7,
      'title': 'Vocabulary List - Advanced English',
      'description': 'Liste de vocabulaire avancé avec traductions',
      'matiere': 'Anglais',
      'filiere': 'Toutes',
      'type': 'PDF',
      'size': '0.5 MB',
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'downloads': 312,
      'author': 'Mme. Smith',
    },
    {
      'id': 8,
      'title': 'Guide de survie - Examens',
      'description': 'Conseils et techniques pour réussir vos examens',
      'matiere': 'Projet',
      'filiere': 'Toutes',
      'type': 'PDF',
      'size': '1.1 MB',
      'date': DateTime.now().subtract(const Duration(hours: 12)),
      'downloads': 445,
      'author': 'Administration',
    },
  ];

  List<Map<String, dynamic>> get filteredDocuments {
    return documents.where((doc) {
      final matchesMatiere = selectedMatiere == 'Toutes' || doc['matiere'] == selectedMatiere;
      final matchesFiliere = selectedFiliere == 'Toutes' || doc['filiere'] == selectedFiliere;
      final matchesSearch = searchQuery.isEmpty || 
                           doc['title'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                           doc['description'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchesMatiere && matchesFiliere && matchesSearch;
    }).toList();
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
              'Documents Pédagogiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${filteredDocuments.length} documents',
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
            icon: Icon(Icons.search, color: Color(0xFF64748B)),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          _buildFilters(),
          
          // Liste des documents
          Expanded(
            child: filteredDocuments.isEmpty
                ? _buildEmptyState()
                : _buildDocumentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
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
            color: Color(0xFF0F172A),
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
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    option,
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
    );
  }

  Widget _buildDocumentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = filteredDocuments[index];
        return _buildDocumentCard(document);
      },
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> document) {
    final type = document['type'] as String;
    final size = document['size'] as String;
    final downloads = document['downloads'] as int;
    final date = document['date'] as DateTime;
    
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
                        document['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        document['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
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
                // Type et taille
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getFileTypeColor(type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$type • $size',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getFileTypeColor(type),
                    ),
                  ),
                ),
                
                // Matière et filière
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                  ),
                  child: Text(
                    '${document['matiere']} • ${document['filiere']}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Pied du document
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                // Auteur et date
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      document['author'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                // Téléchargements
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download_outlined,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$downloads téléchargements',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                // Date et Bouton
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        _downloadDocument(document);
                      },
                      icon: Icon(Icons.download, size: 16),
                      label: Text('Télécharger'),
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
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.folder_open,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun document trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres ou votre recherche',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
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

  void _downloadDocument(Map<String, dynamic> document) {
    // Simuler le téléchargement
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement de "${document['title']}" en cours...'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
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
