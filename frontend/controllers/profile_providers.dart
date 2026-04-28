import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/core/services/profile_service.dart';
import 'package:campusconnect/controllers/auth_providers.dart';

/// Provider pour récupérer le profil de l'utilisateur actuel
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  return await ProfileService.getCurrentUserProfile();
});
