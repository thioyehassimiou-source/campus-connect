import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/schedule_service.dart';
import '../../domain/models/emploi_du_temps_item.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  late final ScheduleService _service;

  List<String> _filieres = const [];
  String? _selectedFiliere;

  bool _loadingFilieres = true;
  bool _loadingSchedule = false;

  List<EmploiDuTempsItem> _items = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = ScheduleService(Supabase.instance.client);
    _loadFilieres();
  }

  Future<void> _loadFilieres() async {
    setState(() {
      _loadingFilieres = true;
      _error = null;
    });

    try {
      final filieres = await _service.fetchFilieres();
      setState(() {
        _filieres = filieres;
        _selectedFiliere = filieres.isNotEmpty ? filieres.first : null;
        _loadingFilieres = false;
      });

      if (_selectedFiliere != null) {
        await _loadSchedule();
      }
    } catch (e) {
      setState(() {
        _loadingFilieres = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadSchedule() async {
    final filiere = _selectedFiliere;
    if (filiere == null) return;

    setState(() {
      _loadingSchedule = true;
      _error = null;
    });

    try {
      final items = await _service.fetchScheduleForFiliere(filiere: filiere);
      setState(() {
        _items = items;
        _loadingSchedule = false;
      });
    } catch (e) {
      setState(() {
        _loadingSchedule = false;
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
        title: const Text('Emploi du temps'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadingFilieres || _loadingSchedule ? null : _loadSchedule,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFiliereFilter(),
            const SizedBox(height: 12),
            if (_loadingFilieres || _loadingSchedule)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (_items.isEmpty)
              const Expanded(
                child: Center(child: Text('Aucun cours trouvé pour cette filière.')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped.entries.elementAt(index);
                    final day = entry.key;
                    final items = entry.value;

                    return _DaySection(
                      day: day,
                      items: items,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiliereFilter() {
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
          const Icon(Icons.filter_list, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            'Filière',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedFiliere,
                hint: const Text('Choisir une filière'),
                items: _filieres
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(f),
                      ),
                    )
                    .toList(),
                onChanged: _loadingFilieres
                    ? null
                    : (value) async {
                        setState(() {
                          _selectedFiliere = value;
                        });
                        await _loadSchedule();
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<EmploiDuTempsItem> items;

  const _DaySection({
    required this.day,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final title = _formatDayTitle(day);

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
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
          Text(
            item.course,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
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
              const Icon(Icons.person, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(item.teacher.isEmpty ? 'Enseignant non défini' : item.teacher),
              ),
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
    final key = item.day;
    map.putIfAbsent(key, () => []).add(item);
  }

  final sortedKeys = map.keys.toList()..sort();
  final sorted = <DateTime, List<EmploiDuTempsItem>>{};
  for (final key in sortedKeys) {
    final dayItems = map[key]!..sort((a, b) => a.startAt.compareTo(b.startAt));
    sorted[key] = dayItems;
  }
  return sorted;
}

String _formatDayTitle(DateTime date) {
  const days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
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
