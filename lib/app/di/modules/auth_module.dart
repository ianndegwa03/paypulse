// lib/app/di/modules/auth_module.dart
import 'package:injectable/injectable.dart';
import 'package:paypulse/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:paypulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:paypulse/features/auth/domain/use_cases/login_use_case.dart';
import 'package:paypulse/features/auth/domain/use_cases/register_use_case.dart';
import 'package:paypulse/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:paypulse/features/auth/domain/use_cases/biometric_login_use_case.dart';
import 'package:paypulse/features/auth/presentation/bloc/auth_bloc.dart';

@module
abstract class AuthModule {
  
  // Data Sources
  @singleton
  AuthRemoteDataSource get authRemoteDataSource => AuthRemoteDataSource();
  
  @singleton
  AuthLocalDataSource get authLocalDataSource => AuthLocalDataSource();
  
  // Repository
  @singleton
  AuthRepository get authRepository => AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );
  
  // Use Cases
  @singleton
  LoginUseCase get loginUseCase => LoginUseCase(authRepository);
  
  @singleton
  RegisterUseCase get registerUseCase => RegisterUseCase(authRepository);
  
  @singleton
  LogoutUseCase get logoutUseCase => LogoutUseCase(authRepository);
  
  @singleton
  BiometricLoginUseCase get biometricLoginUseCase => BiometricLoginUseCase(authRepository);
  
  // BLoCs
  @singleton
  AuthBloc get authBloc => AuthBloc(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
    biometricLoginUseCase: biometricLoginUseCase,
  );
}