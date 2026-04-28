import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class RoleRedirectScreen extends ConsumerWidget {
  const RoleRedirectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: state.isLoading
            ? const CircularProgressIndicator()
            : const CircularProgressIndicator(),
      ),
    );
  }
}
