import 'package:paypulse/core/errors/exceptions.dart';
import 'dart:io';
import 'package:paypulse/data/models/response/auth_response.dart';
import 'package:paypulse/data/remote/firebase/firebase_auth.dart';
import 'package:paypulse/data/remote/firebase/social_auth_service.dart';

abstract class AuthDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(
    String email,
    String password,
    String username,
    String firstName,
    String lastName,
  );
  Future<void> logout();
  Future<void> validateToken(String token);
  Future<void> forgotPassword(String email);
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? occupation,
    String? nationality,
  });
  Future<String> uploadProfileImage(File image);
  Future<void> resetPassword(String token, String newPassword);

  // Social login methods
  Future<AuthResponse> signInWithGoogle();
  Future<AuthResponse> signInWithApple();
}

class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuthService _firebaseAuth;
  final SocialAuthService _socialAuth;

  AuthDataSourceImpl(this._firebaseAuth, this._socialAuth);

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      return await _firebaseAuth.login(email, password);
    } catch (e) {
      if (e is AuthException) {
        throw ServerException(message: e.message);
      }
      throw ServerException(message: 'Login failed: $e');
    }
  }

  @override
  Future<AuthResponse> register(
    String email,
    String password,
    String username,
    String firstName,
    String lastName,
  ) async {
    try {
      return await _firebaseAuth.register(
        email: email,
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );
    } catch (e) {
      if (e is AuthException) {
        throw ServerException(message: e.message);
      }
      throw ServerException(message: 'Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.logout();
      // Also sign out from Google if signed in
      await _socialAuth.signOutGoogle();
    } catch (e) {
      if (e is AuthException) {
        throw ServerException(message: e.message);
      }
      throw ServerException(message: 'Logout failed: $e');
    }
  }

  @override
  Future<void> validateToken(String token) async {
    try {
      final isValid = await _firebaseAuth.validateToken(token);
      if (!isValid) {
        throw const AuthException(message: 'Invalid token');
      }
    } catch (e) {
      if (e is AuthException) {
        throw ServerException(message: e.message);
      }
      throw ServerException(message: 'Token validation failed: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.forgotPassword(email);
    } catch (e) {
      if (e is AuthException) {
        throw ServerException(message: e.message);
      }
      throw ServerException(message: 'Password reset failed: $e');
    }
  }

  @override
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? occupation,
    String? nationality,
  }) async {
    try {
      await _firebaseAuth.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        bio: bio,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
        occupation: occupation,
        nationality: nationality,
      );
    } catch (e) {
      if (e is AuthException) {
        throw ServerException(message: e.message);
      }
      throw ServerException(message: 'Profile update failed: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(File image) async {
    try {
      return await _firebaseAuth.uploadProfileImage(image);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    // Firebase handles password reset via email link
    // This method is not directly applicable to Firebase Auth
    throw UnimplementedError(
      'Password reset is handled via email link in Firebase Auth. Use forgotPassword instead.',
    );
  }

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      return await _socialAuth.signInWithGoogle();
    } catch (e) {
      if (e is AuthException) {
        throw ServerException(message: e.message);
      }
      throw ServerException(message: 'Google sign-in failed: $e');
    }
  }

  @override
  Future<AuthResponse> signInWithApple() async {
    try {
      return await _socialAuth.signInWithApple();
    } catch (e) {
      if (e is AuthException) {
        throw ServerException(message: e.message);
      }
      throw ServerException(message: 'Apple sign-in failed: $e');
    }
  }
}
