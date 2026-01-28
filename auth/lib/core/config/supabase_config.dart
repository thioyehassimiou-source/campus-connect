import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://votre-projet.supabase.co';
  static const String anonKey = 'votre-cle-anon';
  
  static SupabaseClient get client => Supabase.instance.client;
}
