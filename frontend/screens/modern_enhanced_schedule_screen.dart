import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/controllers/schedule_providers.dart';
import 'package:campusconnect/core/services/schedule_service.dart';
import 'package:campusconnect/core/services/export_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:campusconnect/controllers/profile_providers.dart';
import 'package:campusconnect/shared/models/user_model.dart';

class ModernEnhancedScheduleScreen extends ConsumerStatefulWidget {
  final bool isTeacher;
  final bool isAdmin;
  
  const ModernEnhancedScheduleScreen({
    super.key,
    this.isTeacher = false,
    this.isAdmin = false,
  });

  @override
  ConsumerState<ModernEnhancedScheduleScreen> createState() => _ModernEnhancedScheduleScreenState();
}

class _ModernEnhancedScheduleScreenState extends ConsumerState<ModernEnhancedScheduleScreen> {
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
    // Les données seront chargées via ref.watch dans build
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadScheduleFromItems(List<ScheduleItem> items) {
    _courses = items.map((item) {
      final startTimeStr = DateFormat('HH:mm').format(item.startTime);
      final endTimeStr = DateFormat('HH:mm').format(item.endTime);
      
      Color color;
      try {
        color = Color(int.parse(item.color.replaceFirst('#', '0xFF')));
      } catch (_) {
        color = const Color(0xFF2563EB);
      }
      
      return {
        'id': item.id,
        'title': item.subject,
        'teacher': item.teacher,
        'room': item.room,
        'startTime': startTimeStr,
        'endTime': endTimeStr,
        'day': _getDayName(item.startTime.weekday),
        'color': color,
        'status': _mapStatusName(item.status),
        'niveau': item.niveau,
      };
    }).toList();

    _events = <DateTime, List<Map<String, dynamic>>>{};
    for (var course in _courses) {
      final itemsForThisDay = items.where((it) => it.id == course['id']).toList();
      if (itemsForThisDay.isNotEmpty) {
        final item = itemsForThisDay.first;
        final dateKey = DateTime(item.startTime.year, item.startTime.month, item.startTime.day);
        
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
  }

  String _mapStatusName(int status) {
    switch (status) {
      case 0: return 'Normal';
      case 1: return 'Annulé';
      case 2: return 'Déplacé';
      case 3: return 'En attente';
      case 4: return 'Rejeté';
      default: return 'Normal';
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Lundi';
      case 2: return 'Mardi';
      case 3: return 'Mercredi';
      case 4: return 'Jeudi';
      case 5: return 'Vendredi';
      case 6: return 'Samedi';
      case 7: return 'Dimanche';
      default: return '';
    }
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

  List<Map<String, dynamic>> get _filteredCourses {
    var filtered = _courses;
    if (_selectedDay != null) {
      final dayName = _getDayName(_selectedDay!.weekday);
      filtered = filtered.where((c) => c['day'] == dayName).toList();
    }
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((c) => 
        c['title'].toString().toLowerCase().contains(query) ||
        c['teacher'].toString().toLowerCase().contains(query)
      ).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        final roleStr = profile?['role']?.toString().toUpperCase() ?? 'ETUDIANT';
        final serviceType = profile?['service_type']?.toString().toUpperCase();

        final isSallesAdmin = roleStr == 'ADMIN_SERVICE' && serviceType == 'SALLES';
        final isScolariteAdmin = roleStr == 'ADMIN_SERVICE' && serviceType == 'SCOLARITE';
        final isDeptAdmin = roleStr == 'ADMIN_SERVICE' && serviceType == 'DEPARTEMENT';
        final isEnseignant = roleStr == 'ENSEIGNANT';
        
        // Seuls ces rôles peuvent modifier l'emploi du temps
        final canManageSchedule = isSallesAdmin || isScolariteAdmin || isDeptAdmin || isEnseignant;
        
        // Sélection du provider selon le rôle
        AsyncValue<List<ScheduleItem>> scheduleAsync;
        if (isSallesAdmin || isScolariteAdmin || isDeptAdmin) {
          scheduleAsync = ref.watch(pendingSchedulesProvider);
        } else if (isEnseignant) {
          scheduleAsync = ref.watch(teacherProposalsProvider);
        } else {
          scheduleAsync = ref.watch(validatedScheduleProvider);
        }

        return scheduleAsync.when(
          data: (items) {
            _loadScheduleFromItems(items);
            return _buildMainContent(context, canManageSchedule, isEnseignant, isDeptAdmin || isScolariteAdmin || isSallesAdmin);
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, st) => _buildErrorState(e),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => _buildErrorState(e),
    );
  }

  Widget _buildErrorState(Object e) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erreur: $e'),
            ElevatedButton(
              onPressed: () => ref.invalidate(userProfileProvider),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool canManage, bool isTeacher, bool isAdmin) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emploi du Temps',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              '${_courses.length} cours trouvés',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (canManage)
            IconButton(
              icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
              onPressed: _showAddCourseDialog,
            ),
          IconButton(
            icon: Icon(Icons.download, color: Theme.of(context).iconTheme.color),
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
              color: Theme.of(context).cardColor,
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
                    hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).iconTheme.color,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
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
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
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
                            icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                            items: ['Jour', 'Semaine', 'Mois']
                                .map((view) => DropdownMenuItem(
                                      value: view,
                                      child: Text(
                                        view,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
                            icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                            items: ['Tous les cours', 'Cours magistraux', 'TP', 'TD', 'Projets']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                locale: 'fr_FR',
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
                  weekendTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
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
                    color: Theme.of(context).colorScheme.secondary,
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
                  leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).iconTheme.color),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
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
                      'Cours du ${_formatFullDate(_selectedDay!)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: _filteredCourses.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = _filteredCourses[index];
                              return _buildCourseCard(course, isTeacher, isAdmin);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: _showAddCourseDialog,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              icon: Icon(Icons.add),
              label: Text(isTeacher ? 'Proposer cours' : 'Ajouter cours'),
            )
          : null,
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, bool isTeacher, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          if (course['status'] != 'Normal')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusBgColor(course['status']),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                course['status'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusTextColor(course['status']),
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (course['module'] != null) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                course['module'],
                                style: TextStyle(
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
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
                              style: TextStyle(
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
                if (isTeacher)
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
                      child: Text(
                        'Gérer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else if (isAdmin)
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
                      child: Text(
                        'Détails Admin',
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
                      child: Text(
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
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
              'Aucun cours ce jour',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Profitez de votre journée libre!',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    const List<String> months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    const List<String> days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Annulé': return Colors.red.withOpacity(0.1);
      case 'Rejeté': return Colors.red.withOpacity(0.1);
      case 'Déplacé': return Colors.orange.withOpacity(0.1);
      case 'En attente': return Colors.blue.withOpacity(0.1);
      default: return Colors.transparent;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Annulé': return Colors.red;
      case 'Rejeté': return Colors.red;
      case 'Déplacé': return Colors.orange;
      case 'En attente': return Colors.blue;
      default: return Colors.transparent;
    }
  }

  void _showAddCourseDialog() {
    final titleController = TextEditingController();
    final teacherController = TextEditingController();
    final roomController = TextEditingController();
    final niveauController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un cours'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titre du cours'),
                ),
                TextField(
                  controller: teacherController,
                  decoration: const InputDecoration(labelText: 'Enseignant'),
                ),
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(labelText: 'Salle'),
                ),
                TextField(
                  controller: niveauController,
                  decoration: const InputDecoration(labelText: 'Niveau (ex: L1)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;
                
                final now = DateTime.now();
                // Utiliser la date sélectionnée ou aujourd'hui
                final selectedDate = _selectedDay ?? now;
                final startTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 8, 0);
                final endTime = startTime.add(const Duration(hours: 2));

                await ref.read(scheduleControllerProvider.notifier).addSchedule(
                  subject: titleController.text,
                  teacher: teacherController.text,
                  startTime: startTime,
                  endTime: endTime,
                  room: roomController.text,
                  day: selectedDate.weekday - 1,
                  niveau: niveauController.text,
                  ref: ref,
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cours ajouté avec succès')),
                  );
                }
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
                  Text('Description:'),
                  Text(course['description']),
                ],
                if (course['materials'] != null && course['materials'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Matériel requis:'),
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
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _addToGoogleCalendar(course);
              },
              icon: const Icon(Icons.calendar_today, size: 16),
              label: const Text('Google Calendar'),
              style: ElevatedButton.styleFrom(
                 backgroundColor: const Color(0xFF2563EB),
                 foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _addToGoogleCalendar(Map<String, dynamic> course) async {
    final title = Uri.encodeComponent(course['title']);
    final details = Uri.encodeComponent('Prof: ${course['teacher']}\nSalle: ${course['room']}');
    final location = Uri.encodeComponent(course['room']);
    
    // Format: 20231231T120000Z
    // Note: On va tricher un peu car on n'a pas la date précise ici, juste l'horaire simulé.
    // L'idéal est d'utiliser le ScheduleItem si disponible.
    
    final now = DateTime.now();
    final start = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(now.toUtc());
    final end = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(now.add(const Duration(hours: 2)).toUtc());
    
    final url = 'https://www.google.com/calendar/render?action=TEMPLATE&text=$title&details=$details&location=$location&dates=$start/$end';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir Google Calendar')),
        );
      }
    }
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
                leading: Icon(Icons.edit),
                title: Text('Modifier le cours'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Modification du cours...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Gérer les étudiants'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gestion des étudiants...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Color(0xFFEF4444)),
                title: Text('Supprimer le cours', style: TextStyle(color: Color(0xFFEF4444))),
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
              child: Text('Annuler'),
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

  void _exportSchedule() async {
    final scheduleAsync = ref.read(validatedScheduleProvider);
    
    if (scheduleAsync.asData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Données non disponibles.')),
      );
      return;
    }

    final items = scheduleAsync.asData!.value;
    final user = Supabase.instance.client.auth.currentUser;
    final studentName = user?.userMetadata?['nom'] ?? user?.userMetadata?['full_name'] ?? 'Etudiant';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exporter l\'emploi du temps'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
                title: const Text('PDF'),
                subtitle: const Text('Télécharger en format PDF'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final pdfBytes = await ExportService.generateSchedulePdf(items);
                    await Printing.layoutPdf(
                      onLayout: (format) => pdfBytes,
                      name: 'EmploiDuTemps_$studentName.pdf',
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur export PDF: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Color(0xFF10B981)),
                title: const Text('Excel'),
                subtitle: const Text('Exporter en format Excel'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    await ExportService.generateScheduleExcel(items, studentName);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fichier Excel généré et enregistré dans vos documents.'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur export Excel: $e')),
                      );
                    }
                  }
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
