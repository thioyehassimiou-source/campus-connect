enum UserRole {
  etudiant,
  enseignant,
  admin;

  static UserRole fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'enseignant':
        return UserRole.enseignant;
      case 'admin':
      case 'administrateur':
        return UserRole.admin;
      case 'etudiant':
      default:
        return UserRole.etudiant;
    }
  }

  String get value {
    switch (this) {
      case UserRole.etudiant:
        return 'etudiant';
      case UserRole.enseignant:
        return 'enseignant';
      case UserRole.admin:
        return 'admin';
    }
  }

  String get label {
    switch (this) {
      case UserRole.etudiant:
        return 'Étudiant';
      case UserRole.enseignant:
        return 'Enseignant';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

class AppUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
  });

  String get fullName {
    final first = (firstName ?? '').trim();
    final last = (lastName ?? '').trim();
    final name = '$first $last'.trim();
    return name.isEmpty ? email : name;
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: (map['id'] ?? map['user_id'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      firstName: map['first_name']?.toString(),
      lastName: map['last_name']?.toString(),
      role: UserRole.fromString(map['role']?.toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role.value,
    };
  }
}
