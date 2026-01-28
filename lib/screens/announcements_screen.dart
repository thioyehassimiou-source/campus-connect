import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/shared/models/announcement_model.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:campusconnect/core/services/firebase_service.dart';

class AnnouncementsScreen extends StatefulWidget {
  final UserModel user;

  const AnnouncementsScreen({super.key, required this.user});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;
  String _selectedPriority = 'Toutes';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);

    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('announcements')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final announcements = querySnapshot.docs
          .map((doc) => AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((announcement) => _isAnnouncementForUser(announcement))
          .toList();

      setState(() {
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  bool _isAnnouncementForUser(AnnouncementModel announcement) {
    if (announcement.isExpired) return false;

    switch (announcement.target) {
      case AnnouncementTarget.all:
        return true;
      case AnnouncementTarget.students:
        return widget.user.role == UserRole.etudiant;
      case AnnouncementTarget.teachers:
        return widget.user.role == UserRole.enseignant;
      case AnnouncementTarget.specific:
        return announcement.targetUserIds.contains(widget.user.id);
    }
  }

  List<AnnouncementModel> get _filteredAnnouncements {
    if (_selectedPriority == 'Toutes') return _announcements;
    
    final priority = AnnouncementPriority.values.firstWhere(
      (p) => p.name == _selectedPriority.toLowerCase(),
      orElse: () => AnnouncementPriority.medium,
    );
    
    return _announcements.where((a) => a.priority == priority).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annonces'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnnouncements,
          ),
          if (widget.user.role == UserRole.administrateur)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showCreateAnnouncementDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Priority Filter
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPriority,
                      isExpanded: true,
                      items: ['Toutes', 'low', 'medium', 'high', 'urgent'].map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority == 'Toutes' ? priority : _getPriorityDisplayName(AnnouncementPriority.values.firstWhere(
                            (p) => p.name == priority,
                            orElse: () => AnnouncementPriority.medium,
                          ))),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                    ),
                  ),
                ),

                // Announcements List
                Expanded(
                  child: _filteredAnnouncements.isEmpty
                      ? const Center(
                          child: Text('Aucune annonce disponible'),
                        )
                      : ListView.builder(
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
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: announcement.priorityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    announcement.priorityDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(announcement.createdAt),
                  style: AppTheme.captionStyle,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              announcement.title,
              style: AppTheme.subheadingStyle,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              announcement.content,
              style: AppTheme.bodyStyle,
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  announcement.authorName,
                  style: AppTheme.captionStyle,
                ),
                if (announcement.expiresAt != null) ...[
                  const Spacer(),
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Expire: ${DateFormat('dd/MM/yyyy').format(announcement.expiresAt!)}',
                    style: AppTheme.captionStyle,
                  ),
                ],
              ],
            ),
            
            if (announcement.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Pièces jointes:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...announcement.attachments.map((attachment) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attachment.split('/').last,
                        style: AppTheme.captionStyle,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, size: 16),
                      onPressed: () {
                        // TODO: Download attachment
                      },
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    AnnouncementPriority selectedPriority = AnnouncementPriority.medium;
    AnnouncementTarget selectedTarget = AnnouncementTarget.all;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Créer une annonce'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Contenu',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AnnouncementPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priorité',
                    border: OutlineInputBorder(),
                  ),
                  items: AnnouncementPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(_getPriorityDisplayName(priority)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AnnouncementTarget>(
                  value: selectedTarget,
                  decoration: const InputDecoration(
                    labelText: 'Cible',
                    border: OutlineInputBorder(),
                  ),
                  items: AnnouncementTarget.values.map((target) {
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
                if (titleController.text.isEmpty || contentController.text.isEmpty) {
                  return;
                }

                try {
                  final announcement = AnnouncementModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    content: contentController.text,
                    authorId: widget.user.id,
                    authorName: widget.user.fullName,
                    priority: selectedPriority,
                    target: selectedTarget,
                    targetUserIds: [],
                    createdAt: DateTime.now(),
                    attachments: [],
                    isActive: true,
                  );

                  await FirebaseService.firestore
                      .collection('announcements')
                      .doc(announcement.id)
                      .set(announcement.toMap());

                  Navigator.pop(context);
                  _loadAnnouncements();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityDisplayName(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.low:
        return 'Basse';
      case AnnouncementPriority.medium:
        return 'Moyenne';
      case AnnouncementPriority.high:
        return 'Haute';
      case AnnouncementPriority.urgent:
        return 'Urgente';
    }
  }

  String _getTargetDisplayName(AnnouncementTarget target) {
    switch (target) {
      case AnnouncementTarget.all:
        return 'Tout le monde';
      case AnnouncementTarget.students:
        return 'Étudiants';
      case AnnouncementTarget.teachers:
        return 'Enseignants';
      case AnnouncementTarget.specific:
        return 'Utilisateurs spécifiques';
    }
  }
}
