import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/domain/use_cases/auth/login_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/register_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/logout_use_case.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final _logger = LoggerService.instance;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
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
            successMessage: 'Registration successful!',
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
}

// Riverpod Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: getIt<LoginUseCase>(),
    registerUseCase: getIt<RegisterUseCase>(),
    logoutUseCase: getIt<LogoutUseCase>(),
  );
});
