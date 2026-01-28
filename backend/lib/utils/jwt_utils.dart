import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';
import 'dart:convert';
import '../models/user_model.dart';

class JwtUtils {
  static String _getSecret() {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    return env['JWT_SECRET'] ?? 'default_secret_key_change_in_production';
  }
  
  static String generateToken(UserModel user) {
    final secret = _getSecret();
    final now = DateTime.now();
    final expireAt = now.add(Duration(hours: 24));
    
    final jwt = JWT({
      'userId': user.id,
      'email': user.email,
      'role': user.role,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expireAt.millisecondsSinceEpoch ~/ 1000,
      'type': 'access',
    });
    
    return jwt.sign(SecretKey(secret));
  }
  
  static String generateRefreshToken(UserModel user) {
    final secret = _getSecret();
    final now = DateTime.now();
    final expireAt = now.add(Duration(days: 7));
    
    final jwt = JWT({
      'userId': user.id,
      'email': user.email,
      'role': user.role,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expireAt.millisecondsSinceEpoch ~/ 1000,
      'type': 'refresh',
    });
    
    return jwt.sign(SecretKey(secret));
  }
  
  static Future<Map<String, dynamic>> validateToken(String token) async {
    try {
      final secret = _getSecret();
      final jwt = JWT.verify(token, SecretKey(secret));
      
      // Check if token is expired
      final exp = jwt.payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      if (now > exp) {
        throw Exception('Token expired');
      }
      
      return jwt.payload as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid token: $e');
    }
  }
  
  static Future<Map<String, dynamic>> validateAccessToken(String token) async {
    final payload = await validateToken(token);
    
    if (payload['type'] != 'access') {
      throw Exception('Invalid token type');
    }
    
    return payload;
  }
  
  static Future<Map<String, dynamic>> validateRefreshToken(String token) async {
    final payload = await validateToken(token);
    
    if (payload['type'] != 'refresh') {
      throw Exception('Invalid token type');
    }
    
    return payload;
  }
  
  static String? extractUserIdFromToken(String token) {
    try {
      final secret = _getSecret();
      final jwt = JWT.verify(token, SecretKey(secret));
      return jwt.payload['userId'] as String?;
    } catch (e) {
      return null;
    }
  }
}
