import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/data/models/response/auth_response.dart';
import 'dart:io' show Platform;

/// Social Authentication Service for Google and Apple Sign-In
class SocialAuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  SocialAuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(message: 'Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(message: 'Google sign-in failed');
      }

      Map<String, dynamic> userData = {};
      try {
        // Store/update user info in Firestore
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          // New user - create profile
          final nameParts = (user.displayName ?? '').split(' ');
          final firstName = nameParts.isNotEmpty ? nameParts.first : '';
          final lastName =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          await userDoc.set({
            'userId': user.uid,
            'email': user.email ?? '',
            'firstName': firstName,
            'lastName': lastName,
            'photoUrl': user.photoURL,
            'provider': 'google',
            'emailVerified': user.emailVerified,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Existing user - update last login
          await userDoc.update({
            'updatedAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        }

        userData = docSnapshot.exists ? docSnapshot.data() ?? {} : {};
      } catch (e) {
        // Continue without firestore data
      }
      final idToken = await user.getIdToken();

      return AuthResponse(
        userId: user.uid,
        email: user.email ?? '',
        firstName: userData['firstName'] as String? ?? '',
        lastName: userData['lastName'] as String? ?? '',
        profileImageUrl: user.photoURL,
        accessToken: idToken,
        refreshToken: await user.getIdToken(true),
        expiresIn: 3600,
        isEmailVerified: user.emailVerified,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Google sign-in failed: $e');
    }
  }

  /// Sign in with Apple (iOS/macOS only)
  Future<AuthResponse> signInWithApple() async {
    try {
      // Check if platform supports Apple Sign In
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw const AuthException(
          message: 'Apple Sign-In is only available on iOS and macOS',
        );
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(oAuthCredential);
      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(message: 'Apple sign-in failed');
      }

      Map<String, dynamic> userData = {};
      try {
        // Store/update user info in Firestore
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          // New user - create profile
          final firstName = appleCredential.givenName ?? '';
          final lastName = appleCredential.familyName ?? '';

          await userDoc.set({
            'userId': user.uid,
            'email': user.email ?? appleCredential.email ?? '',
            'firstName': firstName,
            'lastName': lastName,
            'provider': 'apple',
            'emailVerified': user.emailVerified,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Existing user - update last login
          await userDoc.update({
            'updatedAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        }

        userData = docSnapshot.exists ? docSnapshot.data() ?? {} : {};
      } catch (e) {
        // Continue without firestore data
      }
      final idToken = await user.getIdToken();

      return AuthResponse(
        userId: user.uid,
        email: user.email ?? appleCredential.email ?? '',
        firstName: userData['firstName'] as String? ?? '',
        lastName: userData['lastName'] as String? ?? '',
        accessToken: idToken,
        refreshToken: await user.getIdToken(true),
        expiresIn: 3600,
        isEmailVerified: user.emailVerified,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getAuthErrorMessage(e.code));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthException(message: 'Apple sign-in was cancelled');
      }
      throw AuthException(message: 'Apple sign-in failed: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Apple sign-in failed: $e');
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore errors during Google sign out
    }
  }

  /// Check if signed in with Google
  Future<bool> isSignedInWithGoogle() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in method.';
      case 'invalid-credential':
        return 'The credential is invalid or has expired.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with these credentials.';
      case 'wrong-password':
        return 'Invalid credentials.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
