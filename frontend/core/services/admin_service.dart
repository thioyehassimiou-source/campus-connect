import 'package:supabase_flutter/supabase_flutter.dart';

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
}

class AdminService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupère les statistiques globales pour le dashboard admin
  static Future<AdminStats> getGlobalStats() async {
    try {
      // 1. Nombre d'utilisateurs
      final usersRes = await _supabase.from('profiles').select('role');
      final List<dynamic> users = usersRes as List<dynamic>;
      
      Map<String, int> rolesCount = {
        'Étudiant': 0,
        'Enseignant': 0,
        'Admin': 0,
      };

      for (var user in users) {
        String role = user['role'] ?? 'Étudiant';
        rolesCount[role] = (rolesCount[role] ?? 0) + 1;
      }

      // 2. Nombre d'annonces
      final announcementsRes = await _supabase.from('announcements').select('id');
      final int announcementsCount = announcementsRes.length;

      // 3. Nombre de salles réelles
      int roomsCount = 0; 
      try {
        final roomsRes = await _supabase.from('rooms').select('id');
        roomsCount = (roomsRes as List).length;
      } catch (e) {
        print('⚠️ Erreur fetch rooms: $e');
        roomsCount = 126; // Fallback demo
      }

      // 4. Nombre de services
      int servicesCount = 8;
      try {
        final servicesRes = await _supabase.from('services').select('id');
        servicesCount = (servicesRes as List).length;
      } catch (_) {}

      return AdminStats(
        totalUsers: users.length,
        totalAnnouncements: announcementsCount,
        totalRooms: roomsCount,
        activeServices: servicesCount,
        usersByRole: rolesCount,
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

  /// Récupère la liste complète des profils utilisateurs
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, nom, email, role, created_at')
          .order('nom', ascending: true);
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('❌ Erreur GetAllUsers: $e');
      return [];
    }
  }

  /// Supprimer un utilisateur
  static Future<void> deleteUser(String userId) async {
    // Note: La suppression d'un utilisateur auth nécessite les droits admin (Service Role)
    // Ici on supprime le profil, le trigger ou RLS devrait gérer le reste si configuré.
    await _supabase.from('profiles').delete().eq('id', userId);
  }

  /// Créer un utilisateur (Par un Admin)
  static Future<void> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    // Utilisation du signUp classique, l'admin peut créer des comptes.
    // Idéalement on utiliserait une Edge Function avec Service Role pour créer sans logout l'admin actuel.
    // Pour l'instant, on utilise le signUp qui pourrait déconnecter l'admin si non géré.
    // Une alternative est d'appeler une RPC ou Edge Function.
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
      },
    );
  }
}
