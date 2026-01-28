import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/schedule/domain/models/emploi_du_temps_item.dart';

class ScheduleService {
  final SupabaseClient _client;

  ScheduleService(this._client);

  Future<List<String>> fetchFilieres() async {
    final rows = await _client
        .from('emplois_temps')
        .select('filiere')
        .order('filiere');

    final set = <String>{};
    for (final row in (rows as List)) {
      final value = (row as Map)['filiere']?.toString().trim();
      if (value != null && value.isNotEmpty) {
        set.add(value);
      }
    }

    final list = set.toList()..sort();
    return list;
  }

  Future<List<EmploiDuTempsItem>> fetchScheduleForFiliere({
    required String filiere,
  }) async {
    final rows = await _client
        .from('emplois_temps')
        .select('*')
        .eq('filiere', filiere)
        .order('date', ascending: true)
        .order('heure_debut', ascending: true);

    return (rows as List)
        .map((e) => EmploiDuTempsItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EmploiDuTempsItem>> fetchScheduleForTeacher({
    required String teacherName,
  }) async {
    final rows = await _client
        .from('emplois_temps')
        .select('*')
        .eq('enseignant', teacherName)
        .order('date', ascending: true)
        .order('heure_debut', ascending: true);

    return (rows as List)
        .map((e) => EmploiDuTempsItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
