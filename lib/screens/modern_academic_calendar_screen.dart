import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:campusconnect/core/services/academic_calendar_service.dart';
import 'package:campusconnect/controllers/calendar_providers.dart';
import 'package:intl/intl.dart';

class ModernAcademicCalendarScreen extends ConsumerStatefulWidget {
  const ModernAcademicCalendarScreen({super.key});

  @override
  ConsumerState<ModernAcademicCalendarScreen> createState() => _ModernAcademicCalendarScreenState();
}

class _ModernAcademicCalendarScreenState extends ConsumerState<ModernAcademicCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  List<AcademicEvent> _academicEvents = [];
  String _selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Données chargées via Riverpod dams build
  }

  void _loadAcademicEventsFromList(List<AcademicEvent> events) {
    _academicEvents = events;
    _events = <DateTime, List<Map<String, dynamic>>>{};
    
    for (var event in events) {
      final dateKey = DateTime(event.dateDebut.year, event.dateDebut.month, event.dateDebut.day);
      
      _addEventToMap(dateKey, event);

      if (event.dateFin != null) {
        var currentDate = event.dateDebut.add(const Duration(days: 1));
        final endDate = event.dateFin!;
        
        while (currentDate.isBefore(endDate) || isSameDay(currentDate, endDate)) {
          final multiDateKey = DateTime(currentDate.year, currentDate.month, currentDate.day);
          _addEventToMap(multiDateKey, event);
          currentDate = currentDate.add(const Duration(days: 1));
        }
      }
    }
  }

  void _addEventToMap(DateTime dateKey, AcademicEvent event) {
    if (_events[dateKey] == null) {
      _events[dateKey] = [];
    }
    _events[dateKey]!.add({
      'id': event.id,
      'title': event.title,
      'color': event.color,
      'type': event.type,
      'description': event.description,
      'priority': event.priority,
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(academicEventsProvider);

    return eventsAsync.when(
      data: (events) {
        _loadAcademicEventsFromList(events);
        return _buildMainContent(context);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendrier Académique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              'Semestre 1 - 2024/2025',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
            onPressed: _showAddEventDialog,
          ),
          IconButton(
            icon: Icon(Icons.download, color: Theme.of(context).textTheme.bodyMedium?.color),
            onPressed: _exportCalendar,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Tous', 'Académique', 'Examen', 'Vacances', 'Événement'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Calendrier
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2026, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              eventLoader: (day) {
                return _events[day] ?? [];
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.error),
                holidayTextStyle: TextStyle(color: Theme.of(context).colorScheme.error),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).textTheme.bodyMedium?.color),
                rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                weekendStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Événements du jour sélectionné
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedDay != null) ...[
                  Text(
                    'Événements du ${_formatDate(_selectedDay!)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: _eventsForSelectedDay.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _eventsForSelectedDay.length,
                          itemBuilder: (context, index) {
                            final event = _eventsForSelectedDay[index];
                            return _buildEventCard(event);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventDialog,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Événement'),
      ),
    );
  }

  List<Map<String, dynamic>> get _eventsForSelectedDay {
    if (_selectedDay == null) return [];
    
    final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final events = _events[dateKey] ?? [];
    
    // Filtrer selon le filtre sélectionné
    if (_selectedFilter == 'Tous') {
      return events.cast<Map<String, dynamic>>();
    }
    
    return events.where((event) => event['type'] == _selectedFilter).cast<Map<String, dynamic>>().toList();
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: event['color'].withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: event['color'],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: event['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event['type'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: event['color'],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodyMedium?.color),
              onPressed: () => _showEventOptions(event),
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
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.event_available,
              color: Theme.of(context).primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun événement ce jour',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez un autre jour ou ajoutez un événement',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    const List<String> days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String type = 'Académique';
    DateTime selectedDate = _selectedDay ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un événement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                items: ['Académique', 'Examen', 'Vacances', 'Événement', 'Soutenance', 'Réunion']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => type = v!,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                try {
                  await ref.read(calendarControllerProvider.notifier).addEvent({
                    'title': titleController.text,
                    'description': descController.text,
                    'date_debut': selectedDate.toIso8601String(),
                    'type': type,
                  }, ref);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEventOptions(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (event['description'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(event['description'], style: const TextStyle(fontSize: 14)),
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
              title: const Text('Supprimer', style: TextStyle(color: Color(0xFFEF4444))),
              onTap: () async {
                try {
                  await ref.read(calendarControllerProvider.notifier).deleteEvent(event['id'], ref);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _exportCalendar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exporter le calendrier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today, color: Color(0xFF2563EB)),
              title: Text('Google Calendar'),
              subtitle: Text('Synchroniser avec Google Calendar'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Synchronisation...')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
              title: Text('PDF'),
              subtitle: Text('Télécharger en format PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Génération PDF...')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
