import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? phone;
  final String? profileImageUrl;
  final String? department;
  final String? studentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
    this.profileImageUrl,
    this.department,
    this.studentId,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get fullName => '$firstName $lastName';
  
  String get roleDisplayName {
    switch (role) {
      case 'etudiant':
        return 'Étudiant';
      case 'enseignant':
        return 'Enseignant';
      case 'administrateur':
        return 'Administrateur';
      default:
        return role;
    }
  }
}

enum UserRole {
  etudiant,
  enseignant,
  administrateur;
}

class CreateUserRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? phone;
  final String? department;
  final String? studentId;

  CreateUserRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
    this.department,
    this.studentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'role': role.name,
      'phone': phone,
      'department': department,
      'student_id': studentId,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class AuthResponse {
  final UserModel user;
  final String token;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.token,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}
