import 'package:campusconnect/services/api_service.dart';
import 'package:campusconnect/services/auth_service.dart';
import 'package:campusconnect/models/schedule_model.dart';

export 'package:campusconnect/models/schedule_model.dart';

class ScheduleService {
  /// Récupérer l'emploi du temps (Pour Étudiants et Enseignants)
  /// Le filtrage est fait côté Backend selon le rôle de l'utilisateur
  static Future<List<ScheduleItem>> getValidatedSchedule() async {
    try {
      final token = await AuthService.getToken();
      final response = await ApiService.getSchedules(token: token);
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('❌ Erreur récupération emploi du temps REST: $e');
      return [];
    }
  }

  /// Alias pour compatibilité avec l'ancien code enseignant
  static Future<List<ScheduleItem>> getTeacherProposals() async {
    return getValidatedSchedule();
  }

  /// Récupérer tous les créneaux (Pour Admin)
  static Future<List<ScheduleItem>> getPendingSchedules() async {
    // Dans le nouveau backend, getSchedules renvoie tout ce qui est pertinent pour l'user
    return getValidatedSchedule();
  }

  /// Ajouter un cours (Proposer ou Direct)
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
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final data = {
        'subject': subject,
        'teacher': teacher,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'room': room,
        'day': day,
        'niveau': niveau,
        'type': type,
        'scope': scope,
        'department_id': departmentId,
        'faculty_id': facultyId,
      };

      final response = await ApiService.createSchedule(data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de l\'ajout du cours');
      }
    } catch (e) {
      print('❌ Erreur ajout cours REST: $e');
      rethrow;
    }
  }

  /// Valider un cours (Pour Admin)
  static Future<void> validateSchedule(String id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final response = await ApiService.updateSchedule(id, {'status': 'validated'}, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de la validation');
      }
    } catch (e) {
      print('❌ Erreur validation cours REST: $e');
      rethrow;
    }
  }

  /// Rejeter un cours (Pour Admin)
  static Future<void> rejectSchedule(String id, [String? reason]) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final data = {'status': 'rejected'};
      if (reason != null && reason.isNotEmpty) {
        data['reason'] = reason;
      }

      final response = await ApiService.updateSchedule(id, data, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors du rejet');
      }
    } catch (e) {
      print('❌ Erreur rejet cours REST: $e');
      rethrow;
    }
  }

  /// Annuler un cours (Pour Enseignant/Admin)
  static Future<void> cancelSchedule(String id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final response = await ApiService.deleteSchedule(id, token);
      if (!response.success) {
        throw Exception(response.error?.message ?? 'Erreur lors de l\'annulation');
      }
    } catch (e) {
      print('❌ Erreur annulation cours REST: $e');
      rethrow;
    }
  }
}
