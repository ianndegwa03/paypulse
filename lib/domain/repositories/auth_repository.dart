import 'package:paypulse/domain/entities/user_entity.dart';

/// An interface for the authentication repository.
abstract class AuthRepository {
  /// Signs in a user with the given email and password.
  Future<User> signInWithEmailAndPassword(String email, String password);

  /// Signs up a user with the given email and password.
  Future<User> signUpWithEmailAndPassword(String email, String password);

  /// Signs in a user with Google.
  Future<User> signInWithGoogle();

  /// Signs in a user with Apple.
  Future<User> signInWithApple();

  /// Signs out the current user.
  Future<void> signOut();

  /// Gets the current user.
  Stream<User?> get user;
}
