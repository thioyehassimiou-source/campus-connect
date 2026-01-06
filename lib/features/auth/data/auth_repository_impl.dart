import 'package:campusconnect/core/services/firebase_service.dart';
import 'package:campusconnect/features/auth/domain/auth_repository.dart';
import 'package:campusconnect/shared/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<(String, UserModel?)> signIn(String email, String password) async {
    try {
      final userCredential = await FirebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return ('User profile not found', null);
      }

      final userModel = UserModel.fromMap(userDoc.data()!);
      return ('', userModel);
    } catch (e) {
      return (e.toString(), null);
    }
  }

  @override
  Future<(String, UserModel?)> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    UserRole role,
  ) async {
    try {
      final userCredential = await FirebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseService.firestore
          .collection('users')
          .doc(userModel.id)
          .set(userModel.toMap());

      return ('', userModel);
    } catch (e) {
      return (e.toString(), null);
    }
  }

  @override
  Future<(String, void)> signOut() async {
    try {
      await FirebaseService.signOut();
      return ('', null);
    } catch (e) {
      return (e.toString(), null);
    }
  }

  @override
  Future<(String, UserModel?)> getCurrentUser() async {
    try {
      final user = FirebaseService.currentUser;
      if (user == null) {
        return ('No user logged in', null);
      }

      final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        return ('User profile not found', null);
      }

      final userModel = UserModel.fromMap(userDoc.data()!);
      return ('', userModel);
    } catch (e) {
      return (e.toString(), null);
    }
  }

  @override
  Future<(String, void)> resetPassword(String email) async {
    try {
      await FirebaseService.auth.sendPasswordResetEmail(email: email);
      return ('', null);
    } catch (e) {
      return (e.toString(), null);
    }
  }

  @override
  Future<(String, UserModel?)> updateProfile(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      
      await FirebaseService.firestore
          .collection('users')
          .doc(user.id)
          .set(updatedUser.toMap());

      return ('', updatedUser);
    } catch (e) {
      return (e.toString(), null);
    }
  }
}
