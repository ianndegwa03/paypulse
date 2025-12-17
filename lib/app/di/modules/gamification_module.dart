import 'package:get_it/get_it.dart';
import 'package:paypulse/data/remote/datasources/gamification_datasource.dart';
import 'package:paypulse/data/repositories/gamification_repository_impl.dart';
import 'package:paypulse/domain/repositories/gamification_repository.dart';
import 'package:paypulse/domain/use_cases/gamification/get_gamification_profile_use_case.dart';

class GamificationModule {
  Future<void> init() async {
    final getIt = GetIt.instance;

    // DataSource
    if (!getIt.isRegistered<GamificationDataSource>()) {
      getIt.registerLazySingleton<GamificationDataSource>(
        () => GamificationDataSourceImpl(),
      );
    }

    // Repository
    if (!getIt.isRegistered<GamificationRepository>()) {
      getIt.registerLazySingleton<GamificationRepository>(
        () => GamificationRepositoryImpl(getIt<GamificationDataSource>()),
      );
    }

    // UseCases
    if (!getIt.isRegistered<GetGamificationProfileUseCase>()) {
      getIt.registerLazySingleton<GetGamificationProfileUseCase>(
        () => GetGamificationProfileUseCase(getIt<GamificationRepository>()),
      );
    }
  }
}
