import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  bool _isLoading = false;
  String? _message;

  Future<void> _createProfile() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _message = 'Aucun utilisateur connecté';
          _isLoading = false;
        });
        return;
      }

      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'nom': 'Hassimiou Thioye',
        'email': user.email,
        'role': 'Étudiant',
        'telephone': '+221 77 123 45 67',
        'niveau': 'Master 1',
        'filiere_id': 'Informatique',
      });

      setState(() {
        _message = 'Profil créé avec succès!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _createProfile,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Créer mon profil'),
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_message!),
              ),
          ],
        ),
      ),
    );
  }
}