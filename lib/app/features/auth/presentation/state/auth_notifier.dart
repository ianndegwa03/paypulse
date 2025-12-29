import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_state.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/services/biometric/biometric_service.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/use_cases/auth/login_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/register_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/forgot_password_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/logout_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/google_signin_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/apple_signin_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/update_profile_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/enable_biometric_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/check_auth_status_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/get_current_user_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/biometric_login_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/pin_login_use_case.dart';
import 'package:paypulse/domain/value_objects/phone_number.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final LogoutUseCase logoutUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final AppleSignInUseCase appleSignInUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final EnableBiometricUseCase enableBiometricUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final BiometricLoginUseCase biometricLoginUseCase;
  final PinLoginUseCase pinLoginUseCase;
  final BiometricService biometricService;
  final _logger = LoggerService.instance;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.forgotPasswordUseCase,
    required this.googleSignInUseCase,
    required this.appleSignInUseCase,
    required this.updateProfileUseCase,
    required this.enableBiometricUseCase,
    required this.checkAuthStatusUseCase,
    required this.getCurrentUserUseCase,
    required this.biometricLoginUseCase,
    required this.pinLoginUseCase,
    required this.biometricService,
  }) : super(const AuthState()) {
    checkAuthStatus();
    checkBiometricStatus();
    checkPinStatus();
  }

  bool _biometricPrompted = false;

  Future<void> checkBiometricStatus() async {
    try {
      final isAvailable =
          await biometricLoginUseCase.repository.isBiometricEnabled();
      isAvailable.fold(
        (_) => state = state.copyWith(isBiometricEnabled: false),
        (enabled) => state = state.copyWith(isBiometricEnabled: enabled),
      );
    } catch (e) {
      _logger.e('Error checking biometric status: $e', tag: 'AuthNotifier');
    }
  }

  Future<void> checkPinStatus() async {
    try {
      final isAvailable = await biometricLoginUseCase.repository.isPinEnabled();
      isAvailable.fold(
        (_) => state = state.copyWith(isPinEnabled: false),
        (enabled) => state = state.copyWith(isPinEnabled: enabled),
      );
    } catch (e) {
      _logger.e('Error checking PIN status: $e', tag: 'AuthNotifier');
    }
  }

  Future<void> checkAuthStatus() async {
    // Check if user is already logged in
    final result = await checkAuthStatusUseCase.execute();

    result.fold((failure) {
      // Not authenticated or error
    }, (isAuthenticated) async {
      if (isAuthenticated) {
        _logger.d('User is authenticated, fetching details...',
            tag: 'AuthNotifier');
        final userResult = await getCurrentUserUseCase.execute();
        userResult.fold(
            (f) => _logger.e('Failed to fetch current user: ${f.message}',
                tag: 'AuthNotifier'), (user) async {
          state = state.copyWith(
              isAuthenticated: true,
              currentUser: user,
              userId: user.id,
              email: user.email.value,
              isLoading: false);

          // Trigger biometric prompt only if enabled and not yet prompted this session
          if (user.securitySettings['biometric_enabled'] == true &&
              !_biometricPrompted) {
            _biometricPrompted = true; // Set flag immediately
            // We can trigger a biometric verify use case here or UI can react to this
            // For now, assuming the UI reacts to 'isAuthenticated' and handles prompt,
            // but if the prompt is logic-driven here:
            // await _triggerBiometricVerify();
          }
        });
      }
    });
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await loginUseCase.execute(email, password);

      result.fold(
        (failure) {
          _logger.e('Login failed: ${failure.message}', tag: 'AuthNotifier');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (user) async {
          _logger.i('User logged in successfully: ${user.id}',
              tag: 'AuthNotifier');

          // If biometric is enabled, save these credentials
          if (state.isBiometricEnabled) {
            try {
              final creds = json.encode({'email': email, 'password': password});
              await biometricService.saveBiometricCredentials('default', creds);
            } catch (e) {
              _logger.e('Failed to save biometric credentials: $e',
                  tag: 'AuthNotifier');
            }
          }

          state = state.copyWith(
            isAuthenticated: true,
            userId: user.id,
            email: user.email.value,
            currentUser: user,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during login: $e', tag: 'AuthNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await googleSignInUseCase.execute();

      result.fold(
        (failure) {
          _logger.e('Google Sign-In failed: ${failure.message}',
              tag: 'AuthNotifier');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (user) {
          _logger.i('User signed in with Google: ${user.id}',
              tag: 'AuthNotifier');
          state = state.copyWith(
            isAuthenticated: true,
            userId: user.id,
            email: user.email.value,
            currentUser: user,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during Google Sign-In: $e',
          tag: 'AuthNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await appleSignInUseCase.execute();

      result.fold(
        (failure) {
          _logger.e('Apple Sign-In failed: ${failure.message}',
              tag: 'AuthNotifier');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (user) {
          _logger.i('User signed in with Apple: ${user.id}',
              tag: 'AuthNotifier');
          state = state.copyWith(
            isAuthenticated: true,
            userId: user.id,
            email: user.email.value,
            currentUser: user,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during Apple Sign-In: $e',
          tag: 'AuthNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register(
    String email,
    String password,
    String username,
    String firstName,
    String lastName,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await registerUseCase.execute(
        email: email,
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );

      result.fold(
        (failure) {
          _logger.e('Registration failed: ${failure.message}',
              tag: 'AuthNotifier');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (user) {
          _logger.i('User registered successfully: ${user.id}',
              tag: 'AuthNotifier');
          state = state.copyWith(
            isAuthenticated: true,
            userId: user.id,
            email: user.email.value,
            currentUser: user,
            isLoading: false,
            successMessage:
                'Registration successful! Please check your email for verification.',
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during registration: $e',
          tag: 'AuthNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await logoutUseCase.execute();

      result.fold(
        (failure) {
          _logger.e('Logout failed: ${failure.message}', tag: 'AuthNotifier');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (_) {
          _logger.i('User logged out successfully', tag: 'AuthNotifier');
          state = AuthState(
            isAuthenticated: false,
            isLoading: false,
            isBiometricEnabled: state.isBiometricEnabled,
            isOnboardingComplete: state.isOnboardingComplete,
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during logout: $e', tag: 'AuthNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await forgotPasswordUseCase.execute(email);

      result.fold((failure) {
        _logger.e('Forgot password failed: ${failure.message}',
            tag: 'AuthNotifier');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      }, (_) {
        _logger.i('Forgot password request succeeded', tag: 'AuthNotifier');
        state = state.copyWith(
            isLoading: false,
            successMessage:
                'If the email exists, reset instructions were sent.');
      });
    } catch (e) {
      _logger.e('Unexpected error during forgot password: $e',
          tag: 'AuthNotifier');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
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
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final currentUser = state.currentUser;
    if (currentUser == null) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'No user is logged in.');
      return;
    }

    PhoneNumber? newPhone = currentUser.phoneNumber;
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final phoneResult = PhoneNumber.create(phoneNumber);
      final failureOrPhone = phoneResult.fold<dynamic>((f) => f, (p) => p);
      if (failureOrPhone is Failure) {
        state = state.copyWith(
            isLoading: false, errorMessage: failureOrPhone.message);
        return;
      }
      newPhone = failureOrPhone;
    }

    final updatedUser = currentUser.copyWith(
      firstName: firstName ?? currentUser.firstName,
      lastName: lastName ?? currentUser.lastName,
      username: username ?? currentUser.username,
      phoneNumber: newPhone,
      bio: bio ?? currentUser.bio,
      dateOfBirth: dateOfBirth ?? currentUser.dateOfBirth,
      gender: gender ?? currentUser.gender,
      address: address ?? currentUser.address,
      occupation: occupation ?? currentUser.occupation,
      nationality: nationality ?? currentUser.nationality,
      privacyLevel: privacyLevel ?? currentUser.privacyLevel,
      stealthModeEnabled: stealthModeEnabled ?? currentUser.stealthModeEnabled,
      isProfessionalProfileVisible: isProfessionalProfileVisible ??
          currentUser.isProfessionalProfileVisible,
      professionalBio: professionalBio ?? currentUser.professionalBio,
    );

    try {
      final result = await updateProfileUseCase.execute(updatedUser);

      result.fold(
        (failure) {
          _logger.e('Update profile failed: ${failure.message}',
              tag: 'AuthNotifier');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (_) {
          _logger.i('Profile updated successfully', tag: 'AuthNotifier');
          state = state.copyWith(
            isLoading: false,
            currentUser: updatedUser,
            successMessage: 'Profile updated successfully.',
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during profile update: $e',
          tag: 'AuthNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> uploadProfileImage(File image) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result =
          await biometricLoginUseCase.repository.uploadProfileImage(image);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (imageUrl) {
          if (state.currentUser != null) {
            state = state.copyWith(
              isLoading: false,
              currentUser:
                  state.currentUser!.copyWith(profileImageUrl: imageUrl),
              successMessage: 'Photo updated successfully',
            );
          } else {
            state = state.copyWith(isLoading: false);
          }
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loginWithBiometrics() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await biometricLoginUseCase.execute();

      result.fold(
        (failure) {
          _logger.e('Biometric login failed: ${failure.message}',
              tag: 'AuthNotifier');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (user) {
          _logger.i('User logged in via biometrics: ${user.id}',
              tag: 'AuthNotifier');
          state = state.copyWith(
            isAuthenticated: true,
            userId: user.id,
            email: user.email.value,
            currentUser: user,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during biometric login: $e',
          tag: 'AuthNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loginWithPin(String pin) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await pinLoginUseCase.execute(pin);

      result.fold(
        (failure) {
          _logger.e('PIN login failed: ${failure.message}',
              tag: 'AuthNotifier');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (user) {
          _logger.i('User logged in via PIN: ${user.id}', tag: 'AuthNotifier');
          state = state.copyWith(
            isAuthenticated: true,
            userId: user.id,
            email: user.email.value,
            currentUser: user,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during PIN login: $e', tag: 'AuthNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> enableBiometric(bool enable) async {
    final currentUser = state.currentUser;
    if (currentUser == null) return;

    try {
      final result = await enableBiometricUseCase.execute(enable);

      result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
        },
        (_) {
          final newSettings =
              Map<String, dynamic>.from(currentUser.securitySettings);
          newSettings['biometric_enabled'] = enable;
          final updatedUser =
              currentUser.copyWith(securitySettings: newSettings);
          state = state.copyWith(
            currentUser: updatedUser,
            isBiometricEnabled: enable,
          );
          _logger.i('Biometric ${enable ? 'enabled' : 'disabled'}',
              tag: 'AuthNotifier');
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> enablePin(bool enable, String? pin) async {
    try {
      final result =
          await biometricLoginUseCase.repository.enablePin(enable, pin);

      result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
        },
        (_) {
          state = state.copyWith(isPinEnabled: enable, pin: pin);
          _logger.i('PIN ${enable ? 'enabled' : 'disabled'}',
              tag: 'AuthNotifier');
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> unlockFeature(String featureKey) async {
    // This is a simplified local implementation. In a real app, this would verify a purchase on the backend.
    final currentUser = state.currentUser;
    if (currentUser == null) return;

    final currentFeatures = currentUser.unlockedFeatures;
    if (currentFeatures.contains(featureKey)) return;

    final updatedFeatures = List<String>.from(currentFeatures)..add(featureKey);
    final updatedUser = currentUser.copyWith(unlockedFeatures: updatedFeatures);

    state = state.copyWith(currentUser: updatedUser);

    // Ideally, we should also call updateProfileUseCase to persist this to the backend/storage
    // For now, it will persist in memory for the session or if updateProfileUseCase supports it
    // await updateProfileUseCase.execute(updatedUser);
  }
}

// Riverpod Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: getIt<LoginUseCase>(),
    registerUseCase: getIt<RegisterUseCase>(),
    logoutUseCase: getIt<LogoutUseCase>(),
    forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
    googleSignInUseCase: getIt<GoogleSignInUseCase>(),
    appleSignInUseCase: getIt<AppleSignInUseCase>(),
    updateProfileUseCase: getIt<UpdateProfileUseCase>(),
    enableBiometricUseCase: getIt<EnableBiometricUseCase>(),
    checkAuthStatusUseCase: getIt<CheckAuthStatusUseCase>(),
    getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    biometricLoginUseCase: getIt<BiometricLoginUseCase>(),
    pinLoginUseCase: getIt<PinLoginUseCase>(),
    biometricService: getIt<BiometricService>(),
  );
});
