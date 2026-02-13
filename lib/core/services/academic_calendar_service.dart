import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AcademicEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final String type;
  final String priority;
  final Color color;
  final bool isRecurring;

  AcademicEvent({
    required this.id,
    required this.title,
    this.description,
    required this.dateDebut,
    this.dateFin,
    required this.type,
    required this.priority,
    required this.color,
    this.isRecurring = false,
  });

  factory AcademicEvent.fromJson(Map<String, dynamic> json) {
    String colorHex = json['color'] ?? '#2563EB';
    Color color;
    try {
      color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      color = const Color(0xFF2563EB);
    }

    return AcademicEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: json['date_fin'] != null ? DateTime.parse(json['date_fin']) : null,
      type: json['type'] ?? 'Académique',
      priority: json['priority'] ?? 'Moyenne',
      color: color,
      isRecurring: json['is_recurring'] ?? false,
    );
  }
}

class AcademicCalendarService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupérer tous les événements du calendrier
  static Future<List<AcademicEvent>> getAcademicEvents() async {
    try {
      final response = await _supabase
          .from('academic_calendar')
          .select()
          .order('date_debut', ascending: true);
      
      return (response as List).map((json) => AcademicEvent.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur AcademicCalendarService.getAcademicEvents: $e');
      return [];
    }
  }

  /// Ajouter un événement (Admin Only)
  static Future<void> addEvent(Map<String, dynamic> eventData) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    eventData['created_by'] = user.id;
    await _supabase.from('academic_calendar').insert(eventData);
  }

  /// Supprimer un événement
  static Future<void> deleteEvent(String eventId) async {
    await _supabase.from('academic_calendar').delete().eq('id', eventId);
  }
}
