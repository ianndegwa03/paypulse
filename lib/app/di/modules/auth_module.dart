import 'package:get_it/get_it.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/data/remote/api/interfaces/auth_api_interface.dart';
import 'package:paypulse/data/remote/api/implementations/auth_api_impl.dart';
import 'package:paypulse/core/network/api/dio_client.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';
import 'package:paypulse/domain/use_cases/auth/login_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/register_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/logout_use_case.dart';
import 'package:paypulse/domain/use_cases/auth/forgot_password_use_case.dart';
import 'package:paypulse/data/repositories/auth_repository_impl.dart';
import 'package:paypulse/data/remote/datasources/auth_datasource.dart';
import 'package:paypulse/data/local/datasources/local_datasource.dart';
import 'package:paypulse/core/network/connectivity/network_info.dart';
import 'package:paypulse/data/remote/mappers/user_mapper.dart';

/// Auth module for dependency injection
class AuthModule {
  Future<void> init() async {
    // API
    if (!getIt.isRegistered<AuthApiInterface>()) {
      final dioClient = getIt<DioClient>();
      getIt.registerSingleton<AuthApiInterface>(
        AuthApiImpl(dioClient.instance),
      );
    }
    // Data Sources
    if (!getIt.isRegistered<AuthDataSource>()) {
      getIt.registerLazySingleton<AuthDataSource>(
        () => AuthDataSourceImpl(getIt<AuthApiInterface>()),
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

    LoggerService.instance.d('AuthModule initialized', tag: 'DI');
  }
}
