import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/data/models/response/auth_response.dart';

/// Firebase Authentication Service
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Login with email and password
  Future<AuthResponse> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException(message: 'User not found after login');
      }

      // Get additional user data from Firestore
      Map<String, dynamic> userData = {};
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        userData = userDoc.data() ?? {};
      } catch (e) {
        // proceed with empty user data if firestore fails
      }

      // Get ID token for API authentication
      final idToken = await user.getIdToken();

      return AuthResponse(
        userId: user.uid,
        email: user.email ?? email,
        firstName: userData['firstName'] as String? ?? '',
        lastName: userData['lastName'] as String? ?? '',
        phoneNumber: userData['phoneNumber'] as String?,
        bio: userData['bio'] as String?,
        dateOfBirth: userData['dateOfBirth'] != null
            ? DateTime.parse(userData['dateOfBirth'] as String)
            : null,
        gender: userData['gender'] as String?,
        address: userData['address'] as String?,
        occupation: userData['occupation'] as String?,
        nationality: userData['nationality'] as String?,
        privacyLevel: userData['privacyLevel'] as String?,
        stealthModeEnabled: userData['stealthModeEnabled'] as bool?,
        isProfessionalProfileVisible:
            userData['isProfessionalProfileVisible'] as bool?,
        professionalBio: userData['professionalBio'] as String?,
        accessToken: idToken,
        refreshToken: await user.getIdToken(true),
        expiresIn: 3600,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      throw AuthException(message: 'Login failed: $e');
    }
  }

  /// Register a new user with email and password
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException(message: 'User creation failed');
      }

      // Update display name
      await user.updateDisplayName('$firstName $lastName');

      // Send email verification
      try {
        await user.sendEmailVerification();
      } catch (e) {
        // Don't fail registration if email verification fails
        // User can resend later
      }

      // Store additional user info in Firestore
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'email': email,
          'username': username,
          'firstName': firstName,
          'lastName': lastName,
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 10));
      } catch (e) {
        // Log the error but allow registration to complete if auth succeeded
        print('Firestore user creation failed or timed out: $e');
      }

      // Get ID token for API authentication
      final idToken = await user
          .getIdToken()
          .timeout(const Duration(seconds: 10))
          .catchError((e) => '');

      return AuthResponse(
        userId: user.uid,
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
        accessToken: idToken,
        refreshToken: await user
            .getIdToken(true)
            .timeout(const Duration(seconds: 10))
            .catchError((e) => ''),
        expiresIn: 3600,
        isEmailVerified: false,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      throw AuthException(message: 'Registration failed: $e');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  /// Upload profile image to Firebase Storage
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No user logged in');
      }

      final storageRef =
          _storage.ref().child('profiles/${user.uid}/avatar.jpg');
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      // Update user document in Firestore with new photo URL
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth user profile
      await user.updatePhotoURL(downloadUrl);

      return downloadUrl;
    } catch (e) {
      throw AuthException(message: 'Failed to upload image: $e');
    }
  }

  /// Send password reset email
  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
      );
    } catch (e) {
      throw AuthException(message: 'Password reset failed: $e');
    }
  }

  /// Validate token (check if user is authenticated)
  Future<bool> validateToken(String token) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      final idToken = await user.getIdToken();
      return idToken == token;
    } catch (e) {
      return false;
    }
  }

  /// Update user profile
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
    String? privacyLevel,
    bool? stealthModeEnabled,
    bool? isProfessionalProfileVisible,
    String? professionalBio,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No user logged in');
      }

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (bio != null) updates['bio'] = bio;
      if (dateOfBirth != null)
        updates['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (gender != null) updates['gender'] = gender;
      if (address != null) updates['address'] = address;
      if (occupation != null) updates['occupation'] = occupation;
      if (nationality != null) updates['nationality'] = nationality;
      if (privacyLevel != null) updates['privacyLevel'] = privacyLevel;
      if (stealthModeEnabled != null)
        updates['stealthModeEnabled'] = stealthModeEnabled;
      if (isProfessionalProfileVisible != null)
        updates['isProfessionalProfileVisible'] = isProfessionalProfileVisible;
      if (professionalBio != null) updates['professionalBio'] = professionalBio;

      if (firstName != null || lastName != null) {
        final displayName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
        await user.updateDisplayName(displayName);
      }

      await _firestore.collection('users').doc(user.uid).update(updates);
    } catch (e) {
      throw AuthException(message: 'Profile update failed: $e');
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'No user logged in');
      }

      if (user.emailVerified) {
        throw const AuthException(message: 'Email is already verified');
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException(message: 'Failed to send verification email: $e');
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // Reload user to get latest verification status
      await user.reload();
      final refreshedUser = _firebaseAuth.currentUser;
      return refreshedUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    await sendEmailVerification();
  }

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Convert Firebase error codes to user-friendly messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
