import 'package:flutter/material.dart';
import 'package:campusconnect/screens/modern_login_screen.dart';
import 'package:campusconnect/core/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModernProfileScreen extends StatefulWidget {
  const ModernProfileScreen({super.key});

  @override
  State<ModernProfileScreen> createState() => _ModernProfileScreenState();
}

class _ModernProfileScreenState extends State<ModernProfileScreen> {
  Map<String, dynamic>? userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final data = await ProfileService.getCurrentUserProfile();
    
    if (mounted) {
      setState(() {
        if (data != null) {
          userData = {
            ...data,
            'nom': data['nom'] ?? data['full_name'] ?? 'Utilisateur',
            'email': data['email'] ?? 'utilisateur@campus.fr',
            'telephone': data['telephone'] ?? data['phone'] ?? 'Non renseigné',
            'role': data['role'] ?? 'Étudiant',
            'niveau': data['niveau'] ?? data['level'] ?? 'Non renseigné',
            'filiere_id': data['filiere_id'] ?? data['program'] ?? 'Non renseignée',
            'faculty_name': data['faculties'] != null ? (data['faculties']['nom'] ?? data['faculties']['name']) : 'Non renseignée',
            'department_name': data['departments'] != null ? (data['departments']['nom'] ?? data['departments']['name']) : null,
            'service_name': data['services'] != null ? (data['services']['nom'] ?? data['services']['name']) : null,
          };
        } else {
          _error = "Impossible de charger le profil. Vérifiez votre connexion.";
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchProfile,
                        child: Text("Réessayer"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête profil
                      _buildProfileHeader(),
                      
                      const SizedBox(height: 32),
                      
                      // Informations personnelles
                      _buildPersonalInfo(),
                      
                      const SizedBox(height: 32),
                      
                      // Informations académiques
                      _buildAcademicInfo(),
                      
                      const SizedBox(height: 32),
                      
                      // Actions
                      _buildActions(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Photo de profil
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              
              // Informations principales
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData?['nom'] ?? 'Utilisateur',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getRoleColor(userData?['role'] ?? '').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            userData?['role'] ?? 'Étudiant',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _getRoleColor(userData?['role'] ?? ''),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${userData?['niveau'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Dernière connexion
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 8),
              Text(
                'ID : ${userData?['id']?.substring(0, 8) ?? '...'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations personnelles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow(
                Icons.email_outlined,
                'Email',
                userData?['email'] ?? 'Non renseigné',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.phone_outlined,
                'Téléphone',
                userData?['telephone'] ?? 'Non renseigné',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations académiques',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow(
                Icons.badge_outlined,
                'ID',
                userData?['id']?.substring(0, 8) ?? 'Non renseigné',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.location_city_outlined,
                'Faculté',
                userData?['faculty_name'] ?? 'Non renseignée',
              ),
              if (userData?['role'] != 'Administratif' && userData?['department_name'] != null) ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.account_tree_outlined,
                  'Département',
                  userData?['department_name'],
                ),
              ],
              if (userData?['role'] == 'Administratif' && userData?['service_name'] != null) ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.business_center_outlined,
                  'Service',
                  userData?['service_name'],
                ),
              ],
              if (userData?['role'] == 'Étudiant') ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.school_outlined,
                  'Filière',
                  userData?['filiere_id'] ?? 'Non renseignée',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.trending_up_outlined,
                  'Niveau',
                  userData?['niveau'] ?? 'Non renseigné',
                ),
              ],
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.person_outline_sharp,
                'Rôle',
                userData?['role'] ?? 'Non renseigné',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).iconTheme.color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        
        // Bouton modifier profil
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              _showEditProfileDialog();
            },
            icon: Icon(Icons.edit_outlined, size: 20),
            label: Text(
                'Modifier le profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Bouton déconnexion
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {
              _showLogoutDialog();
            },
            icon: Icon(Icons.logout_outlined, size: 20),
            label: Text(
              'Se déconnecter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Étudiant':
        return const Color(0xFF2563EB);
      case 'Enseignant':
        return const Color(0xFF10B981);
      case 'Administrateur':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);
    
    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} heures';
    } else {
      return 'Il y a ${difference.inDays} jours';
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userData?['nom'] ?? '');
    final phoneController = TextEditingController(text: userData?['telephone'] == 'Non renseigné' ? '' : userData?['telephone']);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Modifier le profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
              ),
              if (isSaving) ...[
                 const SizedBox(height: 16),
                 const LinearProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                setStateDialog(() => isSaving = true);
                try {
                  final userId = Supabase.instance.client.auth.currentUser?.id;
                  if (userId != null) {
                    await Supabase.instance.client.from('profiles').update({
                      if (nameController.text.isNotEmpty) 'full_name': nameController.text,
                      if (phoneController.text.isNotEmpty) 'phone': phoneController.text,
                    }).eq('id', userId);
                    
                    if (mounted) {
                      Navigator.of(context).pop();
                      _fetchProfile(); // Refresh profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil mis à jour avec succès')),
                      );
                    }
                  }
                } catch (e) {
                  setStateDialog(() => isSaving = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e')),
                    );
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Se déconnecter'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const ModernLoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Paramètres'),
          content: Text('Fonctionnalité des paramètres en cours de développement.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
