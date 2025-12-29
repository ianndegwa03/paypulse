import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/data/remote/mappers/user_mapper.dart';
import 'package:paypulse/data/repositories/user_repository_impl.dart';
import 'package:paypulse/domain/repositories/user_repository.dart';

class UserModule {
  Future<void> init() async {
    // Repositories
    if (!getIt.isRegistered<UserRepository>()) {
      getIt.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(
          getIt<FirebaseFirestore>(),
          getIt<UserMapper>(),
        ),
      );
    }

    LoggerService.instance.d('UserModule initialized', tag: 'DI');
  }
}
