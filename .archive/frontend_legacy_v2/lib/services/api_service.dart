import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class ApiService {
  static final _client = http.Client();
  
  static Map<String, String> _getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  static Future<ApiResponse<T>> _handleRequest<T>(
    Future<http.Response> Function() requestFunction,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await requestFunction();
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = json.decode(response.body);
        return ApiResponse<T>.fromJson(body, fromJson);
      } else {
        final body = json.decode(response.body);
        return ApiResponse<T>.error(
          body['error']['message'] ?? 'Request failed',
          code: body['error']['code'],
        );
      }
    } catch (e) {
      return ApiResponse<T>.error('Network error: $e');
    }
  }
  
  // Auth endpoints
  static Future<ApiResponse<AuthResponse>> register(CreateUserRequest request) async {
    return _handleRequest<AuthResponse>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      ),
      (json) => AuthResponse.fromJson(json),
    );
  }
  
  static Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    return _handleRequest<AuthResponse>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: _getHeaders(),
        body: json.encode(request.toJson()),
      ),
      (json) => AuthResponse.fromJson(json),
    );
  }
  
  static Future<ApiResponse<Map<String, dynamic>>> logout(String token) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
        headers: _getHeaders(token: token),
      ),
      (json) => json as Map<String, dynamic>,
    );
  }
  
  static Future<ApiResponse<UserModel>> getCurrentUser(String token) async {
    return _handleRequest<UserModel>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
        headers: _getHeaders(token: token),
      ),
      (json) => UserModel.fromJson(json),
    );
  }
  
  static Future<ApiResponse<AuthResponse>> refreshToken(String refreshToken) async {
    return _handleRequest<AuthResponse>(
      () => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/refresh'),
        headers: _getHeaders(),
        body: json.encode({'refreshToken': refreshToken}),
      ),
      (json) => AuthResponse.fromJson(json),
    );
  }
  
  // User endpoints
  static Future<ApiResponse<List<UserModel>>> getUsers({
    int page = 1,
    int limit = 10,
    String? role,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (role != null) {
      queryParams['role'] = role;
    }
    
    final uri = Uri.parse('${ApiConfig.baseUrl}/users')
        .replace(queryParameters: queryParams);
    
    return _handleRequest<List<UserModel>>(
      () => _client.get(
        uri,
        headers: _getHeaders(token: token),
      ),
      (json) {
        final data = json['data'] as List;
        return data.map((item) => UserModel.fromJson(item)).toList();
      },
    );
  }
  
  static Future<ApiResponse<UserModel>> getUserById(String id, {String? token}) async {
    return _handleRequest<UserModel>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$id'),
        headers: _getHeaders(token: token),
      ),
      (json) => UserModel.fromJson(json),
    );
  }
  
  static Future<ApiResponse<UserModel>> updateUser(
    String id,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    return _handleRequest<UserModel>(
      () => _client.put(
        Uri.parse('${ApiConfig.baseUrl}/users/$id'),
        headers: _getHeaders(token: token),
        body: json.encode(data),
      ),
      (json) => UserModel.fromJson(json),
    );
  }
  
  static Future<ApiResponse<Map<String, dynamic>>> deleteUser(String id, {String? token}) async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/users/$id'),
        headers: _getHeaders(token: token),
      ),
      (json) => json as Map<String, dynamic>,
    );
  }
  
  // Health check
  static Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    return _handleRequest<Map<String, dynamic>>(
      () => _client.get(
        Uri.parse('${ApiConfig.baseUrl}/health'),
        headers: _getHeaders(),
      ),
      (json) => json as Map<String, dynamic>,
    );
  }
}
