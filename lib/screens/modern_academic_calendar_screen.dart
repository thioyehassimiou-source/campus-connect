import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ModernAcademicCalendarScreen extends StatefulWidget {
  const ModernAcademicCalendarScreen({super.key});

  @override
  State<ModernAcademicCalendarScreen> createState() => _ModernAcademicCalendarScreenState();
}

class _ModernAcademicCalendarScreenState extends State<ModernAcademicCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  List<Map<String, dynamic>> _academicEvents = [];
  String _selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAcademicEvents();
  }

  void _loadAcademicEvents() {
    // Simulation de chargement des événements académiques
    setState(() {
      _academicEvents = [
        {
          'id': '1',
          'title': 'Début des cours',
          'description': 'Reprise des cours pour le semestre 1',
          'date': DateTime(2025, 1, 6),
          'type': 'Académique',
          'priority': 'Élevée',
          'color': const Color(0xFF2563EB),
          'isRecurring': false,
        },
        {
          'id': '2',
          'title': 'Journée d\'intégration',
          'description': 'Accueil des nouveaux étudiants',
          'date': DateTime(2025, 1, 10),
          'type': 'Événement',
          'priority': 'Moyenne',
          'color': const Color(0xFF10B981),
          'isRecurring': false,
        },
        {
          'id': '3',
          'title': 'Premier partiel',
          'description': 'Examen partiel de mi-semestre',
          'date': DateTime(2025, 2, 15),
          'type': 'Examen',
          'priority': 'Élevée',
          'color': const Color(0xFFEF4444),
          'isRecurring': false,
        },
        {
          'id': '4',
          'title': 'Vacances de printemps',
          'description': 'Congés de printemps',
          'date': DateTime(2025, 2, 20),
          'endDate': DateTime(2025, 3, 3),
          'type': 'Vacances',
          'priority': 'Moyenne',
          'color': const Color(0xFFF59E0B),
          'isRecurring': false,
        },
        {
          'id': '5',
          'title': 'Soutenance de projets',
          'description': 'Présentation des projets de fin de semestre',
          'date': DateTime(2025, 3, 20),
          'type': 'Soutenance',
          'priority': 'Élevée',
          'color': const Color(0xFF8B5CF6),
          'isRecurring': false,
        },
        {
          'id': '6',
          'title': 'Examen final',
          'description': 'Examen de fin de semestre',
          'date': DateTime(2025, 4, 10),
          'type': 'Examen',
          'priority': 'Élevée',
          'color': const Color(0xFFEF4444),
          'isRecurring': false,
        },
        {
          'id': '7',
          'title': 'Conseil de classe',
          'description': 'Réunion du conseil de classe',
          'date': DateTime(2025, 4, 20),
          'type': 'Réunion',
          'priority': 'Moyenne',
          'color': const Color(0xFF06B6D4),
          'isRecurring': false,
        },
        {
          'id': '8',
          'title': 'Publication des résultats',
          'description': 'Résultats du semestre 1',
          'date': DateTime(2025, 4, 25),
          'type': 'Académique',
          'priority': 'Élevée',
          'color': const Color(0xFF2563EB),
          'isRecurring': false,
        },
      ];

      // Créer les événements pour le calendrier
      _events = <DateTime, List<Map<String, dynamic>>>{};
      for (var event in _academicEvents) {
        final dateKey = DateTime(event['date'].year, event['date'].month, event['date'].day);
        
        if (_events[dateKey] == null) {
          _events[dateKey] = [];
        }
        _events[dateKey]!.add({
          'title': event['title'],
          'color': event['color'],
          'type': event['type'],
        });

        // Ajouter les événements sur plusieurs jours
        if (event['endDate'] != null) {
          var currentDate = event['date'];
          final endDate = event['endDate'];
          
          while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
            final multiDateKey = DateTime(currentDate.year, currentDate.month, currentDate.day);
            if (_events[multiDateKey] == null) {
              _events[multiDateKey] = [];
            }
            _events[multiDateKey]!.add({
              'title': event['title'],
              'color': event['color'],
              'type': event['type'],
            });
            currentDate = currentDate.add(const Duration(days: 1));
          }
        }
      }
    });
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
              'Calendrier Académique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Semestre 1 - 2024/2025',
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
            icon: Icon(Icons.add, color: Color(0xFF2563EB)),
            onPressed: _showAddEventDialog,
          ),
          IconButton(
            icon: Icon(Icons.download, color: Color(0xFF64748B)),
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
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: Color(0xFF2563EB),
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
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF64748B),
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
                weekendTextStyle: TextStyle(color: Color(0xFF64748B)),
                holidayTextStyle: TextStyle(color: Color(0xFFEF4444)),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFF2563EB).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF64748B)),
                rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF64748B)),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
                weekendStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
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
                      color: Color(0xFF0F172A),
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
        backgroundColor: const Color(0xFF2563EB),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                      color: Color(0xFF0F172A),
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
              icon: Icon(Icons.more_vert, color: Color(0xFF64748B)),
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
              color: Color(0xFF2563EB),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun événement ce jour',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez un autre jour ou ajoutez un événement',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un événement'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Titre'),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Événement ajouté avec succès!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            child: Text('Ajouter'),
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
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modification...')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Partager'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Partage...')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Color(0xFFEF4444)),
              title: Text('Supprimer', style: TextStyle(color: Color(0xFFEF4444))),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Événement supprimé'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
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
