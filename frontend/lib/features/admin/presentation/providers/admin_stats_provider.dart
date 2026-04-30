import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/features/admin/data/models/admin_stats_model.dart';
import 'package:campusconnect/features/admin/data/services/admin_service_v2.dart';

/// Provider des statistiques globales du dashboard admin.
/// Se recharge automatiquement via [ref.refresh(adminStatsProvider)].
final adminStatsProvider = FutureProvider<AdminStatsModel>((ref) async {
  return AdminServiceV2.getGlobalStats();
});
