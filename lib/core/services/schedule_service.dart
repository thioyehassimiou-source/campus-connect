import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleItem {
  final String id;
  final String subject;
  final String teacher;
  final String teacherId; // Alias pour compatibilité
  final DateTime startTime;
  final DateTime endTime;
  final String room;
  final int day;
  final String type; // CM, TD, TP
  final String color;
  final int status; // 0=Scheduled, 1=Cancelled, 2=Moved, 3=Pending, 4=Rejected
  final String? notes;
  final String? niveau;
  final int? departmentId;
  final String? scope;
  final String? facultyId;

  ScheduleItem({
    required this.id,
    required this.subject,
    required this.teacher,
    String? teacherId,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.day,
    this.type = 'CM',
    this.color = '#1F77D2',
    this.status = 0,
    this.notes,
    this.niveau,
    this.departmentId,
    this.scope,
    this.facultyId,
  }) : teacherId = teacherId ?? teacher;

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'],
      subject: json['subject'] ?? 'Sans titre',
      teacher: json['teacher'] ?? 'Inconnu',
      teacherId: json['teacher_id']?.toString() ?? json['teacher'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      room: json['room'] ?? 'N/A',
      day: json['day'] ?? 0,
      type: json['type'] ?? 'CM',
      color: json['color'] ?? '#1F77D2',
      status: json['status'] is int ? json['status'] : (json['status'] == 'validated' ? 0 : (json['status'] == 'pending' ? 3 : 0)),
      notes: json['notes'],
      niveau: json['niveau'],
      departmentId: json['department_id'],
      scope: json['scope'],
      facultyId: json['faculty_id'],
    );
  }
}

class ScheduleService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupérer l'emploi du temps (Pour Étudiants)
  static Future<List<ScheduleItem>> getValidatedSchedule() async {
    try {
      final response = await _supabase
          .from('schedules')
          .select()
          .eq('status', 0) // 0 = Scheduled / Validated
          .order('start_time', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => ScheduleItem.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur récupération emploi du temps: $e');
      return [];
    }
  }

  /// Récupérer les cours d'un enseignant
  static Future<List<ScheduleItem>> getTeacherProposals() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      // On essaie de filtrer par teacher_id s'il existe, sinon par nom (moins fiable)
      // Pour l'instant on fetch tout et on pourra filtrer localement ou via une colonne ajoutée
      final response = await _supabase
          .from('schedules')
          .select()
          .order('start_time', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => ScheduleItem.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur récupération cours prof: $e');
      return [];
    }
  }

  /// Récupérer tous les créneaux (Pour Admin)
  static Future<List<ScheduleItem>> getPendingSchedules() async {
    try {
      final response = await _supabase
          .from('schedules')
          .select()
          .order('start_time', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => ScheduleItem.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur récupération tous les créneaux: $e');
      return [];
    }
  }

  /// Ajouter un cours
  static Future<void> proposeSchedule({
    required String subject,
    String? teacher,
    required DateTime startTime,
    required DateTime endTime,
    required String room,
    required int day,
    String? niveau,
    String type = 'CM',
    String scope = 'license',
    int? departmentId,
    String? facultyId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      final teacherName = teacher ?? user?.userMetadata?['full_name'] ?? 'Enseignant';
      
      await _supabase.from('schedules').insert({
        'subject': subject,
        'teacher': teacherName,
        'teacher_id': user?.id, // Link to auth user
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'room': room,
        'day': day,
        'status': 3, // 3 = Pending
        'niveau': niveau,
        'type': type,
        'scope': scope,
        'department_id': departmentId,
        'faculty_id': facultyId,
      });
    } catch (e) {
        print('❌ Erreur ajout cours: $e');
        rethrow;
    }
  }

  /// Valider un créneau (Directeur)
  static Future<void> validateSchedule(String scheduleId) async {
    try {
      await _supabase
          .from('schedules')
          .update({'status': 0}) // 0 = Validated/Scheduled
          .eq('id', scheduleId);
    } catch (e) {
      print('❌ Erreur validation créneau: $e');
      rethrow;
    }
  }

  /// Rejeter un créneau (Directeur)
  static Future<void> rejectSchedule(String scheduleId, String reason) async {
    try {
      await _supabase
          .from('schedules')
          .update({'status': 4, 'notes': reason}) // 4 = Rejected
          .eq('id', scheduleId);
    } catch (e) {
      print('❌ Erreur rejet créneau: $e');
      rethrow;
    }
  }

  /// Annuler un cours
  static Future<void> cancelSchedule(String scheduleId) async {
    try {
      await _supabase
          .from('schedules')
          .update({'status': 1}) // 1 = Cancelled
          .eq('id', scheduleId);
    } catch (e) {
      print('❌ Erreur annulation cours: $e');
      rethrow;
    }
  }
}
