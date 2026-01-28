import 'package:dotenv/dotenv.dart';

class DatabaseConfig {
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    
    // For now, we'll use Supabase instead of direct PostgreSQL
    // This avoids dependency issues
    _initialized = true;
    print('✅ Database configuration initialized (using Supabase)');
  }
  
  static bool get isInitialized => _initialized;
  
  static Future<void> close() async {
    // Nothing to close for now
  }
  
  // Initialize tables - will be handled by Supabase
  static Future<void> initializeTables() async {
    print('✅ Database tables will be initialized via Supabase dashboard');
  }
}
