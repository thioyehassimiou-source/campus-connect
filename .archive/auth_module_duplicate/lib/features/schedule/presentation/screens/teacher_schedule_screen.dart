import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/schedule_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/emploi_du_temps_item.dart';

class TeacherScheduleScreen extends ConsumerStatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  ConsumerState<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends ConsumerState<TeacherScheduleScreen> {
  late final ScheduleService _service;

  bool _loading = true;
  String? _error;
  List<EmploiDuTempsItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _service = ScheduleService(Supabase.instance.client);
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // IMPORTANT: this assumes your table has a column `enseignant` storing the teacher full name.
      // If you store teacher id instead, replace teacherName with user.id and adapt the column.
      final items = await _service.fetchScheduleForTeacher(teacherName: user.fullName);
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay(_items);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Mon emploi du temps'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _items.isEmpty
                  ? const Center(child: Text('Aucun cours trouvé.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final entry = grouped.entries.elementAt(index);
                        return _DaySection(day: entry.key, items: entry.value);
                      },
                    ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<EmploiDuTempsItem> items;

  const _DaySection({required this.day, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        title: Text(
          _formatDayTitle(day),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _ScheduleCard(item: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final EmploiDuTempsItem item;

  const _ScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final time = '${_formatHm(item.startAt)} - ${_formatHm(item.endAt)}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.course, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(time),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(item.room.isEmpty ? 'Salle non définie' : item.room),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.school, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Expanded(child: Text('Filière: ${item.filiere}')),
            ],
          ),
        ],
      ),
    );
  }
}

Map<DateTime, List<EmploiDuTempsItem>> _groupByDay(List<EmploiDuTempsItem> items) {
  final map = <DateTime, List<EmploiDuTempsItem>>{};
  for (final item in items) {
    map.putIfAbsent(item.day, () => []).add(item);
  }

  final keys = map.keys.toList()..sort();
  final sorted = <DateTime, List<EmploiDuTempsItem>>{};
  for (final key in keys) {
    final dayItems = map[key]!..sort((a, b) => a.startAt.compareTo(b.startAt));
    sorted[key] = dayItems;
  }
  return sorted;
}

String _formatDayTitle(DateTime date) {
  const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  const months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  final dayName = days[date.weekday - 1];
  final monthName = months[date.month - 1];
  return '$dayName ${date.day} $monthName';
}

String _formatHm(DateTime dt) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(dt.hour)}:${two(dt.minute)}';
}
