import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String role;
  final String? phone;
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  final String? department;
  @JsonKey(name: 'student_id')
  final String? studentId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'is_active')
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
  final String? filiere;
  final String? niveau;
  final String? studentId;

  CreateUserRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
    this.filiere,
    this.niveau,
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
      'filiere': filiere,
      'niveau': niveau,
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
