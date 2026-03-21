import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/features/admin/data/models/activity_log_model.dart';
import 'package:campusconnect/features/admin/data/services/admin_service_v2.dart';

/// Provider du journal d'activité des administrateurs.
final adminActivityLogsProvider = FutureProvider<List<ActivityLogModel>>((ref) async {
  return AdminServiceV2.getActivityLogs(limit: 20);
});
