import 'package:campusconnect/shared/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<String, UserModel>> signIn(String email, String password);
  Future<Either<String, UserModel>> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    UserRole role,
  );
  Future<Either<String, void>> signOut();
  Future<Either<String, UserModel>> getCurrentUser();
  Future<Either<String, void>> resetPassword(String email);
  Future<Either<String, UserModel>> updateProfile(UserModel user);
}
