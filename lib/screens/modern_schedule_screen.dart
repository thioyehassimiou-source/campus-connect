import 'package:flutter/material.dart';

class ModernScheduleScreen extends StatefulWidget {
  const ModernScheduleScreen({super.key});

  @override
  State<ModernScheduleScreen> createState() => _ModernScheduleScreenState();
}

class _ModernScheduleScreenState extends State<ModernScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  int selectedDayIndex = DateTime.now().weekday - 1; // 0 = Lundi
  
  final List<String> weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final List<String> fullWeekDays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  
  final Map<String, List<Map<String, dynamic>>> weekSchedule = {
    'Lundi': [
      {'subject': 'Mathématiques', 'time': '08:00-09:30', 'room': 'Amphi A', 'teacher': 'Dr. Martin', 'type': 'CM'},
      {'subject': 'Physique', 'time': '10:00-11:30', 'room': 'Labo B205', 'teacher': 'Prof. Dubois', 'type': 'TP'},
      {'subject': 'Anglais', 'time': '14:00-15:30', 'room': 'Salle C302', 'teacher': 'Mme. Bernard', 'type': 'TD'},
    ],
    'Mardi': [
      {'subject': 'Informatique', 'time': '08:00-10:00', 'room': 'Labo Info', 'teacher': 'Dr. Robert', 'type': 'TP'},
      {'subject': 'Chimie', 'time': '10:30-12:00', 'room': 'Labo Chimie', 'teacher': 'Prof. Laurent', 'type': 'TP'},
      {'subject': 'Économie', 'time': '14:00-15:30', 'room': 'Salle D201', 'teacher': 'Dr. Petit', 'type': 'CM'},
    ],
    'Mercredi': [
      {'subject': 'Mathématiques', 'time': '08:00-09:30', 'room': 'Salle A101', 'teacher': 'Dr. Martin', 'type': 'TD'},
      {'subject': 'Physique', 'time': '10:00-11:30', 'room': 'Salle B201', 'teacher': 'Prof. Dubois', 'type': 'CM'},
      {'subject': 'Sport', 'time': '15:00-17:00', 'room': 'Gymnase', 'teacher': 'M. Durand', 'type': 'Autre'},
    ],
    'Jeudi': [
      {'subject': 'Informatique', 'time': '08:00-09:30', 'room': 'Salle C301', 'teacher': 'Dr. Robert', 'type': 'CM'},
      {'subject': 'Chimie', 'time': '10:00-11:30', 'room': 'Salle D101', 'teacher': 'Prof. Laurent', 'type': 'TD'},
      {'subject': 'Anglais', 'time': '14:00-15:30', 'room': 'Salle E201', 'teacher': 'Mme. Bernard', 'type': 'CM'},
    ],
    'Vendredi': [
      {'subject': 'Mathématiques', 'time': '08:00-10:00', 'room': 'Amphi B', 'teacher': 'Dr. Martin', 'type': 'CM'},
      {'subject': 'Économie', 'time': '10:30-12:00', 'room': 'Salle F301', 'teacher': 'Dr. Petit', 'type': 'TD'},
      {'subject': 'Projet', 'time': '14:00-17:00', 'room': 'Labo Projet', 'teacher': 'M. Leroy', 'type': 'Projet'},
    ],
    'Samedi': [],
    'Dimanche': [],
  };

  @override
  Widget build(BuildContext context) {
    final currentDayCourses = weekSchedule[fullWeekDays[selectedDayIndex]] ?? [];
    
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
              'Emploi du temps',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}',
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
            icon: Icon(Icons.calendar_month, color: Color(0xFF64748B)),
            onPressed: () {
              _showCalendarDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélecteur de jour
          _buildDaySelector(),
          
          // Liste des cours
          Expanded(
            child: currentDayCourses.isEmpty
                ? _buildEmptySchedule()
                : _buildCourseList(currentDayCourses),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // En-tête de la semaine
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Semaine du ${DateTime.now().day} ${_getMonthName(DateTime.now().month)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _showCalendarDialog();
                  },
                  child: Text(
                    'Voir calendrier',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Sélecteur de jours
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5, // Lundi à Vendredi
              itemBuilder: (context, index) {
                final isSelected = selectedDayIndex == index;
                final dayDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1 - index));
                final isToday = dayDate.day == DateTime.now().day && 
                               dayDate.month == DateTime.now().month;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDayIndex = index;
                      selectedDate = dayDate;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekDays[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dayDate.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        if (isToday)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Auj.',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(List<Map<String, dynamic>> courses) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
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
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barre latérale colorée
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: _getCourseTypeColor(course['type']),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                // Contenu du cours
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête du cours
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                course['subject'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCourseTypeColor(course['type']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                course['type'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getCourseTypeColor(course['type']),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Informations du cours en grille
                        Row(
                          children: [
                            // Heure
                            Expanded(
                              child: _buildCourseInfo(
                                Icons.access_time,
                                course['time'],
                                'Horaires',
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Salle
                            Expanded(
                              child: _buildCourseInfo(
                                Icons.room_outlined,
                                course['room'],
                                'Salle',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Enseignant
                        _buildCourseInfo(
                          Icons.person_outline,
                          course['teacher'],
                          'Enseignant',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseInfo(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySchedule() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.event_available,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun cours aujourd\'hui',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Profitez de votre journée libre',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCourseTypeColor(String type) {
    switch (type) {
      case 'CM':
        return const Color(0xFF2563EB);
      case 'TD':
        return const Color(0xFF10B981);
      case 'TP':
        return const Color(0xFFF59E0B);
      case 'Projet':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getMonthName(int month) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return months[month - 1];
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Calendrier'),
          content: Text('Vue calendrier complète en cours de développement.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
