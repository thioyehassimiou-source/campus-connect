class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final String? profileImageUrl;
  final UserRole role;
  final String? serviceType;
  final String? scopeFaculteId;
  final String? scopeDepartementId;
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
    this.serviceType,
    this.scopeFaculteId,
    this.scopeDepartementId,
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
      serviceType: json['service_type'],
      scopeFaculteId: json['scope_faculte_id'],
      scopeDepartementId: json['scope_departement_id'],
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
        'service_type': serviceType,
        'scope_faculte_id': scopeFaculteId,
        'scope_departement_id': scopeDepartementId,
        'phone': phone,
        'address': address,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static UserRole _parseRole(dynamic roleValue) {
    if (roleValue == null) return UserRole.ETUDIANT;
    final roleStr = roleValue.toString().toUpperCase();
    if (roleStr == 'SUPER_ADMIN' || roleStr == 'ADMIN' || roleStr == 'ADMINISTRATEUR') return UserRole.SUPER_ADMIN;
    if (roleStr == 'ADMIN_SERVICE') return UserRole.ADMIN_SERVICE;
    if (roleStr == 'ENSEIGNANT' || roleStr.contains('TEACHER') || roleStr.contains('PROF')) return UserRole.ENSEIGNANT;
    if (roleStr == 'ETUDIANT' || roleStr.contains('STUDENT')) return UserRole.ETUDIANT;
    return UserRole.ETUDIANT;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? profileImage,
    UserRole? role,
    String? serviceType,
    String? scopeFaculteId,
    String? scopeDepartementId,
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
      serviceType: serviceType ?? this.serviceType,
      scopeFaculteId: scopeFaculteId ?? this.scopeFaculteId,
      scopeDepartementId: scopeDepartementId ?? this.scopeDepartementId,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum UserRole {
  SUPER_ADMIN,
  ADMIN_SERVICE,
  ENSEIGNANT,
  ETUDIANT,
}
