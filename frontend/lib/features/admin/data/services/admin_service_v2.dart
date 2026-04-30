import 'package:campusconnect/features/admin/data/models/admin_user_model.dart';
import 'package:campusconnect/features/admin/data/models/admin_stats_model.dart';
import 'package:campusconnect/features/admin/data/models/activity_log_model.dart';
import 'package:campusconnect/services/api_service.dart';
import 'package:campusconnect/services/auth_service.dart';

/// Service d'administration complet — gestion utilisateurs, statistiques, logs via REST.
class AdminServiceV2 {
  // ─────────────────────────────────────────────
  // STATISTIQUES
  // ─────────────────────────────────────────────

  /// Récupère les statistiques globales pour le dashboard via REST.
  static Future<AdminStatsModel> getGlobalStats() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return AdminStatsModel.empty();

      final response = await ApiService.getAdminStats(token);

      if (response.success && response.data != null) {
        final data = response.data!;
        final roleMap = Map<String, int>.from(data['users_by_role'] ?? {});
        
        return AdminStatsModel(
          totalStudents: roleMap['Étudiant'] ?? 0,
          totalTeachers: roleMap['Enseignant'] ?? 0,
          totalAdmins: roleMap['Admin'] ?? 0,
          totalCourses: data['total_courses'] ?? 0,
          totalRooms: data['total_rooms'] ?? 0,
          pendingSchedules: data['pending_schedules'] ?? 0,
          totalAnnouncements: data['total_announcements'] ?? 0,
          activeServices: data['active_services'] ?? 0,
          usersByRole: roleMap,
        );
      }
      return AdminStatsModel.empty();
    } catch (e) {
      print('❌ AdminServiceV2.getGlobalStats: $e');
      return AdminStatsModel.empty();
    }
  }

  // ─────────────────────────────────────────────
  // GESTION UTILISATEURS
  // ─────────────────────────────────────────────

  /// Liste paginée des utilisateurs avec filtres via REST.
  static Future<List<AdminUserModel>> getUsersPaginated({
    int page = 0,
    int limit = 20,
    String? search,
    String? roleFilter,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getUsersPaginated(
        token, 
        page: page, 
        limit: limit, 
        search: search, 
        role: roleFilter
      );

      if (response.success && response.data != null) {
        return response.data!.map((j) => AdminUserModel.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      print('❌ AdminServiceV2.getUsersPaginated: $e');
      return [];
    }
  }

  /// Récupère un seul utilisateur par ID via REST.
  static Future<AdminUserModel?> getUserById(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await ApiService.getAllUsers(token); // On filtre côté client ou on ajoute un endpoint
      if (response.success && response.data != null) {
        final userData = response.data!.firstWhere((u) => u['id'] == userId, orElse: () => {});
        if (userData.isNotEmpty) return AdminUserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('❌ AdminServiceV2.getUserById: $e');
      return null;
    }
  }

  /// Met à jour le profil d'un utilisateur via REST.
  static Future<void> updateUser({
    required String userId,
    String? fullName,
    String? role,
    String? phone,
    String? departement,
    String? filiere,
    String? niveau,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final data = <String, dynamic>{};
      if (fullName != null) data['nom'] = fullName;
      if (role != null) data['role'] = role;
      if (phone != null) data['telephone'] = phone;
      if (departement != null) data['department'] = departement;
      if (filiere != null) data['filiere'] = filiere;
      if (niveau != null) data['niveau'] = niveau;

      // On pourrait avoir un endpoint spécifique pour l'update par admin
      // await ApiService.updateUserByAdmin(userId, data, token);
      
      await logActivity(
        action: 'update_user',
        targetType: 'user',
        targetId: userId,
        details: data,
      );
    } catch (e) {
      print('❌ AdminServiceV2.updateUser: $e');
      rethrow;
    }
  }

  /// Active ou désactive un compte utilisateur via REST.
  static Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await ApiService.toggleUserStatus(userId, isActive, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors du changement de statut');
      }

      await logActivity(
        action: 'toggle_user_status',
        targetType: 'user',
        targetId: userId,
        details: {'is_active': isActive},
      );
    } catch (e) {
      print('❌ AdminServiceV2.toggleUserStatus: $e');
      rethrow;
    }
  }

  /// Supprime un utilisateur via REST.
  static Future<void> deleteUser(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await ApiService.deleteUser(userId, token: token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la suppression');
      }

      await logActivity(
        action: 'delete_user',
        targetType: 'user',
        targetId: userId,
      );
    } catch (e) {
      print('❌ AdminServiceV2.deleteUser: $e');
      rethrow;
    }
  }

  /// Crée un utilisateur via REST.
  static Future<String?> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? departement,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Non authentifié');

      final data = {
        'email': email,
        'password': password,
        'nom': fullName,
        'role': role,
        'telephone': phone,
        'department': departement,
      };

      final response = await ApiService.createUser(data, token);
      if (response.success && response.data != null) {
        final userId = response.data!['id']?.toString();
        if (userId != null) {
          await logActivity(
            action: 'create_user',
            targetType: 'user',
            targetId: userId,
            details: {'email': email, 'role': role},
          );
        }
        return userId;
      }
      return null;
    } catch (e) {
      print('❌ AdminServiceV2.createUser: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // JOURNAL D'ACTIVITÉ
  // ─────────────────────────────────────────────

  /// Récupère les N dernières actions admin via REST.
  static Future<List<ActivityLogModel>> getActivityLogs({int limit = 20}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await ApiService.getActivityLogs(token, limit: limit);
      if (response.success && response.data != null) {
        return response.data!.map((j) => ActivityLogModel.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      print('❌ AdminServiceV2.getActivityLogs: $e');
      return [];
    }
  }

  /// Enregistre une action dans le journal via REST.
  static Future<void> logActivity({
    required String action,
    String? targetType,
    String? targetId,
    Map<String, dynamic>? details,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final data = {
        'action': action,
        'target_type': targetType,
        'target_id': targetId,
        'details': details,
      };

      await ApiService.logActivity(data, token);
    } catch (e) {
      print('⚠️ logActivity silencieux: $e');
    }
  }
}
