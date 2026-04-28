import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/core/services/schedule_service.dart';

/// Écran admin de gestion de l'emploi du temps.
/// Valider / rejeter les créneaux, détecter les conflits.
class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  List<ScheduleItem> _items = [];
  bool _loading = true;
  String _filterStatus = 'all'; // all | pending | validated | cancelled

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await ScheduleService.getPendingSchedules();
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ScheduleItem> get _filtered {
    switch (_filterStatus) {
      case 'pending': return _items.where((i) => i.status == 3).toList();
      case 'validated': return _items.where((i) => i.status == 0).toList();
      case 'cancelled':
        return _items.where((i) => i.status == 1 || i.status == 4).toList();
      default: return _items;
    }
  }

  /// Détecte si deux créneaux entrent en conflit de salle.
  bool _hasConflict(ScheduleItem item) {
    return _items.any((other) =>
        other.id != item.id &&
        other.room == item.room &&
        other.day == item.day &&
        other.status != 1 && other.status != 4 && // pas annulé/rejeté
        item.startTime.isBefore(other.endTime) &&
        item.endTime.isAfter(other.startTime));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;
    final pendingCount = _items.where((i) => i.status == 3).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Emploi du temps'),
          if (pendingCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$pendingCount en attente',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
          IconButton(
            onPressed: () => _showAddScheduleDialog(context),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Ajouter un créneau',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: 'Tous (${_items.length})', value: 'all',
                      current: _filterStatus, color: theme.colorScheme.primary,
                      onTap: () => setState(() => _filterStatus = 'all')),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'En attente ($pendingCount)', value: 'pending',
                      current: _filterStatus, color: Colors.orange,
                      onTap: () => setState(() => _filterStatus = 'pending')),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Validés', value: 'validated',
                      current: _filterStatus, color: Colors.green,
                      onTap: () => setState(() => _filterStatus = 'validated')),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Rejetés', value: 'cancelled',
                      current: _filterStatus, color: Colors.red,
                      onTap: () => setState(() => _filterStatus = 'cancelled')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // Liste
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.event_busy, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Aucun créneau', style: TextStyle(color: Colors.grey)),
                        ]),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _ScheduleTile(
                            item: filtered[i],
                            hasConflict: _hasConflict(filtered[i]),
                            onValidate: () => _validate(filtered[i].id),
                            onReject: () => _showRejectDialog(context, filtered[i].id),
                            onCancel: () => _cancel(filtered[i].id),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _validate(String id) async {
    await ScheduleService.validateSchedule(id);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Créneau validé ✓'), backgroundColor: Colors.green));
    }
  }

  Future<void> _cancel(String id) async {
    await ScheduleService.cancelSchedule(id);
    _load();
  }

  Future<void> _showRejectDialog(BuildContext context, String id) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeter le créneau', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Raison du rejet'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ScheduleService.rejectSchedule(id, ctrl.text.trim());
      _load();
    }
  }

  Future<void> _showAddScheduleDialog(BuildContext context) async {
    final subjectCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    int day = 1;
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    String type = 'CM';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouveau Créneau', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SizedBox(
            width: 340,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: subjectCtrl,
                    decoration: const InputDecoration(labelText: 'Matière *')),
                const SizedBox(height: 10),
                TextField(controller: roomCtrl,
                    decoration: const InputDecoration(labelText: 'Salle *')),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: day,
                  decoration: const InputDecoration(labelText: 'Jour'),
                  items: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam']
                      .asMap()
                      .entries
                      .map((e) => DropdownMenuItem(value: e.key + 1, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) => setState(() => day = v ?? 1),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['CM', 'TD', 'TP']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => type = v!),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            FilledButton(
              onPressed: () async {
                if (subjectCtrl.text.trim().isEmpty || roomCtrl.text.trim().isEmpty) return;
                final now = DateTime.now();
                final start = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
                final end = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);
                await ScheduleService.proposeSchedule(
                  subject: subjectCtrl.text.trim(),
                  startTime: start,
                  endTime: end,
                  room: roomCtrl.text.trim(),
                  day: day,
                  type: type,
                );
                _load();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ScheduleTile ─────────────────────────────────────────────────────────────

class _ScheduleTile extends StatelessWidget {
  final ScheduleItem item;
  final bool hasConflict;
  final VoidCallback onValidate;
  final VoidCallback onReject;
  final VoidCallback onCancel;

  const _ScheduleTile({
    required this.item,
    required this.hasConflict,
    required this.onValidate,
    required this.onReject,
    required this.onCancel,
  });

  Color get _statusColor {
    switch (item.status) {
      case 0: return Colors.green;
      case 1: return Colors.grey;
      case 3: return Colors.orange;
      case 4: return Colors.red;
      default: return Colors.blue;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case 0: return 'Validé';
      case 1: return 'Annulé';
      case 3: return 'En attente';
      case 4: return 'Rejeté';
      default: return 'Inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasConflict
            ? const BorderSide(color: Colors.red, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    if (hasConflict) ...[
                      const Icon(Icons.warning, color: Colors.red, size: 14),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(item.subject,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  Text('${item.teacher} · ${item.type}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_statusLabel,
                    style: TextStyle(color: _statusColor, fontWeight: FontWeight.w700, fontSize: 11)),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${fmt.format(item.startTime)} - ${fmt.format(item.endTime)}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.meeting_room, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(item.room, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
            ]),
            if (item.status == 3) ...[
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text('Rejeter', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onValidate,
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Valider', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label, required this.value, required this.current,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == current;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : color.withOpacity(0.4)),
        ),
        child: Text(label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600, fontSize: 12,
            )),
      ),
    );
  }
}
