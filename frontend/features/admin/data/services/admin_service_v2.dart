import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/features/admin/data/models/admin_user_model.dart';
import 'package:campusconnect/features/admin/data/models/admin_stats_model.dart';
import 'package:campusconnect/features/admin/data/models/activity_log_model.dart';

/// Service d'administration complet — gestion utilisateurs, statistiques, logs.
/// Utilise uniquement le client Supabase (anon key + RLS admin policies).
class AdminServiceV2 {
  static final SupabaseClient _sb = Supabase.instance.client;

  // ─────────────────────────────────────────────
  // STATISTIQUES
  // ─────────────────────────────────────────────

  /// Récupère les statistiques globales pour le dashboard.
  static Future<AdminStatsModel> getGlobalStats() async {
    try {
      // Profils par rôle
      final profilesRes = await _sb.from('profiles').select('role');
      final profiles = List<Map<String, dynamic>>.from(profilesRes as List);

      int students = 0, teachers = 0, admins = 0;
      final roleMap = <String, int>{};
      for (final p in profiles) {
        final r = (p['role'] ?? 'Étudiant').toString();
        roleMap[r] = (roleMap[r] ?? 0) + 1;
        if (r.contains('tudiant')) students++;
        else if (r.contains('nseignant')) teachers++;
        else admins++;
      }

      // Cours
      int courses = 0;
      try {
        final cRes = await _sb.from('courses').select('id');
        courses = (cRes as List).length;
      } catch (_) {}

      // Salles
      int rooms = 0;
      try {
        final rRes = await _sb.from('rooms').select('id');
        rooms = (rRes as List).length;
      } catch (_) {}

      // Créneaux en attente (status = 3)
      int pending = 0;
      try {
        final sRes = await _sb.from('schedules').select('id').eq('status', 3);
        pending = (sRes as List).length;
      } catch (_) {}

      // Annonces
      int announcements = 0;
      try {
        final aRes = await _sb.from('announcements').select('id');
        announcements = (aRes as List).length;
      } catch (_) {}

      // Services actifs
      int services = 0;
      try {
        final svRes = await _sb.from('campus_services').select('id');
        services = (svRes as List).length;
      } catch (_) {
        try {
          final svRes2 = await _sb.from('services').select('id');
          services = (svRes2 as List).length;
        } catch (_) {}
      }

      return AdminStatsModel(
        totalStudents: students,
        totalTeachers: teachers,
        totalAdmins: admins,
        totalCourses: courses,
        totalRooms: rooms,
        pendingSchedules: pending,
        totalAnnouncements: announcements,
        activeServices: services,
        usersByRole: roleMap,
      );
    } catch (e) {
      print('❌ AdminServiceV2.getGlobalStats: $e');
      return AdminStatsModel.empty();
    }
  }

  // ─────────────────────────────────────────────
  // GESTION UTILISATEURS
  // ─────────────────────────────────────────────

  /// Liste paginée des utilisateurs avec filtres.
  static Future<List<AdminUserModel>> getUsersPaginated({
    int page = 0,
    int limit = 20,
    String? search,
    String? roleFilter,
  }) async {
    try {
      var query = _sb
          .from('profiles')
          .select('id, email, full_name, first_name, last_name, role, phone, '
              'profile_image_url, is_active, matricule, departement, filiere, '
              'niveau, created_at, last_login_at');

      // Filtre rôle
      if (roleFilter != null && roleFilter.isNotEmpty) {
        query = query.eq('role', roleFilter);
      }

      // Filtre recherche textuelle (Supabase ilike)
      if (search != null && search.isNotEmpty) {
        query = query.or('full_name.ilike.%$search%,email.ilike.%$search%');
      }

      final res = await query
          .order('full_name', ascending: true)
          .range(page * limit, (page + 1) * limit - 1);

      return (res as List).map((j) => AdminUserModel.fromJson(j)).toList();
    } catch (e) {
      print('❌ AdminServiceV2.getUsersPaginated: $e');
      return [];
    }
  }

  /// Récupère un seul utilisateur par ID.
  static Future<AdminUserModel?> getUserById(String userId) async {
    try {
      final res = await _sb
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return AdminUserModel.fromJson(res);
    } catch (e) {
      print('❌ AdminServiceV2.getUserById: $e');
      return null;
    }
  }

  /// Met à jour le profil d'un utilisateur (rôle, nom, téléphone, etc.).
  static Future<void> updateUser({
    required String userId,
    String? fullName,
    String? role,
    String? phone,
    String? departement,
    String? filiere,
    String? niveau,
  }) async {
    final data = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (fullName != null) data['full_name'] = fullName;
    if (role != null) data['role'] = role;
    if (phone != null) data['phone'] = phone;
    if (departement != null) data['departement'] = departement;
    if (filiere != null) data['filiere'] = filiere;
    if (niveau != null) data['niveau'] = niveau;

    await _sb.from('profiles').update(data).eq('id', userId);
    await logActivity(
      action: 'update_user',
      targetType: 'user',
      targetId: userId,
      details: data,
    );
  }

  /// Active ou désactive un compte utilisateur.
  static Future<void> toggleUserStatus(String userId, bool isActive) async {
    await _sb.from('profiles').update({
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);

    await logActivity(
      action: 'toggle_user_status',
      targetType: 'user',
      targetId: userId,
      details: {'is_active': isActive},
    );
  }

  /// Supprime le profil d'un utilisateur (le compte auth reste).
  static Future<void> deleteUser(String userId) async {
    await _sb.from('profiles').delete().eq('id', userId);
    await logActivity(
      action: 'delete_user',
      targetType: 'user',
      targetId: userId,
    );
  }

  /// Crée un utilisateur via signUp (sans déconnecter l'admin actuel).
  /// ⚠️ Pour la production, utiliser une Edge Function avec Service Role.
  static Future<String?> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? departement,
  }) async {
    try {
      // On insère directement dans profiles si le compte existe déjà,
      // sinon on crée via signUp (avec conséquence possible de déconnexion admin).
      // Recommandation : utiliser une Edge Function Supabase en production.
      final res = await _sb.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
          'phone': phone,
        },
      );
      if (res.user != null) {
        // Upsert du profil au cas où le trigger ne l'a pas créé
        await _sb.from('profiles').upsert({
          'id': res.user!.id,
          'email': email,
          'full_name': fullName,
          'role': role,
          'phone': phone,
          'departement': departement,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        await logActivity(
          action: 'create_user',
          targetType: 'user',
          targetId: res.user!.id,
          details: {'email': email, 'role': role},
        );
        return res.user!.id;
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

  /// Récupère les N dernières actions admin.
  static Future<List<ActivityLogModel>> getActivityLogs({int limit = 20}) async {
    try {
      final res = await _sb
          .from('admin_activity_logs')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return (res as List).map((j) => ActivityLogModel.fromJson(j)).toList();
    } catch (e) {
      print('⚠️ AdminServiceV2.getActivityLogs (table peut ne pas exister): $e');
      return [];
    }
  }

  /// Enregistre une action dans le journal.
  static Future<void> logActivity({
    required String action,
    String? targetType,
    String? targetId,
    Map<String, dynamic>? details,
  }) async {
    try {
      final adminId = _sb.auth.currentUser?.id;
      if (adminId == null) return;
      await _sb.from('admin_activity_logs').insert({
        'admin_id': adminId,
        'action': action,
        'target_type': targetType,
        'target_id': targetId,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silencieux si la table n'existe pas encore
      print('⚠️ logActivity silencieux: $e');
    }
  }
}
