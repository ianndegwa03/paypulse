import 'package:get_it/get_it.dart';
import 'package:paypulse/data/remote/datasources/savings_datasource.dart';
import 'package:paypulse/data/repositories/savings_repository_impl.dart';
import 'package:paypulse/domain/repositories/savings_repository.dart';
import 'package:paypulse/domain/use_cases/savings/get_savings_goals_use_case.dart';

class SavingsModule {
  Future<void> init() async {
    final getIt = GetIt.instance;

    // DataSource
    if (!getIt.isRegistered<SavingsDataSource>()) {
      getIt.registerLazySingleton<SavingsDataSource>(
        () => SavingsDataSourceImpl(),
      );
    }

    // Repository
    if (!getIt.isRegistered<SavingsRepository>()) {
      getIt.registerLazySingleton<SavingsRepository>(
        () => SavingsRepositoryImpl(getIt<SavingsDataSource>()),
      );
    }

    // UseCases
    if (!getIt.isRegistered<GetSavingsGoalsUseCase>()) {
      getIt.registerLazySingleton<GetSavingsGoalsUseCase>(
        () => GetSavingsGoalsUseCase(getIt<SavingsRepository>()),
      );
    }
  }
}
