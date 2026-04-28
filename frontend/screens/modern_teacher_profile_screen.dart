import 'package:flutter/material.dart';
import 'package:campusconnect/core/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModernTeacherProfileScreen extends StatefulWidget {
  const ModernTeacherProfileScreen({super.key});

  @override
  State<ModernTeacherProfileScreen> createState() => _ModernTeacherProfileScreenState();
}

class _ModernTeacherProfileScreenState extends State<ModernTeacherProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _officeController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  
  Map<String, dynamic>? _userData;
  
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _officeController.dispose();
    _bioController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _loadTeacherData() async {
    setState(() {
      _isLoading = true;
    });

    final data = await ProfileService.getCurrentUserProfile();

    if (mounted) {
      setState(() {
        if (data != null) {
          _userData = data;
          final fullName = data['nom'] ?? data['full_name'] ?? 'Enseignant';
          final nameParts = fullName.split(' ');
          _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : 'Prénom';
          _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Nom';
          
          _emailController.text = data['email'] ?? 'email@campus.fr';
          _phoneController.text = data['telephone'] ?? data['phone'] ?? 'Non renseigné';
          _officeController.text = data['office'] ?? 'Non renseigné';
          _bioController.text = data['bio'] ?? 'Enseignant sur CampusConnect';
          _specializationController.text = data['specialization'] ?? 'Non renseignée';
        }
        _isLoading = false;
      });
    }
  }

  List<String> _getSkills() {
    if (_userData?['competences'] != null) {
      return List<String>.from(_userData!['competences']);
    }
    return [
      'Analyse Numérique', 'Statistiques', 'Machine Learning', 'Python',
      'MATLAB', 'Recherche Opérationnelle', 'Optimisation', 'Data Science'
    ]; // Default / Fallback
  }

  Map<String, String> _getOfficeHours() {
    if (_userData?['office_hours'] != null && _userData?['office_hours'] is Map) {
      return Map<String, String>.from(_userData!['office_hours']);
    }
    return {
      'Lundi': '08:00 - 18:00',
      'Mardi': '08:00 - 18:00',
      'Mercredi': '08:00 - 16:00',
      'Jeudi': '08:00 - 18:00',
      'Vendredi': '08:00 - 16:00',
    }; // Default / Fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mon Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Carte principale du profil
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF10B981), const Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
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
                        child: Icon(
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
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Nom et titre
                  if (!_isEditing) ...[
                    Text(
                      '${_firstNameController.text} ${_lastNameController.text}',
                      style: TextStyle(
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
                        _specializationController.text.isNotEmpty 
                            ? _specializationController.text 
                            : 'Professeur',
                        style: TextStyle(
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
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Prénom',
                              labelStyle: TextStyle(color: Colors.white70),
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
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Nom',
                              labelStyle: TextStyle(color: Colors.white70),
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
                      _buildProfileStat('120', 'Étudiants', Icons.people),
                      _buildProfileStat('4.8', 'Évaluation', Icons.star),
                      _buildProfileStat('8', 'Cours', Icons.book),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Informations professionnelles
            _buildSectionCard(
              'Informations Professionnelles',
              Icons.work,
              [
                _buildEditableInfoRow('Email', _emailController, Icons.email),
                _buildEditableInfoRow('Téléphone', _phoneController, Icons.phone),
                _buildInfoRowStatic('Faculté', _userData?['faculties']?['nom'] ?? _userData?['faculties']?['name'] ?? 'Non renseignée', Icons.location_city),
                _buildInfoRowStatic('Département', _userData?['departments']?['nom'] ?? _userData?['departments']?['name'] ?? 'Non renseigné', Icons.account_tree),
                _buildEditableInfoRow('Bureau', _officeController, Icons.location_on),
                _buildEditableInfoRow('Spécialisation', _specializationController, Icons.psychology),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Parlez-nous de votre parcours...',
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
                  children: _getSkills().map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
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
            
            // Cours enseignés
            _buildSectionCard(
              'Cours Enseignés',
              Icons.school,
              [
                if (_userData?['courses'] != null && (_userData!['courses'] as List).isNotEmpty)
                  ...(_userData!['courses'] as List).map((course) => 
                    _buildCourseItem(
                      course['code'] ?? 'CODE', 
                      course['name'] ?? 'Nom du cours', 
                      course['level'] ?? 'N/A', 
                      course['students'] ?? 0
                    )
                  ).toList()
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Aucun cours assigné pour le moment.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Publications
            _buildSectionCard(
              'Publications',
              Icons.menu_book,
              [
                if (_userData?['publications'] != null && (_userData!['publications'] as List).isNotEmpty)
                  ...(_userData!['publications'] as List).map((pub) => 
                    _buildPublicationItem(
                      pub['year'] ?? '-', 
                      pub['title'] ?? 'Sans titre', 
                      pub['journal'] ?? 'Inconnu'
                    )
                  ).toList()
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Aucune publication renseignée.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Disponibilité
            _buildSectionCard(
              'Disponibilité',
              Icons.schedule,
              [
                if (_getOfficeHours().isNotEmpty)
                  ..._getOfficeHours().entries.map((entry) => 
                    _buildAvailabilityRow(entry.key, entry.value)
                  ).toList()
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Horaires non renseignés.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Réseaux sociaux
            _buildSectionCard(
              'Réseaux Sociaux',
              Icons.share,
              [
                _buildSocialRow('Google Scholar', 'scholar.google.com/citations?user=abc123', Icons.school),
                _buildSocialRow('LinkedIn', 'linkedin.com/in/jean-bernard', Icons.link),
                _buildSocialRow('ResearchGate', 'researchgate.net/profile/jean-bernard', Icons.science),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Paramètres
            _buildSectionCard(
              'Paramètres',
              Icons.settings,
              [
                _buildSettingRow('Notifications', 'Actives', Icons.notifications),
                _buildSettingRow('Agenda partagé', 'Public', Icons.calendar_today),
                _buildSettingRow('Langue', 'Français', Icons.language),
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
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Exporter le profil',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showTeacherDashboard,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Tableau de bord',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
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
                  child: Text(
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
          style: TextStyle(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF10B981), size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
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

  Widget _buildCourseItem(String code, String name, String level, int students) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              code,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF10B981),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  level,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$students étudiants',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicationItem(String year, String title, String journal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  year,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            journal,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              hours,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color,
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
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

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ProfileService.updateProfile({
        'nom': '${_firstNameController.text} ${_lastNameController.text}',
        'email': _emailController.text,
        'telephone': _phoneController.text,
        'office': _officeController.text,
        'bio': _bioController.text,
        'specialization': _specializationController.text,
      });

      if (success) {
        if (mounted) {
          setState(() {
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } else {
        throw Exception('Échec de la mise à jour');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _exportProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Exporter le profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
                title: Text('CV académique'),
                subtitle: Text('Générer un CV académique complet'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Génération du CV...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Color(0xFF10B981)),
                title: Text('Partager le profil'),
                subtitle: Text('Lien de partage du profil enseignant'),
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
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _showTeacherDashboard() {
    Navigator.pushNamed(context, '/teacher-dashboard');
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Se déconnecter'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              child: Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRowStatic(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
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
}
