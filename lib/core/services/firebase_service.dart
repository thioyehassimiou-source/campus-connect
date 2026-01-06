import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Auth getters
  static FirebaseAuth get auth => _auth;
  static FirebaseFirestore get firestore => _firestore;
  static FirebaseStorage get storage => _storage;
  static FirebaseMessaging get messaging => _messaging;

  // Current user
  static User? get currentUser => _auth.currentUser;

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    
    // Request notification permissions
    await _messaging.requestPermission();
    
    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;
}
