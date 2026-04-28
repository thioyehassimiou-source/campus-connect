import 'package:supabase_flutter/supabase_flutter.dart';

class Room {
  final String id;
  final String nom;
  final String bloc;
  final int capacite;
  final String type;
  final List<String> equipements;
  final String statut;

  Room({
    required this.id,
    required this.nom,
    required this.bloc,
    required this.capacite,
    required this.type,
    required this.equipements,
    required this.statut,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      bloc: json['bloc'] ?? '',
      capacite: json['capacite'] ?? 0,
      type: json['type'] ?? 'Cours',
      equipements: List<String>.from(json['equipements'] ?? []),
      statut: json['statut'] ?? 'Disponible',
    );
  }
}

class RoomBooking {
  final String id;
  final String roomId;
  final String userId;
  final String? userName;
  final String motif;
  final DateTime dateEvenement;
  final String heureDebut;
  final String heureFin;
  final String statut;
  final String? commentaireAdmin;

  RoomBooking({
    required this.id,
    required this.roomId,
    required this.userId,
    this.userName,
    required this.motif,
    required this.dateEvenement,
    required this.heureDebut,
    required this.heureFin,
    required this.statut,
    this.commentaireAdmin,
  });

  factory RoomBooking.fromJson(Map<String, dynamic> json) {
    return RoomBooking(
      id: json['id'] ?? '',
      roomId: json['room_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'],
      motif: json['motif'] ?? '',
      dateEvenement: DateTime.parse(json['date_evenement']),
      heureDebut: json['heure_debut'] ?? '',
      heureFin: json['heure_fin'] ?? '',
      statut: json['statut'] ?? 'En attente',
      commentaireAdmin: json['commentaire_admin'],
    );
  }
}

class RoomService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupérer toutes les salles
  static Future<List<Room>> getAllRooms() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .order('bloc', ascending: true)
          .order('nom', ascending: true);
      
      return (response as List).map((json) => Room.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur RoomService.getAllRooms: $e');
      return [];
    }
  }

  /// Récupérer les salles d'un bloc spécifique
  static Future<List<Room>> getRoomsByBloc(String bloc) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('bloc', bloc)
          .order('nom', ascending: true);
      
      return (response as List).map((json) => Room.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur RoomService.getRoomsByBloc: $e');
      return [];
    }
  }

  /// Créer ou mettre à jour une salle (Admin Only)
  static Future<void> upsertRoom(Map<String, dynamic> roomData) async {
    await _supabase.from('rooms').upsert(roomData);
  }

  /// Supprimer une salle
  static Future<void> deleteRoom(String roomId) async {
    await _supabase.from('rooms').delete().eq('id', roomId);
  }

  /// Réserver une salle
  static Future<void> createBooking({
    required String roomId,
    required String motif,
    required DateTime date,
    required String debut,
    required String fin,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('room_bookings').insert({
      'room_id': roomId,
      'user_id': user.id,
      'motif': motif,
      'date_evenement': date.toIso8601String().split('T')[0],
      'heure_debut': debut,
      'heure_fin': fin,
    });
  }

  /// Récupérer les réservations
  static Future<List<RoomBooking>> getBookings({bool onlyMine = false}) async {
    try {
      var query = _supabase.from('room_bookings').select('''
        *,
        rooms(nom, bloc)
      ''');

      if (onlyMine) {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          query = query.eq('user_id', user.id);
        }
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List).map((json) => RoomBooking.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur RoomService.getBookings: $e');
      return [];
    }
  }

  /// Valider ou rejeter une réservation (Admin Only)
  static Future<void> updateBookingStatus(String bookingId, String status, {String? commentaire}) async {
    await _supabase.from('room_bookings').update({
      'statut': status,
      'commentaire_admin': commentaire,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', bookingId);
  }
}
