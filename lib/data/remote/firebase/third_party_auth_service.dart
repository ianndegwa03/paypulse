import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/data/models/response/auth_response.dart';
import 'dart:io' show Platform;

/// Third-Party Authentication Service for Google and Apple Sign-In
class ThirdPartyAuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  ThirdPartyAuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(message: 'Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(message: 'Google sign-in failed');
      }

      Map<String, dynamic> userData = {};
      try {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
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
        }
        userData = docSnapshot.data() ?? {};
      } catch (e) {
        // Silently continue if Firestore fails
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
      throw AuthException(message: e.message ?? 'Google sign-in failed');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Google sign-in failed: $e');
    }
  }

  /// Sign in with Apple
  Future<AuthResponse> signInWithApple() async {
    try {
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw const AuthException(
          message: 'Apple Sign-In is only available on iOS and macOS',
        );
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oAuthCredential);
      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(message: 'Apple sign-in failed');
      }

      Map<String, dynamic> userData = {};
      try {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
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
        }
        userData = docSnapshot.data() ?? {};
      } catch (e) {
        // Silently continue if Firestore fails
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
      throw AuthException(message: e.message ?? 'Apple sign-in failed');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Apple sign-in failed: $e');
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  Future<bool> isSignedInWithGoogle() async {
    return await _googleSignIn.isSignedIn();
  }
}
