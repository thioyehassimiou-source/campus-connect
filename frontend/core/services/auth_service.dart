import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campusconnect/shared/models/user_model.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Register with email and password
  static Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    try {
      print('Starting registration for email: $email');
      
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User created successfully: ${result.user?.uid}');

      // Update user profile
      await result.user?.updateDisplayName('$firstName $lastName');

      // Create user document in Firestore
      await _createUserDocument(
        uid: result.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
      );

      print('User document created successfully');
      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      throw _getErrorMessage(e);
    } catch (e) {
      print('General Exception during registration: $e');
      throw 'Une erreur est survenue lors de l\'inscription: ${e.toString()}';
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting sign in for email: $email');
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign in successful: ${result.user?.uid}');
      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during sign in: ${e.code} - ${e.message}');
      throw _getErrorMessage(e);
    } catch (e) {
      print('General Exception during sign in: $e');
      throw 'Une erreur est survenue lors de la connexion: ${e.toString()}';
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Une erreur est survenue lors de la déconnexion';
    }
  }

  // Create user document in Firestore
  static Future<void> _createUserDocument({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required UserRole role,
  }) async {
    try {
      await FirebaseService.firestore.collection('users').doc(uid).set({
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role.toString().split('.').last,
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
      });
    } catch (e) {
      // If Firestore fails, continue (user is still created in Auth)
      print('Error creating user document: $e');
    }
  }

  // Get user-friendly error message
  static String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'user-not-found':
        return 'Utilisateur non trouvé';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'invalid-email':
        return 'Email invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard';
      case 'operation-not-allowed':
        return 'Opération non autorisée';
      default:
        return 'Une erreur est survenue: ${e.message}';
    }
  }

  // Get current user data from Firestore
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseService.firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Add document ID
          return data;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}
