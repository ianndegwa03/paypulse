import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/domain/use_cases/auth/login_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/register_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/forgot_password_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/logout_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/google_signin_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/apple_signin_use_case.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final LogoutUseCase logoutUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final AppleSignInUseCase appleSignInUseCase;
  final _logger = LoggerService.instance;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.forgotPasswordUseCase,
    required this.googleSignInUseCase,
    required this.appleSignInUseCase,
  }) : super(const AuthState());

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
        (user) {
          _logger.i('User logged in successfully: ${user.id}',
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
    String firstName,
    String lastName,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await registerUseCase.execute(
        email: email,
        password: password,
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
          state = const AuthState(
            isAuthenticated: false,
            isLoading: false,
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
  );
});
