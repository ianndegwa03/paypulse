import 'package:get_it/get_it.dart';
import 'package:paypulse/data/remote/datasources/investment_datasource.dart';
import 'package:paypulse/domain/repositories/investment_repository.dart';
import 'package:paypulse/data/repositories/investment_repository_impl.dart';
import 'package:paypulse/domain/use_cases/investment/get_investments_use_case.dart';

class InvestmentModule {
  Future<void> init() async {
    final getIt = GetIt.instance;

    // DataSource
    if (!getIt.isRegistered<InvestmentDataSource>()) {
      getIt.registerLazySingleton<InvestmentDataSource>(
        () => InvestmentDataSourceImpl(),
      );
    }

    // Repository
    if (!getIt.isRegistered<InvestmentRepository>()) {
      getIt.registerLazySingleton<InvestmentRepository>(
        () => InvestmentRepositoryImpl(getIt<InvestmentDataSource>()),
      );
    }

    // UseCases
    if (!getIt.isRegistered<GetInvestmentsUseCase>()) {
      getIt.registerLazySingleton<GetInvestmentsUseCase>(
        () => GetInvestmentsUseCase(getIt<InvestmentRepository>()),
      );
    }
  }
}
