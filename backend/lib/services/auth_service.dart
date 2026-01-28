import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:dotenv/dotenv.dart';

import '../models/user_model.dart';
import '../config/supabase_config.dart';
import '../utils/jwt_utils.dart';

class AuthService {
  static Future<AuthResponse> register(CreateUserRequest request) async {
    final client = SupabaseConfig.client;
    
    // Check if user already exists
    final existingUser = await client
        .from('users')
        .select('id')
        .eq('email', request.email)
        .maybeSingle();
    
    if (existingUser != null) {
      throw Exception('User with this email already exists');
    }
    
    // Hash password
    final passwordHash = _hashPassword(request.password);
    
    // Create user
    final result = await client
        .from('users')
        .insert({
          'email': request.email,
          'password_hash': passwordHash,
          'first_name': request.firstName,
          'last_name': request.lastName,
          'role': request.role.name,
          'phone': request.phone,
          'department': request.department,
          'student_id': request.studentId,
          'is_active': true,
        })
        .select()
        .single();
    
    final user = UserModel(
      id: result['id'].toString(),
      email: result['email'],
      firstName: result['first_name'],
      lastName: result['last_name'],
      role: result['role'],
      phone: result['phone'],
      department: result['department'],
      studentId: result['student_id'],
      createdAt: DateTime.parse(result['created_at']),
      updatedAt: DateTime.parse(result['updated_at']),
      isActive: result['is_active'],
    );
    
    // Generate tokens
    final token = JwtUtils.generateToken(user);
    final refreshToken = JwtUtils.generateRefreshToken(user);
    
    return AuthResponse(
      user: user,
      token: token,
      refreshToken: refreshToken,
    );
  }
  
  static Future<AuthResponse> login(LoginRequest request) async {
    final client = SupabaseConfig.client;
    
    // Find user by email
    final result = await client
        .from('users')
        .select('*')
        .eq('email', request.email)
        .eq('is_active', true)
        .maybeSingle();
    
    if (result == null) {
      throw Exception('Invalid email or password');
    }
    
    final storedPasswordHash = result['password_hash'].toString();
    
    // Verify password
    if (!_verifyPassword(request.password, storedPasswordHash)) {
      throw Exception('Invalid email or password');
    }
    
    final user = UserModel(
      id: result['id'].toString(),
      email: result['email'],
      firstName: result['first_name'],
      lastName: result['last_name'],
      role: result['role'],
      phone: result['phone'],
      department: result['department'],
      studentId: result['student_id'],
      createdAt: DateTime.parse(result['created_at']),
      updatedAt: DateTime.parse(result['updated_at']),
      isActive: result['is_active'],
    );
    
    // Generate tokens
    final token = JwtUtils.generateToken(user);
    final refreshToken = JwtUtils.generateRefreshToken(user);
    
    return AuthResponse(
      user: user,
      token: token,
      refreshToken: refreshToken,
    );
  }
  
  static Future<void> logout(String token) async {
    // In a real implementation, you would add the token to a blacklist
    // For now, we'll just validate that the token is valid
    await JwtUtils.validateToken(token);
  }
  
  static Future<UserModel> getCurrentUser(String token) async {
    final payload = await JwtUtils.validateToken(token);
    final userId = payload['userId'] as String;
    
    final client = SupabaseConfig.client;
    final result = await client
        .from('users')
        .select('*')
        .eq('id', userId)
        .eq('is_active', true)
        .single();
    
    return UserModel(
      id: result['id'].toString(),
      email: result['email'],
      firstName: result['first_name'],
      lastName: result['last_name'],
      role: result['role'],
      phone: result['phone'],
      department: result['department'],
      studentId: result['student_id'],
      createdAt: DateTime.parse(result['created_at']),
      updatedAt: DateTime.parse(result['updated_at']),
      isActive: result['is_active'],
    );
  }
  
  static Future<AuthResponse> refreshToken(String refreshToken) async {
    final payload = await JwtUtils.validateToken(refreshToken);
    final userId = payload['userId'] as String;
    
    final client = SupabaseConfig.client;
    final result = await client
        .from('users')
        .select('*')
        .eq('id', userId)
        .eq('is_active', true)
        .single();
    
    final user = UserModel(
      id: result['id'].toString(),
      email: result['email'],
      firstName: result['first_name'],
      lastName: result['last_name'],
      role: result['role'],
      phone: result['phone'],
      department: result['department'],
      studentId: result['student_id'],
      createdAt: DateTime.parse(result['created_at']),
      updatedAt: DateTime.parse(result['updated_at']),
      isActive: result['is_active'],
    );
    
    // Generate new tokens
    final newToken = JwtUtils.generateToken(user);
    final newRefreshToken = JwtUtils.generateRefreshToken(user);
    
    return AuthResponse(
      user: user,
      token: newToken,
      refreshToken: newRefreshToken,
    );
  }
  
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  static bool _verifyPassword(String password, String hashedPassword) {
    final hashedInput = _hashPassword(password);
    return hashedInput == hashedPassword;
  }
}
