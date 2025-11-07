import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/data/local/secure_storage_service.dart';
import 'package:paypulse/domain/entities/user_entity.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final SecureStorageService _secureStorageService;

  AuthRepositoryImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    SecureStorageService? secureStorageService,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _secureStorageService = secureStorageService ?? GetIt.instance<SecureStorageService>();

  @override
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
      );
    });
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user!;
      final idToken = await firebaseUser.getIdToken();
      await _secureStorageService.write('id_token', idToken!);
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _convertFirebaseError(e);
    } catch (e) {
      throw ServerException('An unexpected error occurred.');
    }
  }

  @override
  Future<User> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user!;
      final idToken = await firebaseUser.getIdToken();
      await _secureStorageService.write('id_token', idToken!);
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _convertFirebaseError(e);
    } catch (e) {
      throw ServerException('An unexpected error occurred.');
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw BadRequestException('Google sign in was cancelled.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;
      final idToken = await firebaseUser.getIdToken();
      await _secureStorageService.write('id_token', idToken!);
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _convertFirebaseError(e);
    } catch (e) {
      throw ServerException('An unexpected error occurred.');
    }
  }

  @override
  Future<User> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user!;
      final idToken = await firebaseUser.getIdToken();
      await _secureStorageService.write('id_token', idToken!);
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _convertFirebaseError(e);
    } catch (e) {
      throw ServerException('An unexpected error occurred.');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await _secureStorageService.delete('id_token');
  }

  Exception _convertFirebaseError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return BadRequestException('The email address is badly formatted.');
      case 'user-not-found':
        return NotFoundException('No user found for that email.');
      case 'wrong-password':
        return UnauthorizedException('Wrong password provided for that user.');
      case 'email-already-in-use':
        return BadRequestException('The email address is already in use by another account.');
      case 'weak-password':
        return BadRequestException('The password provided is too weak.');
      default:
        return ServerException('An unexpected error occurred.');
    }
  }
}
