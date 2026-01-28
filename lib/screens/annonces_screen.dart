import 'package:flutter/material.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/shared/models/user.dart';

class AnnoncesScreen extends StatefulWidget {
  final User user;

  const AnnoncesScreen({super.key, required this.user});

  @override
  State<AnnoncesScreen> createState() => _AnnoncesScreenState();
}

class _AnnoncesScreenState extends State<AnnoncesScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annonces'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: widget.user.role == UserRole.enseignant || widget.user.role == UserRole.administrateur
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _createAnnonce,
                ),
              ]
            : null,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.announcement,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Annonces en cours de chargement...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAnnonce() async {
    // TODO: Implement annonce creation with Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité bientôt disponible'),
      ),
    );
  }
}
