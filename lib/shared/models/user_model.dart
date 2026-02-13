class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final String? profileImageUrl;
  final UserRole role;
  final String? phone;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.profileImageUrl,
    required this.role,
    this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
      profileImageUrl: json['profile_image_url'],
      role: _parseRole(json['role']),
      phone: json['phone'],
      address: json['address'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel.fromJson(map);

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'first_name': firstName,
        'last_name': lastName,
        'profile_image': profileImage,
        'profile_image_url': profileImageUrl,
        'role': role.toString().split('.').last,
        'phone': phone,
        'address': address,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static UserRole _parseRole(dynamic roleValue) {
    if (roleValue == null) return UserRole.student;
    final roleStr = roleValue.toString().toLowerCase();
    if (roleStr.contains('admin')) return UserRole.admin;
    if (roleStr.contains('teacher')) return UserRole.teacher;
    if (roleStr.contains('student')) return UserRole.student;
    return UserRole.student;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? profileImage,
    UserRole? role,
    String? phone,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum UserRole {
  student,
  teacher,
  admin,
  etudiant,
  enseignant,
  administrateur,
}
