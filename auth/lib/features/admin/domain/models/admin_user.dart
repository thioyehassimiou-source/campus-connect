import '../../../auth/domain/models/app_user.dart';

class AdminUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final UserRole role;

  const AdminUser({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
  });

  String get fullName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    final n = '$f $l'.trim();
    return n.isEmpty ? email : n;
  }

  factory AdminUser.fromMap(Map<String, dynamic> map) {
    return AdminUser(
      id: (map['id'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      firstName: map['first_name']?.toString(),
      lastName: map['last_name']?.toString(),
      role: UserRole.fromString(map['role']?.toString()),
    );
  }
}
