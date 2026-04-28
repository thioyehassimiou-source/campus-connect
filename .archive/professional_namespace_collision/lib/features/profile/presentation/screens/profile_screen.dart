import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.maybeWhen(
      data: (user) => user,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar et informations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user?.email?.substring(0, 2).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.userMetadata?['first_name'] ?? 'Utilisateur',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Rôle: ${user?.userMetadata?['role'] ?? 'Non défini'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Options du profil
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Informations personnelles'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Modifier les informations
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Sécurité'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Paramètres de sécurité
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Paramètres de notifications
                    },
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Bouton de déconnexion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
