import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ModernEnhancedScheduleScreen extends StatefulWidget {
  final bool isTeacher;
  final bool isAdmin;
  
  const ModernEnhancedScheduleScreen({
    super.key,
    this.isTeacher = false,
    this.isAdmin = false,
  });

  @override
  State<ModernEnhancedScheduleScreen> createState() => _ModernEnhancedScheduleScreenState();
}

class _ModernEnhancedScheduleScreenState extends State<ModernEnhancedScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _courses = [];
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  String _selectedView = 'Semaine';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadScheduleData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadScheduleData() {
    // Simulation de chargement des données selon le rôle
    setState(() {
      _courses = [
        {
          'id': '1',
          'title': 'Mathématiques',
          'teacher': widget.isTeacher ? 'Moi' : 'Prof. Bernard',
          'room': 'A101',
          'startTime': '08:00',
          'endTime': '10:00',
          'day': 'Lundi',
          'color': const Color(0xFF2563EB),
          'type': 'Cours magistral',
          'students': widget.isTeacher ? 45 : null,
          'module': 'MAT101',
          'description': 'Calcul différentiel et intégral',
          'materials': ['Calculatrice', 'Manuel chapitre 3-4'],
        },
        {
          'id': '2',
          'title': 'Physique',
          'teacher': widget.isTeacher ? 'Moi' : 'Prof. Dubois',
          'room': 'B205',
          'startTime': '10:15',
          'endTime': '12:15',
          'day': 'Lundi',
          'color': const Color(0xFF10B981),
          'type': 'TP',
          'students': widget.isTeacher ? 30 : null,
          'module': 'PHY201',
          'description': 'TP de mécanique quantique',
          'materials': ['Blouse de lab', 'Cahier de TP'],
        },
        {
          'id': '3',
          'title': 'Informatique',
          'teacher': widget.isTeacher ? 'Moi' : 'Prof. Leroy',
          'room': 'C301',
          'startTime': '14:00',
          'endTime': '16:00',
          'day': 'Lundi',
          'color': const Color(0xFF8B5CF6),
          'type': 'Projet',
          'students': widget.isTeacher ? 25 : null,
          'module': 'INF301',
          'description': 'Avancement projet web',
          'materials': ['Ordinateur portable'],
        },
        {
          'id': '4',
          'title': 'Algorithmique',
          'teacher': widget.isTeacher ? 'Moi' : 'Prof. Martin',
          'room': 'D201',
          'startTime': '08:00',
          'endTime': '10:00',
          'day': 'Mardi',
          'color': const Color(0xFFF59E0B),
          'type': 'Cours magistral',
          'students': widget.isTeacher ? 40 : null,
          'module': 'ALG201',
          'description': 'Structures de données avancées',
          'materials': ['Ordinateur portable', 'Manuel'],
        },
        {
          'id': '5',
          'title': 'Base de Données',
          'teacher': widget.isTeacher ? 'Moi' : 'Prof. Petit',
          'room': 'E102',
          'startTime': '10:15',
          'endTime': '12:15',
          'day': 'Mardi',
          'color': const Color(0xFFEF4444),
          'type': 'TD',
          'students': widget.isTeacher ? 35 : null,
          'module': 'BDD201',
          'description': 'SQL et conception de bases de données',
          'materials': ['Ordinateur portable'],
        },
        {
          'id': '6',
          'title': 'Mathématiques',
          'teacher': widget.isTeacher ? 'Moi' : 'Prof. Bernard',
          'room': 'A101',
          'startTime': '14:00',
          'endTime': '16:00',
          'day': 'Mercredi',
          'color': const Color(0xFF2563EB),
          'type': 'TD',
          'students': widget.isTeacher ? 20 : null,
          'module': 'MAT101',
          'description': 'Exercices d\'application',
          'materials': ['Calculatrice', 'Feuilles d\'exercices'],
        },
        {
          'id': '7',
          'title': 'Anglais',
          'teacher': widget.isTeacher ? 'Moi' : 'Prof. Smith',
          'room': 'F301',
          'startTime': '10:15',
          'endTime': '12:15',
          'day': 'Jeudi',
          'color': const Color(0xFF06B6D4),
          'type': 'Cours magistral',
          'students': widget.isTeacher ? 30 : null,
          'module': 'ANG101',
          'description': 'Business English',
          'materials': ['Manuel d\'anglais'],
        },
        {
          'id': '8',
          'title': 'Sport',
          'teacher': widget.isTeacher ? 'Moi' : 'Prof. Durand',
          'room': 'Gymnase',
          'startTime': '16:00',
          'endTime': '18:00',
          'day': 'Jeudi',
          'color': const Color(0xFF10B981),
          'type': 'Activité physique',
          'students': widget.isTeacher ? 50 : null,
          'module': 'SPO101',
          'description': 'Basket-ball',
          'materials': ['Tenue de sport'],
        },
      ];

      // Créer les événements pour le calendrier
      _events = <DateTime, List<Map<String, dynamic>>>{};
      for (var course in _courses) {
        final dayIndex = _getDayIndex(course['day']);
        if (dayIndex != -1) {
          final now = DateTime.now();
          final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
          final eventDate = currentWeekStart.add(Duration(days: dayIndex - 1));
          final dateKey = DateTime(eventDate.year, eventDate.month, eventDate.day);
          
          if (_events[dateKey] == null) {
            _events[dateKey] = [];
          }
          _events[dateKey]!.add({
            'title': course['title'],
            'time': '${course['startTime']} - ${course['endTime']}',
            'room': course['room'],
            'color': course['color'],
          });
        }
      }
    });
  }

  int _getDayIndex(String day) {
    switch (day) {
      case 'Lundi': return 1;
      case 'Mardi': return 2;
      case 'Mercredi': return 3;
      case 'Jeudi': return 4;
      case 'Vendredi': return 5;
      case 'Samedi': return 6;
      case 'Dimanche': return 7;
      default: return -1;
    }
  }

  List<Map<String, dynamic>> get _coursesForSelectedDay {
    if (_selectedDay == null) return [];
    
    final dayIndex = _selectedDay!.weekday;
    String dayName = '';
    switch (dayIndex) {
      case 1: dayName = 'Lundi'; break;
      case 2: dayName = 'Mardi'; break;
      case 3: dayName = 'Mercredi'; break;
      case 4: dayName = 'Jeudi'; break;
      case 5: dayName = 'Vendredi'; break;
      case 6: dayName = 'Samedi'; break;
      case 7: dayName = 'Dimanche'; break;
    }
    
    return _courses.where((course) => course['day'] == dayName).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emploi du Temps',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${_courses.length} cours cette semaine',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.isTeacher || widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
              onPressed: _showAddCourseDialog,
            ),
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF64748B)),
            onPressed: _exportSchedule,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
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
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un cours...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Sélecteur de vue
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedView,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                            items: ['Jour', 'Semaine', 'Mois']
                                .map((view) => DropdownMenuItem(
                                      value: view,
                                      child: Text(
                                        view,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedView = value!;
                                switch (value) {
                                  case 'Jour':
                                    _calendarFormat = CalendarFormat.week;
                                    break;
                                  case 'Semaine':
                                    _calendarFormat = CalendarFormat.week;
                                    break;
                                  case 'Mois':
                                    _calendarFormat = CalendarFormat.month;
                                    break;
                                }
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
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: 'Tous les cours',
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                            items: ['Tous les cours', 'Cours magistraux', 'TP', 'TD', 'Projets']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {});
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
          
          // Calendrier
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 400,
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
          
          // Liste des cours du jour sélectionné
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedDay != null) ...[
                    Text(
                      'Cours du ${_formatDate(_selectedDay!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: _coursesForSelectedDay.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _coursesForSelectedDay.length,
                            itemBuilder: (context, index) {
                              final course = _coursesForSelectedDay[index];
                              return _buildCourseCard(course);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: (widget.isTeacher || widget.isAdmin)
          ? FloatingActionButton.extended(
              onPressed: _showAddCourseDialog,
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter cours'),
            )
          : null,
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(color: course['color'].withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: course['color'],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: course['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course['type'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: course['color'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: course['color'],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course['teacher'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: course['color'],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course['room'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: course['color'],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course['startTime']} - ${course['endTime']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (course['module'] != null) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                course['module'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                          if (course['students'] != null) ...[
                            const Spacer(),
                            Row(
                              children: [
                                Icon(
                                  Icons.groups,
                                  size: 14,
                                  color: course['color'],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${course['students']} étudiants',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      if (course['description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          course['description'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      if (course['materials'] != null && course['materials'].isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 14,
                              color: course['color'],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Matériel: ${(course['materials'] as List<String>).join(', ')}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewCourseDetails(course),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: course['color']),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Détails',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: course['color'],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.isTeacher)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _manageCourse(course),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: course['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Gérer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _joinCourse(course),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: course['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Rejoindre',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
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
            child: const Icon(
              Icons.event_available,
              color: Color(0xFF2563EB),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun cours ce jour',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Profitez de votre journée libre!',
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

  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un cours'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Titre du cours',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Salle',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Heure début',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Heure fin',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cours ajouté avec succès!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _viewCourseDetails(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(course['title']),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enseignant: ${course['teacher']}'),
                Text('Salle: ${course['room']}'),
                Text('Horaire: ${course['startTime']} - ${course['endTime']}'),
                Text('Type: ${course['type']}'),
                if (course['module'] != null) Text('Module: ${course['module']}'),
                if (course['description'] != null) ...[
                  const SizedBox(height: 8),
                  const Text('Description:'),
                  Text(course['description']),
                ],
                if (course['materials'] != null && course['materials'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Matériel requis:'),
                  ...(course['materials'] as List<String>).map((material) => Text('• $material')),
                ],
                if (course['students'] != null) Text('Nombre d\'étudiants: ${course['students']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _manageCourse(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gérer ${course['title']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Modifier le cours'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Modification du cours...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Gérer les étudiants'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gestion des étudiants...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                title: const Text('Supprimer le cours', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cours supprimé'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _joinCourse(Map<String, dynamic> course) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rejoint ${course['title']} avec succès!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _exportSchedule() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exporter l\'emploi du temps'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF2563EB)),
                title: const Text('Calendrier Google'),
                subtitle: const Text('Synchroniser avec Google Calendar'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Synchronisation en cours...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
                title: const Text('PDF'),
                subtitle: const Text('Télécharger en format PDF'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Génération du PDF...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Color(0xFF10B981)),
                title: const Text('Excel'),
                subtitle: const Text('Exporter en format Excel'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export Excel...')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }
}
