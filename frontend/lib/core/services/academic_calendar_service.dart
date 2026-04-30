import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

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
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dateDebut: json['date_debut'] != null ? DateTime.parse(json['date_debut']) : DateTime.now(),
      dateFin: json['date_fin'] != null ? DateTime.parse(json['date_fin']) : null,
      type: json['type'] ?? 'Académique',
      priority: json['priority'] ?? 'Moyenne',
      color: color,
      isRecurring: json['is_recurring'] ?? false,
    );
  }
}

class AcademicCalendarService {
  /// Récupérer tous les événements du calendrier via REST
  static Future<List<AcademicEvent>> getAcademicEvents() async {
    try {
      final response = await ApiService.getAcademicEvents();
      
      if (response.success && response.data != null) {
        return response.data!.map((json) => AcademicEvent.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur AcademicCalendarService.getAcademicEvents: $e');
      return [];
    }
  }

  /// Ajouter un événement (Admin Only) via REST
  static Future<void> addEvent(Map<String, dynamic> eventData) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');
      
      final response = await ApiService.addAcademicEvent(eventData, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de l\'ajout de l\'événement');
      }
    } catch (e) {
      print('❌ Erreur ajout événement: $e');
      rethrow;
    }
  }

  /// Supprimer un événement via REST
  static Future<void> deleteEvent(String eventId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');
      
      final response = await ApiService.deleteAcademicEvent(eventId, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      print('❌ Erreur suppression événement: $e');
      rethrow;
    }
  }
}
