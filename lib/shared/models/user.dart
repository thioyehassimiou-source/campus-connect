class User {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phone;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: _parseRole(json['role']),
      phone: json['phone'],
    );
  }

  static UserRole _parseRole(dynamic roleValue) {
    if (roleValue == null) return UserRole.student;
    final roleStr = roleValue.toString().toLowerCase();
    if (roleStr.contains('admin')) return UserRole.admin;
    if (roleStr.contains('teacher')) return UserRole.teacher;
    return UserRole.student;
  }
}

enum UserRole {
  student,
  teacher,
  admin,
}
