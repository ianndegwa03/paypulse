import 'package:get_it/get_it.dart';
import 'package:paypulse/data/remote/datasources/social_datasource.dart';
import 'package:paypulse/data/repositories/social_repository_impl.dart';
import 'package:paypulse/domain/repositories/social_repository.dart';
import 'package:paypulse/domain/use_cases/social/get_social_feed_use_case.dart';
import 'package:paypulse/core/services/local_storage/storage_service.dart';
import 'package:paypulse/core/services/encryption/encryption_service.dart';

class SocialModule {
  Future<void> init() async {
    final getIt = GetIt.instance;

    // EncryptionService for E2EE Chat
    if (!getIt.isRegistered<EncryptionService>()) {
      getIt.registerLazySingleton<EncryptionService>(
        () => EncryptionService(),
      );
    }

    // DataSource
    if (!getIt.isRegistered<SocialDataSource>()) {
      getIt.registerLazySingleton<SocialDataSource>(
        () => SocialDataSourceImpl(getIt<StorageService>()),
      );
    }

    // Repository
    if (!getIt.isRegistered<SocialRepository>()) {
      getIt.registerLazySingleton<SocialRepository>(
        () => SocialRepositoryImpl(getIt<SocialDataSource>()),
      );
    }

    // UseCases
    if (!getIt.isRegistered<GetSocialFeedUseCase>()) {
      getIt.registerLazySingleton<GetSocialFeedUseCase>(
        () => GetSocialFeedUseCase(getIt<SocialRepository>()),
      );
    }
  }
}
