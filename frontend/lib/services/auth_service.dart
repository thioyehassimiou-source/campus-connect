import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static Future<AuthResponse> register(CreateUserRequest request) async {
    final response = await ApiService.register(request);
    
    if (response.success && response.data != null) {
      await StorageService.saveToken(response.data!.token);
      await StorageService.saveRefreshToken(response.data!.refreshToken);
      await StorageService.saveUser(response.data!.user);
    }
    
    return _handleAuthResponse(response);
  }
  
  static Future<AuthResponse> login(LoginRequest request) async {
    final response = await ApiService.login(request);
    
    if (response.success && response.data != null) {
      await StorageService.saveToken(response.data!.token);
      await StorageService.saveRefreshToken(response.data!.refreshToken);
      await StorageService.saveUser(response.data!.user);
    }
    
    return _handleAuthResponse(response);
  }
  
  static Future<void> logout() async {
    final token = await StorageService.getToken();
    
    if (token != null) {
      await ApiService.logout(token);
    }
    
    await StorageService.clearAll();
  }
  
  static Future<UserModel?> getCurrentUser() async {
    final token = await StorageService.getToken();
    
    if (token == null) {
      return null;
    }
    
    final response = await ApiService.getCurrentUser(token);
    
    if (response.success && response.data != null) {
      await StorageService.saveUser(response.data!);
      return response.data!;
    }
    
    return null;
  }
  
  static Future<AuthResponse?> refreshToken() async {
    final refreshToken = await StorageService.getRefreshToken();
    
    if (refreshToken == null) {
      return null;
    }
    
    final response = await ApiService.refreshToken(refreshToken);
    
    if (response.success && response.data != null) {
      await StorageService.saveToken(response.data!.token);
      await StorageService.saveRefreshToken(response.data!.refreshToken);
      await StorageService.saveUser(response.data!.user);
      return response.data!;
    }
    
    // If refresh fails, clear stored data
    await StorageService.clearAll();
    return null;
  }
  
  static Future<bool> isLoggedIn() async {
    final token = await StorageService.getToken();
    return token != null;
  }
  
  static Future<UserModel?> getStoredUser() async {
    return await StorageService.getUser();
  }
  
  static Future<String?> getToken() async {
    return await StorageService.getToken();
  }
  
  static AuthResponse _handleAuthResponse(ApiResponse<AuthResponse> response) {
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error?.message ?? 'Authentication failed');
    }
  }
}
