import 'package:supabase_flutter/supabase_flutter.dart';

class FirebaseService {
  // Deprecated - use SupabaseService instead
  @deprecated
  static SupabaseClient get firestore => Supabase.instance.client;
  
  @deprecated
  static SupabaseClient get storage => Supabase.instance.client;

  // Current user
  static User? get currentUser => Supabase.instance.client.auth.currentUser;

  // Initialize Supabase
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: FirebaseConfig.web,
      );
    } catch (e) {
      // If Firebase is already initialized, ignore the error
      if (e.toString().contains('already-initialized')) {
        return;
      }
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;
}
