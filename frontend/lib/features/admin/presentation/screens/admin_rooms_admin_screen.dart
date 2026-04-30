import 'package:flutter/material.dart';
import 'package:campusconnect/core/services/room_service.dart';

/// Écran admin de gestion des salles — réutilise RoomService existant.
class AdminRoomsAdminScreen extends StatefulWidget {
  const AdminRoomsAdminScreen({super.key});

  @override
  State<AdminRoomsAdminScreen> createState() => _AdminRoomsAdminScreenState();
}

class _AdminRoomsAdminScreenState extends State<AdminRoomsAdminScreen> {
  List<Room> _rooms = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rooms = await RoomService.getAllRooms();
      if (mounted) setState(() { _rooms = rooms; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Room> get _filtered => _searchQuery.isEmpty
      ? _rooms
      : _rooms.where((r) =>
          r.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.bloc.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;

    // Grouper par bloc
    final Map<String, List<Room>> grouped = {};
    for (final r in filtered) {
      grouped.putIfAbsent(r.bloc, () => []).add(r);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Salles (${_rooms.length})'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Nouvelle salle',
            onPressed: () => _showUpsertDialog(context, null),
          ),
        ],
      ),
      body: Column(
        children: [
          // Recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Rechercher par salle ou bloc…',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const Divider(height: 1),
          // Liste groupée
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: filtered.isEmpty
                        ? const Center(
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.meeting_room_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Aucune salle trouvée', style: TextStyle(color: Colors.grey)),
                            ]),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: grouped.keys.length,
                            itemBuilder: (_, i) {
                              final bloc = grouped.keys.elementAt(i);
                              final rooms = grouped[bloc]!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                                    child: Text('Bloc $bloc',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                          color: theme.colorScheme.primary,
                                          fontSize: 11,
                                        )),
                                  ),
                                  ...rooms.map((r) => _RoomTile(
                                        room: r,
                                        onEdit: () => _showUpsertDialog(context, r),
                                        onDelete: () => _deleteRoom(context, r),
                                      )),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRoom(BuildContext context, Room room) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la salle ?'),
        content: Text('La salle "${room.nom}" sera supprimée.'),
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
    if (ok == true) {
      await RoomService.deleteRoom(room.id);
      _load();
    }
  }

  Future<void> _showUpsertDialog(BuildContext context, Room? room) async {
    final nomCtrl = TextEditingController(text: room?.nom ?? '');
    final blocCtrl = TextEditingController(text: room?.bloc ?? '');
    final capaciteCtrl = TextEditingController(text: room?.capacite.toString() ?? '');
    String type = room?.type ?? 'Cours';
    String statut = room?.statut ?? 'Disponible';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(room == null ? 'Nouvelle Salle' : 'Modifier la Salle',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          content: SizedBox(
            width: 340,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    controller: nomCtrl,
                    decoration: const InputDecoration(labelText: 'Nom de la salle *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: blocCtrl,
                    decoration: const InputDecoration(labelText: 'Bloc *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: capaciteCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Capacité'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: ['Cours', 'Amphithéâtre', 'Laboratoire', 'Informatique', 'Réunion']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => type = v!),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: statut,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: ['Disponible', 'Maintenance', 'Indisponible']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => statut = v!),
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
                await RoomService.upsertRoom({
                  if (room != null) 'id': room.id,
                  'nom': nomCtrl.text.trim(),
                  'bloc': blocCtrl.text.trim(),
                  'capacite': int.tryParse(capaciteCtrl.text) ?? 0,
                  'type': type,
                  'statut': statut,
                  'equipements': room?.equipements ?? [],
                });
                _load();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(room == null ? 'Créer' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Room Tile ────────────────────────────────────────────────────────────────

class _RoomTile extends StatelessWidget {
  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoomTile({required this.room, required this.onEdit, required this.onDelete});

  Color get _statusColor {
    switch (room.statut) {
      case 'Disponible': return Colors.green;
      case 'Maintenance': return Colors.orange;
      default: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.meeting_room, color: Color(0xFFF59E0B), size: 18),
        ),
        title: Row(children: [
          Text(room.nom, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(room.statut,
                style: TextStyle(color: _statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ]),
        subtitle: Text('${room.type} · ${room.capacite} places',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
        trailing: PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit',
                child: Row(children: [Icon(Icons.edit, size: 16, color: Colors.blue), SizedBox(width: 8), Text('Modifier')])),
            PopupMenuItem(value: 'delete',
                child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red.shade600), const SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }
}
