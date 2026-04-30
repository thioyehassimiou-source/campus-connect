import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AdminStats {
  final int totalUsers;
  final int totalAnnouncements;
  final int totalRooms;
  final int activeServices;
  final Map<String, int> usersByRole;

  AdminStats({
    required this.totalUsers,
    required this.totalAnnouncements,
    required this.totalRooms,
    required this.activeServices,
    required this.usersByRole,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['total_users'] ?? 0,
      totalAnnouncements: json['total_announcements'] ?? 0,
      totalRooms: json['total_rooms'] ?? 0,
      activeServices: json['active_services'] ?? 0,
      usersByRole: Map<String, int>.from(json['users_by_role'] ?? {}),
    );
  }
}

class AdminService {
  /// Récupère les statistiques globales pour le dashboard admin via REST
  static Future<AdminStats> getGlobalStats() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await ApiService.getAdminStats(token);

      if (response.success && response.data != null) {
        return AdminStats.fromJson(response.data!);
      }
      
      return AdminStats(
        totalUsers: 0,
        totalAnnouncements: 0,
        totalRooms: 0,
        activeServices: 0,
        usersByRole: {},
      );
    } catch (e) {
      print('❌ Erreur AdminStats: $e');
      return AdminStats(
        totalUsers: 0,
        totalAnnouncements: 0,
        totalRooms: 0,
        activeServices: 0,
        usersByRole: {},
      );
    }
  }

  /// Récupère la liste complète des profils utilisateurs via REST
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getAllUsers(token);
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('❌ Erreur GetAllUsers: $e');
      return [];
    }
  }

  /// Supprimer un utilisateur via REST
  static Future<void> deleteUser(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await ApiService.deleteUser(userId, token: token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      print('❌ Erreur deleteUser: $e');
      rethrow;
    }
  }

  /// Créer un utilisateur (Par un Admin) via REST
  static Future<void> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final data = {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
      };

      final response = await ApiService.createUser(data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la création de l\'utilisateur');
      }
    } catch (e) {
      print('❌ Erreur createUser: $e');
      rethrow;
    }
  }
}
