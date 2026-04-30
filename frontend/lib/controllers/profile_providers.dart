import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/core/services/profile_service.dart';
import 'package:campusconnect/controllers/auth_providers.dart';

/// Provider pour récupérer le profil complet de l'utilisateur actuel via l'API REST
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return null;
  
  return await ProfileService.getCurrentUserProfile();
});
