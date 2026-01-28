import 'package:supabase/supabase.dart';
import 'package:dotenv/dotenv.dart';

class SupabaseConfig {
  static SupabaseClient? _client;
  
  static Future<void> initialize() async {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    
    _client = SupabaseClient(
      env['SUPABASE_URL'] ?? '',
      env['SUPABASE_ANON_KEY'] ?? '',
    );
    
    print('✅ Supabase client initialized');
  }
  
  static SupabaseClient get client {
    if (_client == null) {
      throw StateError('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }
  
  // Alternative to PostgreSQL for development
  static Future<void> initializeSupabaseTables() async {
    try {
      // Create users table
      await client.from('users').select().limit(1);
      
      // Create schedules table
      await client.from('schedules').select().limit(1);
      
      // Create grades table
      await client.from('grades').select().limit(1);
      
      // Create announcements table
      await client.from('announcements').select().limit(1);
      
      // Create documents table
      await client.from('documents').select().limit(1);
      
      print('✅ Supabase tables verified');
    } catch (e) {
      print('⚠️ Supabase tables verification failed: $e');
      // Tables might not exist, need to create them via Supabase dashboard
    }
  }
}
