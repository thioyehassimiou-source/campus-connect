import 'package:flutter/material.dart';
import 'package:campusconnect/core/services/profile_service.dart';
import 'package:campusconnect/core/services/supabase_auth_service.dart';

class ModernStudentProfileScreen extends StatefulWidget {
  const ModernStudentProfileScreen({super.key});

  @override
  State<ModernStudentProfileScreen> createState() => _ModernStudentProfileScreenState();
}

class _ModernStudentProfileScreenState extends State<ModernStudentProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _loadStudentData() async {
    setState(() {
      _isLoading = true;
    });

    final data = await ProfileService.getCurrentUserProfile();

    if (mounted) {
      setState(() {
        if (data != null) {
          // Gestion robuste des noms
          final fullName = data['nom'] ?? data['full_name'] ?? 'Utilisateur';
          final nameParts = fullName.split(' ');
          _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : 'Prénom';
          _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Nom';
          
          // Gestion des autres champs avec valeurs par défaut
          _emailController.text = data['email'] ?? 'email@campus.fr';
          _phoneController.text = data['telephone'] ?? data['phone'] ?? 'Non renseigné';
          _addressController.text = data['address'] ?? 'Non renseignée';
          _bioController.text = data['bio'] ?? 'Étudiant sur CampusConnect';
          
          // Stocker toutes les données
          _studentData = {
            ...data,
            'role': data['role'] ?? 'Étudiant',
            'niveau': data['niveau'] ?? data['level'] ?? 'Non renseigné',
            'filiere_id': data['filiere_id'] ?? data['program'] ?? 'Non renseignée',
            'faculty_name': data['faculties'] != null ? (data['faculties']['nom'] ?? data['faculties']['name']) : 'Non renseignée',
            'department_name': data['departments'] != null ? (data['departments']['nom'] ?? data['departments']['name']) : null,
            'service_name': data['services'] != null ? (data['services']['nom'] ?? data['services']['name']) : null,
          };
        } else {
          // Données par défaut si aucune donnée n'est récupérée
          _firstNameController.text = 'Utilisateur';
          _lastNameController.text = 'CampusConnect';
          _emailController.text = 'utilisateur@campus.fr';
          _phoneController.text = 'Non renseigné';
          _addressController.text = 'Non renseignée';
          _bioController.text = 'Étudiant sur CampusConnect';
          
          _studentData = {
            'id': 'user_id',
            'role': 'Étudiant',
            'niveau': 'Non renseigné',
            'filiere_id': 'Non renseignée',
            'email': 'utilisateur@campus.fr',
            'telephone': 'Non renseigné',
          };
        }
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _studentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: _isEditing ? const Color(0xFF10B981) : const Color(0xFF2563EB),
            ),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Carte principale du profil
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Photo de profil
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Nom et prénom
                  if (!_isEditing) ...[
                    Text(
                      '${_firstNameController.text} ${_lastNameController.text}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_studentData?['role'] ?? 'Étudiant'} • ${_studentData?['niveau'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firstNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Prénom',
                              labelStyle: const TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white54),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _lastNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Nom',
                              labelStyle: const TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white54),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // Statistiques rapides
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat('15.2', 'Moyenne', Icons.grade),
                      _buildProfileStat('45', 'Crédits', Icons.workspace_premium),
                      _buildProfileStat('12/120', 'Classement', Icons.leaderboard),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Informations académiques
            _buildSectionCard(
              'Informations Académiques',
              Icons.school,
              [
                _buildInfoRow('ID', _getShortId(_studentData?['id'])),
                _buildInfoRow('Faculté', _studentData?['faculty_name'] ?? 'Non renseignée'),
                if (_studentData?['role'] != 'Administratif' && _studentData?['department_name'] != null)
                  _buildInfoRow('Département', _studentData?['department_name']),
                if (_studentData?['role'] == 'Administratif' && _studentData?['service_name'] != null)
                  _buildInfoRow('Service', _studentData?['service_name']),
                if (_studentData?['role'] == 'Étudiant') ...[
                  _buildInfoRow('Programme', _studentData?['filiere_id'] ?? 'Non renseigné'),
                  _buildInfoRow('Niveau', _studentData?['niveau'] ?? 'Non renseigné'),
                ],
                _buildInfoRow('Date d\'inscription', _formatDate(_studentData?['created_at']) ?? '2024'),
                _buildInfoRow('Statut', _studentData?['status'] ?? 'Régulier'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Informations personnelles
            _buildSectionCard(
              'Informations Personnelles',
              Icons.person,
              [
                _buildEditableInfoRow('Email', _emailController, Icons.email),
                _buildEditableInfoRow('Téléphone', _phoneController, Icons.phone),
                _buildEditableInfoRow('Adresse', _addressController, Icons.location_on),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Biographie
            _buildSectionCard(
              'Biographie',
              Icons.description,
              [
                if (!_isEditing)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _bioController.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Parlez-nous de vous...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Compétences
            _buildSectionCard(
              'Compétences',
              Icons.psychology,
              [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Python', 'JavaScript', 'React', 'Node.js', 'SQL', 'Git',
                    'Machine Learning', 'Data Analysis'
                  ].map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Centres d'intérêt
            _buildSectionCard(
              'Centres d\'Intérêt',
              Icons.favorite,
              [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'IA', 'Web Development', 'Photographie', 'Musique', 'Voyages'
                  ].map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: Text(
                        interest,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Réseaux sociaux
            _buildSectionCard(
              'Réseaux Sociaux',
              Icons.share,
              [
                _buildSocialRow('LinkedIn', 'linkedin.com/in/alice-martin', Icons.link),
                _buildSocialRow('GitHub', 'github.com/alice-martin', Icons.code),
                _buildSocialRow('Twitter', '@alice_martin', Icons.alternate_email),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Paramètres
            _buildSectionCard(
              'Paramètres',
              Icons.settings,
              [
                _buildSettingRow('Notifications', 'Actives', Icons.notifications),
                _buildSettingRow('Langue', 'Français', Icons.language),
                _buildSettingRow('Fuseau horaire', 'GMT+1 (Paris)', Icons.access_time),
                _buildSettingRow('Confidentialité', 'Gérer', Icons.lock),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            if (!_isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _exportProfile,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Exporter le profil',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/create-profile'),
                child: const Text('Créer Profil'),
              ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showPrivacySettings,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF64748B)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confidentialité',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Se déconnecter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2563EB), size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoRow(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Icon(icon, size: 16, color: const Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.text,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRow(String platform, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 16),
          const SizedBox(width: 12),
          Text(
            platform,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF9CA3AF),
            size: 16,
          ),
        ],
      ),
    );
  }

  void _toggleEditMode() {
    if (_isEditing) {
      _saveProfile();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _saveProfile() {
    setState(() {
      _isLoading = true;
    });

    // Simulation de sauvegarde
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    });
  }

  void _exportProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exporter le profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
                title: const Text('CV au format PDF'),
                subtitle: const Text('Générer un CV professionnel'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Génération du CV...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFF2563EB)),
                title: const Text('Partager le profil'),
                subtitle: const Text('Lien de partage du profil'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lien copié!')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Paramètres de confidentialité'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Profil public'),
                subtitle: const Text('Rendre votre profil visible par tous'),
                value: false,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Partager les informations académiques'),
                subtitle: const Text('Autoriser le partage des notes et diplômes'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Recherches'),
                subtitle: const Text('Permettre aux autres de vous trouver'),
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  String _getShortId(dynamic id) {
    if (id == null) return 'ET2024001';
    final idStr = id.toString();
    return idStr.length > 8 ? idStr.substring(0, 8) : idStr;
  }

  String? _formatDate(dynamic dateValue) {
    if (dateValue == null) return null;
    
    try {
      if (dateValue is String) {
        final date = DateTime.parse(dateValue);
        return '${date.day}/${date.month}/${date.year}';
      }
      return dateValue.toString();
    } catch (e) {
      return dateValue.toString();
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Se déconnecter'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }
}
