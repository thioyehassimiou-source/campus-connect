import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/shared/models/document_model.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:campusconnect/core/services/firebase_service.dart';

class DocumentsScreen extends StatefulWidget {
  final UserModel user;

  const DocumentsScreen({super.key, required this.user});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<DocumentModel> _documents = [];
  bool _isLoading = true;
  String _selectedType = 'Tous';
  String _selectedCourse = 'Tous';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);

    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('documents')
          .where('isActive', isEqualTo: true)
          .orderBy('uploadDate', descending: true)
          .get();

      final documents = querySnapshot.docs
          .map((doc) => DocumentModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((document) => _isDocumentForUser(document))
          .toList();

      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  bool _isDocumentForUser(DocumentModel document) {
    switch (document.target) {
      case DocumentTarget.all:
        return true;
      case DocumentTarget.students:
        return widget.user.role == UserRole.student;
      case DocumentTarget.teachers:
        return widget.user.role == UserRole.teacher;
      case DocumentTarget.specific:
        return document.targetUserIds.contains(widget.user.id);
    }
  }

  List<DocumentModel> get _filteredDocuments {
    var filtered = _documents;

    // Filter by type
    if (_selectedType != 'Tous') {
      final type = DocumentType.values.firstWhere(
        (t) => t.name == _selectedType.toLowerCase(),
        orElse: () => DocumentType.other,
      );
      filtered = filtered.where((d) => d.type == type).toList();
    }

    // Filter by course
    if (_selectedCourse != 'Tous') {
      filtered = filtered.where((d) => d.courseName == _selectedCourse).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) =>
        d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        d.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        d.courseName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  List<String> get _courses {
    final courses = _documents.map((doc) => doc.courseName).toSet().toList();
    courses.sort();
    return ['Tous', ...courses];
  }

  Future<void> _uploadDocument() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        await _showUploadDialog(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  void _showUploadDialog(PlatformFile file) {
    final titleController = TextEditingController(text: file.name.split('.').first);
    final descriptionController = TextEditingController();
    final courseController = TextEditingController();
    
    DocumentType selectedType = DocumentType.other;
    DocumentTarget selectedTarget = DocumentTarget.all;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Uploader un document'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Fichier: ${file.name}',
                  style: AppTheme.captionStyle,
                ),
                Text(
                  'Taille: ${_formatFileSize(file.size ?? 0)}',
                  style: AppTheme.captionStyle,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(
                    labelText: 'Matière/Cours',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DocumentType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type de document',
                    border: OutlineInputBorder(),
                  ),
                  items: DocumentType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DocumentTarget>(
                  value: selectedTarget,
                  decoration: const InputDecoration(
                    labelText: 'Cible',
                    border: OutlineInputBorder(),
                  ),
                  items: DocumentTarget.values.map((target) {
                    return DropdownMenuItem(
                      value: target,
                      child: Text(_getTargetDisplayName(target)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTarget = value!;
                    });
                  },
                ),
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
                if (titleController.text.isEmpty || courseController.text.isEmpty) {
                  return;
                }

                try {
                  // TODO: Upload file to Firebase Storage
                  // For now, create document with placeholder URL
                  final document = DocumentModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    description: descriptionController.text,
                    fileName: file.name ?? '',
                    fileUrl: 'placeholder_url', // TODO: Replace with actual URL
                    fileSize: file.size ?? 0,
                    fileType: file.extension ?? 'unknown',
                    courseId: courseController.text.toLowerCase().replaceAll(' ', '_'),
                    courseName: courseController.text,
                    teacherId: widget.user.id,
                    teacherName: widget.user.fullName,
                    type: selectedType,
                    target: selectedTarget,
                    targetUserIds: [],
                    uploadDate: DateTime.now(),
                    downloadCount: 0,
                    isActive: true,
                  );

                  await FirebaseService.firestore
                      .collection('documents')
                      .doc(document.id)
                      .set(document.toMap());

                  Navigator.pop(context);
                  _loadDocuments();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Uploader'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
          if (widget.user.role == UserRole.teacher || widget.user.role == UserRole.admin)
            IconButton(
              icon: const Icon(Icons.upload),
              onPressed: _uploadDocument,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filters
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher des documents...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Filters
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedType,
                                  isExpanded: true,
                                  items: ['Tous', 'course', 'tutorial', 'lab', 'exam', 'resource', 'other'].map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type == 'Tous' ? type : _getTypeDisplayName(DocumentType.values.firstWhere(
                                        (t) => t.name == type,
                                        orElse: () => DocumentType.other,
                                      ))),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedType = value!;
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
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCourse,
                                  isExpanded: true,
                                  items: _courses.map((course) {
                                    return DropdownMenuItem(
                                      value: course,
                                      child: Text(course),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCourse = value!;
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

                // Documents List
                Expanded(
                  child: _filteredDocuments.isEmpty
                      ? const Center(
                          child: Text('Aucun document disponible'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredDocuments.length,
                          itemBuilder: (context, index) {
                            final document = _filteredDocuments[index];
                            return _buildDocumentCard(document);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildDocumentCard(DocumentModel document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showDocumentOptions(document);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(document.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFileIcon(document.fileType),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title,
                          style: AppTheme.subheadingStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          document.courseName,
                          style: AppTheme.captionStyle,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(document.type),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      document.typeDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (document.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  document.description,
                  style: AppTheme.bodyStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    document.teacherName,
                    style: AppTheme.captionStyle,
                  ),
                  const Spacer(),
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(document.uploadDate),
                    style: AppTheme.captionStyle,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.file_download, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${document.downloadCount}',
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.storage, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    document.formattedFileSize,
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentOptions(DocumentModel document) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Télécharger'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement download
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Téléchargement démarré')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Aperçu'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement preview
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aperçu bientôt disponible')),
                );
              },
            ),
            if (widget.user.role == UserRole.admin || 
                (widget.user.role == UserRole.teacher && document.teacherId == widget.user.id)) ...[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteDocument(document);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDocument(DocumentModel document) async {
    try {
      await FirebaseService.firestore
          .collection('documents')
          .doc(document.id)
          .update({'isActive': false});

      _loadDocuments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document supprimé')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  String _getTypeDisplayName(DocumentType type) {
    switch (type) {
      case DocumentType.course:
        return 'Cours';
      case DocumentType.tutorial:
        return 'TD';
      case DocumentType.lab:
        return 'TP';
      case DocumentType.exam:
        return 'Examen';
      case DocumentType.resource:
        return 'Ressource';
      case DocumentType.other:
        return 'Autre';
    }
  }

  String _getTargetDisplayName(DocumentTarget target) {
    switch (target) {
      case DocumentTarget.all:
        return 'Tout le monde';
      case DocumentTarget.students:
        return 'Étudiants';
      case DocumentTarget.teachers:
        return 'Enseignants';
      case DocumentTarget.specific:
        return 'Utilisateurs spécifiques';
    }
  }

  Color _getTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.course:
        return AppTheme.primaryColor;
      case DocumentType.tutorial:
        return AppTheme.successColor;
      case DocumentType.lab:
        return AppTheme.warningColor;
      case DocumentType.exam:
        return AppTheme.errorColor;
      case DocumentType.resource:
        return Colors.purple;
      case DocumentType.other:
        return Colors.grey;
    }
  }

  IconData _getFileIcon(String fileType) {
    if (fileType.startsWith('image/')) return Icons.image;
    if (fileType == 'application/pdf') return Icons.picture_as_pdf;
    if (fileType.contains('document') || fileType.contains('word')) return Icons.description;
    if (fileType.contains('sheet') || fileType.contains('excel')) return Icons.table_chart;
    if (fileType.contains('presentation') || fileType.contains('powerpoint')) return Icons.slideshow;
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
