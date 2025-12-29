import 'package:paypulse/core/base/base_state.dart';
import 'package:paypulse/domain/entities/user_entity.dart';

class AuthState extends BaseState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final UserEntity? currentUser;
  final bool isBiometricEnabled;
  final bool isPinEnabled;
  final String? pin;
  final bool isOnboardingComplete;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.currentUser,
    this.isBiometricEnabled = false,
    this.isPinEnabled = false,
    this.pin,
    this.isOnboardingComplete = false,
    super.isLoading,
    super.errorMessage,
    super.successMessage,
  });

  @override
  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    UserEntity? currentUser,
    bool? isBiometricEnabled,
    bool? isPinEnabled,
    String? pin,
    bool? isOnboardingComplete,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      currentUser: currentUser ?? this.currentUser,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      pin: pin ?? this.pin,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isAuthenticated,
        userId,
        email,
        currentUser,
        isBiometricEnabled,
        isPinEnabled,
        pin,
        isOnboardingComplete,
        ...super.props,
      ];
}
