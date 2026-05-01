import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/services/auth_service.dart';
import 'package:campusconnect/services/api_service.dart';
import 'package:campusconnect/models/user_model.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/widgets/theme_toggle_button.dart';
import 'package:campusconnect/controllers/auth_providers.dart';

class ModernRegisterScreen extends ConsumerStatefulWidget {
  const ModernRegisterScreen({super.key});

  @override
  ConsumerState<ModernRegisterScreen> createState() => _ModernRegisterScreenState();
}

class _ModernRegisterScreenState extends ConsumerState<ModernRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'Étudiant';
  String _selectedLevel = 'Licence 1';
  final List<String> _levelOptions = ['Licence 1', 'Licence 2', 'Licence 3'];
  dynamic _selectedFiliereId;
  dynamic _selectedServiceId;
  dynamic _selectedFacultyId;
  List<Map<String, dynamic>> _filieres = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _faculties = [];
  bool _isInitialLoading = true;
  String? _initialLoadError;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isInitialLoading = true;
      _initialLoadError = null;
    });

    try {
      final filieresResponse = await ApiService.getFilieres();
      final servicesResponse = await ApiService.getServices();
      final facultiesResponse = await ApiService.getFaculties();
      
      if (mounted) {
        setState(() {
          if (filieresResponse.success && filieresResponse.data != null) {
            _filieres = filieresResponse.data!;
          }
          if (servicesResponse.success && servicesResponse.data != null) {
            _services = servicesResponse.data!;
          }
          if (facultiesResponse.success && facultiesResponse.data != null) {
            _faculties = facultiesResponse.data!;
          }
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      print('Erreur chargement données initiales: $e');
      if (mounted) {
        setState(() {
          _initialLoadError = 'Impossible de charger les données universitaires.';
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'Administratif' && _selectedServiceId == null) {
      setState(() { _errorMessage = 'Veuillez sélectionner un service'; });
      return;
    }
    
    if (_selectedRole == 'Étudiant' && _selectedFiliereId == null) {
      setState(() { _errorMessage = 'Veuillez sélectionner un département'; });
      return;
    }

    if (_selectedRole == 'Enseignant' && _selectedFacultyId == null) {
      setState(() { _errorMessage = 'Veuillez sélectionner une faculté'; });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final UserRole role;
      switch (_selectedRole) {
        case 'Enseignant':
          role = UserRole.enseignant;
          break;
        case 'Administratif':
          role = UserRole.administrateur;
          break;
        default:
          role = UserRole.etudiant;
      }

      final request = CreateUserRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: role,
        filiere: _selectedRole == 'Étudiant' 
            ? _selectedFiliereId?.toString() 
            : (_selectedRole == 'Enseignant' ? _selectedFacultyId?.toString() : null),
        niveau: _selectedRole == 'Étudiant' ? _selectedLevel : null,
        studentId: _selectedRole == 'Étudiant' ? _emailController.text.trim().split('@')[0] : null,
      );

      final result = await AuthService.register(request);

      if (mounted) {
        // Update authStateProvider
        ref.read(authStateProvider.notifier).setUser(result.user);

        if (_selectedRole == 'Administratif') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (_selectedRole == 'Enseignant') {
          Navigator.pushReplacementNamed(context, '/teacher-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/student-dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Exception:') 
              ? e.toString().replaceAll('Exception: ', '') 
              : e.toString();
          _isLoading = false;
        });
      }
      print('Erreur d\'inscription UI: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
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
                  Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rejoignez la communauté universitaire',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Formulaire
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
                      // Prénom
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'Prénom',
                        hint: 'Jean',
                        icon: Icons.person_outline_rounded,
                        validator: (value) => (value == null || value.isEmpty) ? 'Prénom requis' : null,
                      ),
                      const SizedBox(height: 20),

                      // Nom
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Nom',
                        hint: 'Dupont',
                        icon: Icons.person_outline_rounded,
                        validator: (value) => (value == null || value.isEmpty) ? 'Nom requis' : null,
                      ),
                      const SizedBox(height: 20),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email / Matricule',
                        hint: 'nom@univ-campus.fr',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email requis';
                          if (!value.contains('@') && !value.startsWith('MAT')) return 'Format invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Rôle
                      _buildRoleSelector(),

                      const SizedBox(height: 20),

                      // Champs dynamiques
                      if (_isInitialLoading)
                        const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2)))
                      else ...[
                        // Faculté visible pour Étudiant et Enseignant
                        if (_selectedRole == 'Étudiant' || _selectedRole == 'Enseignant') ...[
                          _buildDropdown(
                            'Faculté',
                            _selectedFacultyId,
                            _faculties.map((f) => DropdownMenuItem<dynamic>(
                              value: f['id'],
                              child: Text(f['nom']?.toString() ?? f['name']?.toString() ?? 'Inconnu'),
                            )).toList(),
                            (value) {
                              setState(() {
                                _selectedFacultyId = value;
                                _selectedFiliereId = null; // ✅ Réinitialiser le département
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        if (_selectedRole == 'Étudiant') ...[
                          _buildDropdown(
                            'Département',
                            _selectedFiliereId,
                            _filieres.where((f) {
                              if (_selectedFacultyId == null) return true;
                              // Trouver le nom de la faculté sélectionnée pour comparer
                              final selectedFac = _faculties.firstWhere(
                                (fac) => fac['id'] == _selectedFacultyId,
                                orElse: () => {},
                              );
                              final facName = selectedFac['name'] ?? selectedFac['nom'];
                              return f['faculty'] == facName;
                            }).map((f) => DropdownMenuItem<dynamic>(
                              value: f['id'],
                              child: Text(f['nom']?.toString() ?? 'Inconnu'),
                            )).toList(),
                            (value) => setState(() => _selectedFiliereId = value),
                          ),
                          const SizedBox(height: 20),
                          _buildDropdown(
                            'Niveau (Licence)',
                            _selectedLevel,
                            _levelOptions.map((l) => DropdownMenuItem<String>(
                              value: l,
                              child: Text(l),
                            )).toList(),
                            (value) => setState(() => _selectedLevel = value as String),
                          ),
                        ] else if (_selectedRole == 'Administratif') ...[
                          _buildDropdown(
                            'Service / Entité',
                            _selectedServiceId,
                            _services.map((s) => DropdownMenuItem<dynamic>(
                              value: s['id'],
                              child: Text(s['nom']?.toString() ?? 'Inconnu'),
                            )).toList(),
                            (value) => setState(() => _selectedServiceId = value),
                          ),
                        ],
                      ],

                      const SizedBox(height: 20),

                      // Mot de passe
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Mot de passe requis';
                          if (value.length < 6) return 'Min 6 caractères';
                          return null;
                        },
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _buildErrorMessage(_errorMessage!),
                      ],

                      const SizedBox(height: 32),

                      // Bouton Inscription
                      _buildSubmitButton(),

                      const SizedBox(height: 20),

                      // Connexion
                      _buildLoginLink(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '© 2024 CampusConnect - Application officielle',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).iconTheme.color,
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
            fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
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
    // ✅ Filtrer les items invalides pour éviter les doublons
    final validItems = items.where((item) {
      if (item.value is int) {
        return (item.value as int) > 0; // Exclure 0 et valeurs négatives
      }
      return item.value != null;
    }).toList();

    // ✅ Vérifier si la valeur actuelle est valide
    T? safeValue = value;
    if (value is int && (value as int) <= 0) {
      safeValue = null;
    }
    
    // Si la valeur n'est pas dans les items valides, mettre à null
    if (safeValue != null && !validItems.any((item) => item.value == safeValue)) {
      safeValue = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          isExpanded: true,
          value: safeValue,
          items: validItems,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            ),
          ),
          hint: Text(
            'Sélectionner...',
            style: TextStyle(color: Color(0xFF9CA3AF)),
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

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rôle',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildRoleOption('Étudiant', const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))),
              _buildRoleOption('Enseignant', BorderRadius.zero),
              _buildRoleOption('Administratif', const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleOption(String role, BorderRadius borderRadius) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12), // ✅ Plus compact
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Text(
            role,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              fontSize: 13, // ✅ Taille réduite pour tenir
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : const Text('S\'inscrire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: RichText(
          text: TextSpan(
            text: 'Déjà un compte ? ',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
            children: [
              const TextSpan(text: 'Se connecter', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
