import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/admin_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/block_model.dart';
import '../../domain/models/room_model.dart';

class AdminInfrastructureScreen extends ConsumerStatefulWidget {
  const AdminInfrastructureScreen({super.key});

  @override
  ConsumerState<AdminInfrastructureScreen> createState() =>
      _AdminInfrastructureScreenState();
}

class _AdminInfrastructureScreenState extends ConsumerState<AdminInfrastructureScreen> {
  late final AdminService _service;

  bool _loading = true;
  String? _error;

  List<BlockModel> _blocks = const [];
  String? _selectedBlockId;

  List<RoomModel> _rooms = const [];

  @override
  void initState() {
    super.initState();
    _service = AdminService(Supabase.instance.client);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final blocks = await _service.fetchBlocks();
      final selected = _selectedBlockId ?? (blocks.isNotEmpty ? blocks.first.id : null);
      final rooms = selected == null ? <RoomModel>[] : await _service.fetchRooms(blockId: selected);

      setState(() {
        _blocks = blocks;
        _selectedBlockId = selected;
        _rooms = rooms;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _reloadRooms() async {
    final blockId = _selectedBlockId;
    if (blockId == null) return;
    try {
      final rooms = await _service.fetchRooms(blockId: blockId);
      setState(() => _rooms = rooms);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;

    if (currentUser == null || currentUser.role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Blocs & Salles'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Accès refusé : admin uniquement.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Blocs & Salles'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _loading ? null : _openCreateBlock,
            icon: const Icon(Icons.add_business),
            tooltip: 'Créer un bloc',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildBlockSelector(),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Salles',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _selectedBlockId == null ? null : _openCreateRoom,
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ..._rooms.map((r) => _RoomTile(
                                room: r,
                                onEdit: () => _openEditRoom(r),
                                onDelete: () => _deleteRoom(r.id),
                              )),
                          if (_rooms.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Center(child: Text('Aucune salle.')),
                            )
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildBlockSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.apartment, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Bloc', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedBlockId,
                hint: const Text('Sélectionner un bloc'),
                items: _blocks
                    .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                    .toList(),
                onChanged: (v) async {
                  setState(() {
                    _selectedBlockId = v;
                  });
                  await _reloadRooms();
                },
              ),
            ),
          ),
          IconButton(
            onPressed: _selectedBlockId == null ? null : _openEditSelectedBlock,
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier bloc',
          ),
          IconButton(
            onPressed: _selectedBlockId == null ? null : _deleteSelectedBlock,
            icon: const Icon(Icons.delete),
            tooltip: 'Supprimer bloc',
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateBlock() async {
    final result = await showDialog<_BlockFormResult>(
      context: context,
      builder: (_) => const _BlockDialog(title: 'Créer un bloc'),
    );

    if (result == null) return;

    try {
      await _service.createBlock(name: result.name, description: result.description);
      await _load();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _openEditSelectedBlock() async {
    final id = _selectedBlockId;
    if (id == null) return;
    final block = _blocks.firstWhere((b) => b.id == id);

    final result = await showDialog<_BlockFormResult>(
      context: context,
      builder: (_) => _BlockDialog(title: 'Modifier bloc', initial: block),
    );

    if (result == null) return;

    try {
      await _service.updateBlock(id: id, name: result.name, description: result.description);
      await _load();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _deleteSelectedBlock() async {
    final id = _selectedBlockId;
    if (id == null) return;

    final ok = await _confirm('Supprimer ce bloc ?');
    if (!ok) return;

    try {
      await _service.deleteBlock(id);
      setState(() {
        _selectedBlockId = null;
      });
      await _load();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _openCreateRoom() async {
    final blockId = _selectedBlockId;
    if (blockId == null) return;

    final result = await showDialog<_RoomFormResult>(
      context: context,
      builder: (_) => _RoomDialog(title: 'Créer une salle'),
    );

    if (result == null) return;

    try {
      await _service.createRoom(blockId: blockId, name: result.name, capacity: result.capacity);
      await _reloadRooms();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _openEditRoom(RoomModel room) async {
    final result = await showDialog<_RoomFormResult>(
      context: context,
      builder: (_) => _RoomDialog(title: 'Modifier salle', initial: room),
    );

    if (result == null) return;

    try {
      await _service.updateRoom(
        id: room.id,
        blockId: room.blockId,
        name: result.name,
        capacity: result.capacity,
      );
      await _reloadRooms();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _deleteRoom(String id) async {
    final ok = await _confirm('Supprimer cette salle ?');
    if (!ok) return;

    try {
      await _service.deleteRoom(id);
      await _reloadRooms();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<bool> _confirm(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
        ],
      ),
    );
    return result ?? false;
  }
}

class _RoomTile extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoomTile({
    required this.room,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.meeting_room, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Capacité: ${room.capacity ?? '-'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.red)),
        ],
      ),
    );
  }
}

class _BlockDialog extends StatefulWidget {
  final String title;
  final BlockModel? initial;

  const _BlockDialog({required this.title, this.initial});

  @override
  State<_BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<_BlockDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initial?.name ?? '';
    _descController.text = widget.initial?.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nom du bloc'),
          ),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description (optionnel)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              _BlockFormResult(name: name, description: _descController.text.trim().isEmpty ? null : _descController.text.trim()),
            );
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _RoomDialog extends StatefulWidget {
  final String title;
  final RoomModel? initial;

  const _RoomDialog({required this.title, this.initial});

  @override
  State<_RoomDialog> createState() => _RoomDialogState();
}

class _RoomDialogState extends State<_RoomDialog> {
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initial?.name ?? '';
    _capacityController.text = widget.initial?.capacity?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nom de la salle'),
          ),
          TextField(
            controller: _capacityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Capacité (optionnel)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            final cap = int.tryParse(_capacityController.text.trim());
            Navigator.pop(context, _RoomFormResult(name: name, capacity: cap));
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _BlockFormResult {
  final String name;
  final String? description;

  const _BlockFormResult({required this.name, this.description});
}

class _RoomFormResult {
  final String name;
  final int? capacity;

  const _RoomFormResult({required this.name, this.capacity});
}
