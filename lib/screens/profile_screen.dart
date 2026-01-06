import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campusconnect/core/themes/app_theme.dart';
import 'package:campusconnect/shared/widgets/custom_text_field.dart';
import 'package:campusconnect/shared/widgets/custom_button.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:campusconnect/core/services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _studentIdController;

  bool _isLoading = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _departmentController = TextEditingController(text: widget.user.department ?? '');
    _studentIdController = TextEditingController(text: widget.user.studentId ?? '');
    _profileImageUrl = widget.user.profileImageUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // TODO: Upload image to Firebase Storage
        setState(() {
          _profileImageUrl = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = widget.user.copyWith(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        department: _departmentController.text.isEmpty ? null : _departmentController.text,
        studentId: _studentIdController.text.isEmpty ? null : _studentIdController.text,
        profileImageUrl: _profileImageUrl,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.firestore
          .collection('users')
          .doc(widget.user.id)
          .set(updatedUser.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // User Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations personnelles',
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        controller: _firstNameController,
                        label: 'Prénom',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre prénom';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        controller: _lastNameController,
                        label: 'Nom',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Téléphone',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Academic Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations académiques',
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        controller: _departmentController,
                        label: 'Département/Filière',
                        prefixIcon: Icons.school,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      if (widget.user.role == UserRole.student) ...[
                        CustomTextField(
                          controller: _studentIdController,
                          label: 'Numéro étudiant',
                          prefixIcon: Icons.badge,
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Role Display
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Rôle: ${_getRoleDisplayName(widget.user.role)}',
                            style: AppTheme.bodyStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Update Button
              CustomButton(
                text: 'Mettre à jour le profil',
                onPressed: _updateProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Étudiant';
      case UserRole.teacher:
        return 'Enseignant';
      case UserRole.admin:
        return 'Administrateur';
    }
  }
}
