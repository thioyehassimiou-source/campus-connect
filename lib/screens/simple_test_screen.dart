import 'package:flutter/material.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/core/services/supabase_auth_service.dart';

class SimpleTestScreen extends StatefulWidget {
  const SimpleTestScreen({super.key});

  @override
  State<SimpleTestScreen> createState() => _SimpleTestScreenState();
}

class _SimpleTestScreenState extends State<SimpleTestScreen> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testLogin() async {
    setState(() => _isLoading = true);

    try {
      await SupabaseAuthService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion Supabase réussie!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testRegister() async {
    setState(() => _isLoading = true);

    try {
      await SupabaseAuthService.registerWithEmailAndPassword(
        email: 'newuser@example.com',
        password: 'password123',
        firstName: 'Test',
        lastName: 'User',
        role: 'etudiant',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription Supabase réussie!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusConnect - Test Auth'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo et titre
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/logo/app_logo.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'CampusConnect',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            
            Text(
              'Université de Labé',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 40),
            
            Text(
              'Test d\'authentification Supabase',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Champ email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Champ mot de passe
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Bouton de connexion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Tester Connexion',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bouton d'inscription
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _testRegister,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Tester Inscription',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Informations
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Configuration Supabase requise:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configurez vos clés Supabase dans:\nlib/core/config/supabase_config.dart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
