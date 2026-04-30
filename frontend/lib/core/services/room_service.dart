import '../../services/api_service.dart';
import '../../services/auth_service.dart';

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
      id: json['id']?.toString() ?? '',
      nom: json['nom'] ?? '',
      bloc: json['bloc'] ?? '',
      capacite: json['capacite'] ?? 0,
      type: json['type'] ?? 'Cours',
      equipements: json['equipements'] != null ? List<String>.from(json['equipements']) : [],
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
      id: json['id']?.toString() ?? '',
      roomId: json['room_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? json['user']?['nom'],
      motif: json['motif'] ?? '',
      dateEvenement: json['date_evenement'] != null ? DateTime.parse(json['date_evenement']) : DateTime.now(),
      heureDebut: json['heure_debut'] ?? '',
      heureFin: json['heure_fin'] ?? '',
      statut: json['statut'] ?? 'En attente',
      commentaireAdmin: json['commentaire_admin'],
    );
  }
}

class RoomService {
  /// Récupérer toutes les salles via REST
  static Future<List<Room>> getAllRooms() async {
    try {
      final response = await ApiService.getAllRooms();
      if (response.success && response.data != null) {
        return response.data!.map((json) => Room.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur RoomService.getAllRooms: $e');
      return [];
    }
  }

  /// Récupérer les salles d'un bloc spécifique via REST
  static Future<List<Room>> getRoomsByBloc(String bloc) async {
    try {
      final response = await ApiService.getRoomsByBloc(bloc);
      if (response.success && response.data != null) {
        return response.data!.map((json) => Room.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur RoomService.getRoomsByBloc: $e');
      return [];
    }
  }

  /// Créer ou mettre à jour une salle (Admin Only) via REST
  static Future<void> upsertRoom(Map<String, dynamic> roomData) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');
      
      final response = await ApiService.upsertRoom(roomData, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la mise à jour de la salle');
      }
    } catch (e) {
      print('❌ Erreur upsertRoom: $e');
      rethrow;
    }
  }

  /// Supprimer une salle via REST
  static Future<void> deleteRoom(String roomId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');
      
      final response = await ApiService.deleteRoom(roomId, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      print('❌ Erreur deleteRoom: $e');
      rethrow;
    }
  }

  /// Réserver une salle via REST
  static Future<void> createBooking({
    required String roomId,
    required String motif,
    required DateTime date,
    required String debut,
    required String fin,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final data = {
        'room_id': roomId,
        'motif': motif,
        'date_evenement': date.toIso8601String().split('T')[0],
        'heure_debut': debut,
        'heure_fin': fin,
      };

      final response = await ApiService.createRoomBooking(data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la réservation');
      }
    } catch (e) {
      print('❌ Erreur création réservation: $e');
      rethrow;
    }
  }

  /// Récupérer les réservations via REST
  static Future<List<RoomBooking>> getBookings({bool onlyMine = false}) async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiService.getRoomBookings(onlyMine: onlyMine, token: token);
      
      if (response.success && response.data != null) {
        return response.data!.map((json) => RoomBooking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur RoomService.getBookings: $e');
      return [];
    }
  }

  /// Valider ou rejeter une réservation (Admin Only) via REST
  static Future<void> updateBookingStatus(String bookingId, String status, {String? commentaire}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final data = {
        'statut': status,
        'commentaire_admin': commentaire,
      };

      final response = await ApiService.updateBookingStatus(bookingId, data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la mise à jour du statut');
      }
    } catch (e) {
      print('❌ Erreur updateBookingStatus: $e');
      rethrow;
    }
  }
}
