class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';
  
  // Endpoints
  static const String auth = '/auth';
  static const String users = '/users';
  static const String schedule = '/schedule';
  static const String grades = '/grades';
  static const String announcements = '/announcements';
  static const String documents = '/documents';
  static const String health = '/health';
  
  // Auth endpoints
  static const String register = '$auth/register';
  static const String login = '$auth/login';
  static const String logout = '$auth/logout';
  static const String profile = '$auth/profile';
  static const String refresh = '$auth/refresh';
  
  // User endpoints
  static const String usersMe = '$users/me';
  
  // Request timeout
  static const Duration timeout = Duration(seconds: 30);
  
  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
}
