import 'package:campusconnect/shared/models/user_model.dart';

/// Modèle enrichi d'un utilisateur pour la vue Administrateur.
/// Étend UserModel avec des champs utiles à la gestion admin.
class AdminUserModel {
  final String id;
  final String email;
  final String fullName;
  final String? firstName;
  final String? lastName;
  final UserRole role;
  final bool isActive;
  final String? phone;
  final String? avatarUrl;
  final String? matricule;
  final String? departement;
  final String? filiere;
  final String? niveau;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const AdminUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.firstName,
    this.lastName,
    required this.role,
    this.isActive = true,
    this.phone,
    this.avatarUrl,
    this.matricule,
    this.departement,
    this.filiere,
    this.niveau,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['nom'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: _parseRole(json['role']),
      isActive: json['is_active'] ?? true,
      phone: json['phone'] ?? json['telephone'],
      avatarUrl: json['profile_image_url'] ?? json['avatar_url'],
      matricule: json['matricule'],
      departement: json['departement'],
      filiere: json['filiere'],
      niveau: json['niveau'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'first_name': firstName,
        'last_name': lastName,
        'role': role.supabaseValue,
        'is_active': isActive,
        'phone': phone,
        'avatar_url': avatarUrl,
        'matricule': matricule,
        'departement': departement,
        'filiere': filiere,
        'niveau': niveau,
        'created_at': createdAt.toIso8601String(),
      };

  AdminUserModel copyWith({
    String? fullName,
    UserRole? role,
    bool? isActive,
    String? phone,
    String? departement,
    String? filiere,
    String? niveau,
  }) {
    return AdminUserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      firstName: firstName,
      lastName: lastName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl,
      matricule: matricule,
      departement: departement ?? this.departement,
      filiere: filiere ?? this.filiere,
      niveau: niveau ?? this.niveau,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  static UserRole _parseRole(dynamic roleValue) {
    if (roleValue == null) return UserRole.ETUDIANT;
    final s = roleValue.toString().toUpperCase();
    if (s.contains('ADMIN') || s == 'ADMINISTRATEUR') return UserRole.SUPER_ADMIN;
    if (s == 'ADMIN_SERVICE') return UserRole.ADMIN_SERVICE;
    if (s.contains('ENSEIGNANT') || s.contains('TEACHER') || s.contains('PROF')) {
      return UserRole.ENSEIGNANT;
    }
    return UserRole.ETUDIANT;
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get roleLabel {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return 'Administrateur';
      case UserRole.ADMIN_SERVICE:
        return 'Admin Service';
      case UserRole.ENSEIGNANT:
        return 'Enseignant';
      case UserRole.ETUDIANT:
        return 'Étudiant';
    }
  }
}

extension UserRoleExt on UserRole {
  String get supabaseValue {
    switch (this) {
      case UserRole.SUPER_ADMIN:
        return 'Admin';
      case UserRole.ADMIN_SERVICE:
        return 'Admin_Service';
      case UserRole.ENSEIGNANT:
        return 'Enseignant';
      case UserRole.ETUDIANT:
        return 'Étudiant';
    }
  }
}
