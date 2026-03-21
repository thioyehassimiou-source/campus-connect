import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/features/admin/data/services/admin_announcement_service.dart';

/// Écran de gestion des annonces pour l'administrateur.
class AdminAnnouncementsScreen extends ConsumerStatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  ConsumerState<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends ConsumerState<AdminAnnouncementsScreen> {
  List<AdminAnnouncementModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await AdminAnnouncementService.getAnnouncements();
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annonces'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                  ? const Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.campaign_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Aucune annonce', style: TextStyle(color: Colors.grey)),
                      ]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (_, i) => _AnnouncementTile(
                        item: _items[i],
                        onPublish: () async {
                          await AdminAnnouncementService.publishDraft(_items[i].id);
                          _load();
                        },
                        onDelete: () async {
                          final ok = await _confirmDelete(context, _items[i].titre);
                          if (ok == true) {
                            await AdminAnnouncementService.deleteAnnouncement(_items[i].id);
                            _load();
                          }
                        },
                      ),
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.campaign),
        label: const Text('Nouvelle annonce'),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String title) =>
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Supprimer l\'annonce ?'),
          content: Text('"$title" sera définitivement supprimée.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      );

  Future<void> _showCreateDialog(BuildContext context) async {
    final titreCtrl = TextEditingController();
    final contenuCtrl = TextEditingController();
    AnnouncementPriority priority = AnnouncementPriority.normale;
    AnnouncementTarget target = AnnouncementTarget.global;
    bool isDraft = false;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouvelle Annonce', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SizedBox(
            width: 380,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    controller: titreCtrl,
                    decoration: const InputDecoration(labelText: 'Titre *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: contenuCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Contenu *', alignLabelWithHint: true),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<AnnouncementPriority>(
                    value: priority,
                    decoration: const InputDecoration(labelText: 'Priorité'),
                    items: AnnouncementPriority.values.map((p) {
                      final labels = {
                        AnnouncementPriority.normale: 'Normale',
                        AnnouncementPriority.urgente: '🔴 Urgente',
                        AnnouncementPriority.info: 'ℹ️ Information',
                      };
                      return DropdownMenuItem(value: p, child: Text(labels[p]!));
                    }).toList(),
                    onChanged: (v) => setState(() => priority = v!),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<AnnouncementTarget>(
                    value: target,
                    decoration: const InputDecoration(labelText: 'Cible'),
                    items: AnnouncementTarget.values.map((t) {
                      final labels = {
                        AnnouncementTarget.global: '🌍 Tout le campus',
                        AnnouncementTarget.etudiants: '🎓 Étudiants',
                        AnnouncementTarget.enseignants: '📚 Enseignants',
                        AnnouncementTarget.filiere: '🏫 Filière spécifique',
                      };
                      return DropdownMenuItem(value: t, child: Text(labels[t]!));
                    }).toList(),
                    onChanged: (v) => setState(() => target = v!),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: isDraft,
                    onChanged: (v) => setState(() => isDraft = v),
                    title: const Text('Sauvegarder comme brouillon', style: TextStyle(fontSize: 13)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ]),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await AdminAnnouncementService.createAnnouncement(
                  titre: titreCtrl.text.trim(),
                  contenu: contenuCtrl.text.trim(),
                  priority: priority,
                  target: target,
                  isDraft: isDraft,
                );
                _load();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isDraft ? 'Brouillon sauvegardé' : 'Annonce publiée ✓'),
                    backgroundColor: Colors.green,
                  ));
                }
              },
              child: Text(isDraft ? 'Sauvegarder' : 'Publier'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Announcement Tile ────────────────────────────────────────────────────────

class _AnnouncementTile extends StatelessWidget {
  final AdminAnnouncementModel item;
  final VoidCallback onPublish;
  final VoidCallback onDelete;

  const _AnnouncementTile({required this.item, required this.onPublish, required this.onDelete});

  Color get _priorityColor {
    switch (item.priority) {
      case AnnouncementPriority.urgente: return Colors.red;
      case AnnouncementPriority.info: return Colors.blue;
      case AnnouncementPriority.normale: return const Color(0xFF10B981);
    }
  }

  IconData get _priorityIcon {
    switch (item.priority) {
      case AnnouncementPriority.urgente: return Icons.priority_high;
      case AnnouncementPriority.info: return Icons.info_outline;
      case AnnouncementPriority.normale: return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _priorityColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_priorityIcon, color: _priorityColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.titre,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item.priorityLabel,
                          style: TextStyle(fontSize: 10, color: _priorityColor, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item.targetLabel,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                    ),
                    if (item.isDraft) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Brouillon', style: TextStyle(fontSize: 10, color: Colors.orange.shade700, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ]),
                ]),
              ),
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (v) {
                  if (v == 'publish') onPublish();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  if (item.isDraft)
                    const PopupMenuItem(value: 'publish',
                        child: Row(children: [Icon(Icons.publish, size: 16, color: Colors.green), SizedBox(width: 8), Text('Publier')])),
                  PopupMenuItem(value: 'delete',
                      child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red.shade600), const SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ]),
            const SizedBox(height: 8),
            Text(item.contenu,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
