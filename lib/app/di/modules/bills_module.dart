import 'package:get_it/get_it.dart';
import 'package:paypulse/data/remote/datasources/bills_datasource.dart';
import 'package:paypulse/data/repositories/bills_repository_impl.dart';
import 'package:paypulse/domain/repositories/bills_repository.dart';
import 'package:paypulse/domain/use_cases/bills/get_bills_use_case.dart';

class BillsModule {
  Future<void> init() async {
    final getIt = GetIt.instance;

    // DataSource
    if (!getIt.isRegistered<BillsDataSource>()) {
      getIt.registerLazySingleton<BillsDataSource>(
        () => BillsDataSourceImpl(),
      );
    }

    // Repository
    if (!getIt.isRegistered<BillsRepository>()) {
      getIt.registerLazySingleton<BillsRepository>(
        () => BillsRepositoryImpl(getIt<BillsDataSource>()),
      );
    }

    // UseCases
    if (!getIt.isRegistered<GetBillsUseCase>()) {
      getIt.registerLazySingleton<GetBillsUseCase>(
        () => GetBillsUseCase(getIt<BillsRepository>()),
      );
    }
  }
}
