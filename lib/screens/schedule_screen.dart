import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/shared/models/schedule_model.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:campusconnect/core/services/firebase_service.dart';

class ScheduleScreen extends StatefulWidget {
  final UserModel user;

  const ScheduleScreen({super.key, required this.user});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<ScheduleModel> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);

    try {
      QuerySnapshot querySnapshot;
      
      if (widget.user.role == UserRole.teacher) {
        // Teacher sees their own courses
        querySnapshot = await FirebaseService.firestore
            .collection('schedules')
            .where('teacherId', isEqualTo: widget.user.id)
            .get();
      } else {
        // Student sees courses they're enrolled in
        querySnapshot = await FirebaseService.firestore
            .collection('schedules')
            .where('studentIds', arrayContains: widget.user.id)
            .get();
      }

      final schedules = querySnapshot.docs
          .map((doc) => ScheduleModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  List<ScheduleModel> _getSchedulesForDay(DateTime day) {
    return _schedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.startTime.year,
        schedule.startTime.month,
        schedule.startTime.day,
      );
      final selectedDate = DateTime(day.year, day.month, day.day);
      return scheduleDate.isAtSameMomentAs(selectedDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emploi du temps'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchedules,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendar
                Card(
                  margin: const EdgeInsets.all(16),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) {
                      return _getSchedulesForDay(day);
                    },
                    calendarStyle: const CalendarStyle(
                      markersMaxCount: 3,
                      markerDecoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Schedule List
                Expanded(
                  child: _selectedDay != null
                      ? _buildScheduleList(_getSchedulesForDay(_selectedDay!))
                      : const Center(
                          child: Text('Sélectionnez une date'),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildScheduleList(List<ScheduleModel> schedules) {
    if (schedules.isEmpty) {
      return const Center(
        child: Text('Aucun cours prévu pour ce jour'),
      );
    }

    // Sort schedules by start time
    schedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return _buildScheduleCard(schedule);
      },
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(schedule.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    schedule.typeDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${DateFormat.Hm().format(schedule.startTime)} - ${DateFormat.Hm().format(schedule.endTime)}',
                  style: AppTheme.captionStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              schedule.courseName,
              style: AppTheme.subheadingStyle,
            ),
            
            const SizedBox(height: 4),
            
            if (schedule.teacherName.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    schedule.teacherName,
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
            ],
            
            if (schedule.classroom != null && schedule.classroom!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    schedule.classroom!,
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
            ],
            
            if (schedule.description != null && schedule.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                schedule.description!,
                style: AppTheme.bodyStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(CourseType type) {
    switch (type) {
      case CourseType.lecture:
        return AppTheme.primaryColor;
      case CourseType.tutorial:
        return AppTheme.successColor;
      case CourseType.lab:
        return AppTheme.warningColor;
      case CourseType.exam:
        return AppTheme.errorColor;
      case CourseType.meeting:
        return Colors.purple;
    }
  }
}
