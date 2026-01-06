import 'package:equatable/equatable.dart';

enum UserRole { student, teacher, admin }

class UserModel extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? department;
  final String? studentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    this.department,
    this.studentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.student,
      ),
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      department: map['department'],
      studentId: map['studentId'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'department': department,
      'studentId': studentId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? phoneNumber,
    String? profileImageUrl,
    String? department,
    String? studentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      department: department ?? this.department,
      studentId: studentId ?? this.studentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        role,
        phoneNumber,
        profileImageUrl,
        department,
        studentId,
        createdAt,
        updatedAt,
      ];

  String get fullName => '$firstName $lastName';
}
