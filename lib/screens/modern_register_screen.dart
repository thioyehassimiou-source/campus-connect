import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/screens/modern_login_screen.dart';

class ModernRegisterScreen extends StatefulWidget {
  const ModernRegisterScreen({super.key});

  @override
  State<ModernRegisterScreen> createState() => _ModernRegisterScreenState();
}

class _ModernRegisterScreenState extends State<ModernRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'Étudiant';
  String _selectedLevel = 'Licence 1';
  final List<String> _levelOptions = ['Licence 1', 'Licence 2', 'Licence 3'];
  int? _selectedFacultyId;
  int? _selectedDepartmentId;
  int? _selectedServiceId;
  List<Map<String, dynamic>> _faculties = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFaculties();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadFaculties() async {
    try {
      final response = await Supabase.instance.client.from('faculties').select();
      setState(() {
        _faculties = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Erreur chargement facultés: $e');
    }
  }

  Future<void> _loadDepartments(int facultyId) async {
    try {
      final response = await Supabase.instance.client
          .from('departments')
          .select()
          .eq('faculty_id', facultyId);
      setState(() {
        _departments = List<Map<String, dynamic>>.from(response);
        _selectedDepartmentId = null;
      });
    } catch (e) {
      print('Erreur chargement départements: $e');
    }
  }

  Future<void> _loadServices(int facultyId) async {
    try {
      // D'abord essayer avec faculty_id
      try {
        final response = await Supabase.instance.client
            .from('services')
            .select()
            .eq('faculty_id', facultyId);
        setState(() {
          _services = List<Map<String, dynamic>>.from(response);
          _selectedServiceId = null;
        });
        return;
      } catch (e) {
        // Si faculty_id n'existe pas, charger tous les services
        final response = await Supabase.instance.client
            .from('services')
            .select();
        setState(() {
          _services = List<Map<String, dynamic>>.from(response);
          _selectedServiceId = null;
        });
      }
    } catch (e) {
      print('Erreur chargement services: $e');
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        emailRedirectTo: null,
        data: {
          'nom': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
          'role': _selectedRole,
          'telephone': '',
          'niveau': _selectedRole == 'Étudiant' ? _selectedLevel : 'Non renseigné',
          'filiere_id': 'Non renseignée',
        },
      );

      if (response.user != null) {
        try {
          // Créer le profil (possible même sans session car RLS est désactivé)
          await Supabase.instance.client.from('profiles').insert({
            'id': response.user!.id,
            'nom': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
            'email': _emailController.text.trim(),
            'role': _selectedRole,
            'faculty_id': _selectedFacultyId,
            'department_id': _selectedRole != 'Administratif' ? _selectedDepartmentId : null,
            'service_id': _selectedRole == 'Administratif' ? _selectedServiceId : null,
            'telephone': '',
            'niveau': _selectedRole == 'Étudiant' ? _selectedLevel : 'Non renseigné',
            'filiere_id': 'Non renseignée',
            'created_at': DateTime.now().toIso8601String(),
          });
          
          if (mounted) {
            if (_selectedRole == 'Administratif') {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
            } else if (_selectedRole == 'Enseignant') {
              Navigator.pushReplacementNamed(context, '/teacher-dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/student-dashboard');
            }
          }
        } catch (e) {
          print('CRITICAL: Erreur lors de l\'insertion dans profiles: $e');
          if (e is PostgrestException) {
            print('Postgrest Details: ${e.message}, ${e.details}, ${e.hint}');
          }
          setState(() {
            _errorMessage = 'Erreur lors de la création du profil (Base de données). Vérifiez vos droits d\'accès.';
            _isLoading = false;
          });
          // On ne redirige pas si l'insertion a échoué car le profil est vide
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Erreur d\'inscription';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur d\'inscription';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Rejoignez la communauté universitaire',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Formulaire
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Nom et Prénom
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _firstNameController,
                                label: 'Prénom',
                                hint: 'Jean',
                                icon: Icons.person_outline_rounded,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Prénom requis';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _lastNameController,
                                label: 'Nom',
                                hint: 'Dupont',
                                icon: Icons.person_outline_rounded,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nom requis';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Email/Matricule
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email universitaire / Matricule',
                          hint: 'nom@univ-campus.fr ou MAT2024001',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email/Matricule requis';
                            }
                            if (!value.contains('@') && !value.startsWith('MAT')) {
                              return 'Format invalide';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Sélecteur de rôle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rôle',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedRole = 'Étudiant';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _selectedRole == 'Étudiant'
                                              ? const Color(0xFF2563EB)
                                              : Colors.transparent,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Étudiant',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: _selectedRole == 'Étudiant'
                                                ? Colors.white
                                                : const Color(0xFF6B7280),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedRole = 'Enseignant';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _selectedRole == 'Enseignant'
                                              ? const Color(0xFF2563EB)
                                              : Colors.transparent,
                                        ),
                                        child: Text(
                                          'Enseignant',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: _selectedRole == 'Enseignant'
                                                ? Colors.white
                                                : const Color(0xFF6B7280),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedRole = 'Administratif';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _selectedRole == 'Administratif'
                                              ? const Color(0xFF2563EB)
                                              : Colors.transparent,
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Administratif',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: _selectedRole == 'Administratif'
                                                ? Colors.white
                                                : const Color(0xFF6B7280),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Sélecteur de faculté
                        if (_faculties.isNotEmpty) _buildDropdown(
                          'Faculté',
                          _selectedFacultyId,
                          _faculties.map((f) => DropdownMenuItem<int>(
                            value: f['id'] is int ? f['id'] as int : int.tryParse(f['id']?.toString() ?? '') ?? 0,
                            child: Text(f['nom']?.toString() ?? f['name']?.toString() ?? 'Inconnu'),
                          )).toList(),
                          (value) {
                            setState(() {
                              _selectedFacultyId = value;
                              if (value != null) {
                                _loadDepartments(value);
                                _loadServices(value);
                              }
                            });
                          },
                        ),

                        if (_selectedRole == 'Étudiant') ...[
                          const SizedBox(height: 20),
                          _buildDropdown(
                            'Niveau (Licence)',
                            _selectedLevel,
                            _levelOptions.map((l) => DropdownMenuItem<String>(
                              value: l,
                              child: Text(l),
                            )).toList(),
                            (value) => setState(() => _selectedLevel = value!),
                          ),
                        ],

                        if (_selectedFacultyId != null) const SizedBox(height: 20),

                        // Sélecteur département/service
                        if (_selectedRole != 'Administratif' && _departments.isNotEmpty)
                          _buildDropdown(
                            'Département',
                            _selectedDepartmentId,
                            _departments.map((d) => DropdownMenuItem<int>(
                              value: d['id'] is int ? d['id'] as int : int.tryParse(d['id']?.toString() ?? '') ?? 0,
                              child: Text(d['nom']?.toString() ?? d['name']?.toString() ?? 'Inconnu'),
                            )).toList(),
                            (value) => setState(() => _selectedDepartmentId = value),
                          ),

                        if (_selectedRole == 'Administratif' && _services.isNotEmpty)
                          _buildDropdown(
                            'Service',
                            _selectedServiceId,
                            _services.map((s) => DropdownMenuItem<int>(
                              value: s['id'] is int ? s['id'] as int : int.tryParse(s['id']?.toString() ?? '') ?? 0,
                              child: Text(s['nom']?.toString() ?? s['name']?.toString() ?? 'Inconnu'),
                            )).toList(),
                            (value) => setState(() => _selectedServiceId = value),
                          ),

                        const SizedBox(height: 20),

                        // Mot de passe
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Mot de passe',
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mot de passe requis';
                            }
                            if (value.length < 6) {
                              return 'Min 6 caractères';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Message d'erreur
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFDC2626),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Bouton S'inscrire
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFF93C5FD),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'S\'inscrire',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Lien connexion
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: 'Déjà un compte ? ',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Se connecter',
                                    style: TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Footer
                const Text(
                  '© 2024 CampusConnect - Application universitaire officielle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF6B7280),
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF6B7280),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    void Function(T?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }

  void _showEmailConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation requise'),
        content: const Text(
          'Un email de confirmation vous a été envoyé. '
          'Veuillez confirmer votre compte pour pouvoir vous connecter.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialogue
              Navigator.of(context).pop(); // Retourner au login
            },
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}
