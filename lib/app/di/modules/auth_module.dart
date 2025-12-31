import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/data/remote/firebase/firebase_auth.dart';
import 'package:paypulse/data/remote/firebase/third_party_auth_service.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';
import 'package:paypulse/domain/use_cases/auth/login_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/register_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/logout_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/forgot_password_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/google_signin_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/apple_signin_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/update_profile_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/biometric_login_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/enable_biometric_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/check_auth_status_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/get_current_user_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/pin_login_use_case.dart';
import 'package:paypulse/data/repositories/auth_repository_impl.dart';
import 'package:paypulse/data/remote/datasources/auth_datasource.dart';
import 'package:paypulse/data/local/datasources/local_datasource.dart';
import 'package:paypulse/core/network/connectivity/network_info.dart';
import 'package:paypulse/data/remote/mappers/user_mapper.dart';
import 'package:paypulse/core/services/biometric/biometric_service.dart';

/// Auth module for dependency injection
class AuthModule {
  Future<void> init() async {
    // Firebase Auth Service
    if (!getIt.isRegistered<FirebaseAuthService>()) {
      getIt.registerSingleton<FirebaseAuthService>(
        FirebaseAuthService(),
      );
    }

    // Third Party Auth Service (Google/Apple)
    if (!getIt.isRegistered<ThirdPartyAuthService>()) {
      getIt.registerSingleton<ThirdPartyAuthService>(
        ThirdPartyAuthService(),
      );
    }

    // Data Sources
    if (!getIt.isRegistered<AuthDataSource>()) {
      getIt.registerLazySingleton<AuthDataSource>(
        () => AuthDataSourceImpl(
          getIt<FirebaseAuthService>(),
          getIt<ThirdPartyAuthService>(),
        ),
      );
    }

    // Repositories
    if (!getIt.isRegistered<AuthRepository>()) {
      getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          remoteDataSource: getIt<AuthDataSource>(),
          localDataSource: getIt<LocalDataSource>(),
          networkInfo: getIt<NetworkInfo>(),
          userMapper: getIt<UserMapper>(),
        ),
      );
    }

    // Use Cases
    if (!getIt.isRegistered<LoginUseCase>()) {
      getIt.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(getIt<AuthRepository>()),
      );
    }
    if (!getIt.isRegistered<RegisterUseCase>()) {
      getIt.registerLazySingleton<RegisterUseCase>(
        () => RegisterUseCase(getIt<AuthRepository>()),
      );
    }
    if (!getIt.isRegistered<LogoutUseCase>()) {
      getIt.registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(getIt<AuthRepository>()),
      );
    }
    if (!getIt.isRegistered<ForgotPasswordUseCase>()) {
      getIt.registerLazySingleton<ForgotPasswordUseCase>(
        () => ForgotPasswordUseCase(getIt<AuthRepository>()),
      );
    }
    if (!getIt.isRegistered<GoogleSignInUseCase>()) {
      getIt.registerLazySingleton<GoogleSignInUseCase>(
        () => GoogleSignInUseCase(getIt<AuthRepository>()),
      );
    }
    if (!getIt.isRegistered<AppleSignInUseCase>()) {
      getIt.registerLazySingleton<AppleSignInUseCase>(
        () => AppleSignInUseCase(getIt<AuthRepository>()),
      );
    }
    if (!getIt.isRegistered<UpdateProfileUseCase>()) {
      getIt.registerLazySingleton<UpdateProfileUseCase>(
        () => UpdateProfileUseCase(getIt<AuthRepository>()),
      );
    }
    if (!getIt.isRegistered<BiometricLoginUseCase>()) {
      getIt.registerLazySingleton<BiometricLoginUseCase>(
        () => BiometricLoginUseCase(
          getIt<AuthRepository>(),
          getIt<BiometricService>(),
        ),
      );
    }
    if (!getIt.isRegistered<PinLoginUseCase>()) {
      getIt.registerLazySingleton<PinLoginUseCase>(
        () => PinLoginUseCase(getIt<AuthRepository>()),
      );
    }
    if (!getIt.isRegistered<EnableBiometricUseCase>()) {
      getIt.registerLazySingleton<EnableBiometricUseCase>(
        () => EnableBiometricUseCase(getIt<AuthRepository>()),
      );
    }
    if (!getIt.isRegistered<CheckAuthStatusUseCase>()) {
      getIt.registerLazySingleton<CheckAuthStatusUseCase>(
        () => CheckAuthStatusUseCase(getIt<AuthRepository>()),
      );
    }
    if (!getIt.isRegistered<GetCurrentUserUseCase>()) {
      getIt.registerLazySingleton<GetCurrentUserUseCase>(
        () => GetCurrentUserUseCase(getIt<AuthRepository>()),
      );
    }

    LoggerService.instance.d('AuthModule initialized', tag: 'DI');
  }
}
