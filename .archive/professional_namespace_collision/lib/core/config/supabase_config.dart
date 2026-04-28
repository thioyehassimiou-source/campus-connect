import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://votre-projet.supabase.co';
  static const String anonKey = 'votre-cle-anon';
  static const String serviceKey = 'votre-cle-service';
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static bool get isInitialized => Supabase.instance.isInitialized;
}
