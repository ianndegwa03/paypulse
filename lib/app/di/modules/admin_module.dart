import 'package:get_it/get_it.dart';
import 'package:paypulse/core/services/feature_flag_service.dart';
import 'package:paypulse/data/remote/datasources/admin_datasource.dart';
import 'package:paypulse/data/repositories/admin_repository_impl.dart';
import 'package:paypulse/domain/repositories/admin_repository.dart';
import 'package:paypulse/domain/use_cases/admin/get_admin_settings_use_case.dart';
import 'package:paypulse/domain/use_cases/admin/update_admin_settings_use_case.dart';

class AdminModule {
  Future<void> init() async {
    final getIt = GetIt.instance;

    // Services
    if (!getIt.isRegistered<FeatureFlagService>()) {
      getIt.registerLazySingleton<FeatureFlagService>(
        () => FeatureFlagService(),
      );
    }

    // DataSource
    if (!getIt.isRegistered<AdminDataSource>()) {
      getIt.registerLazySingleton<AdminDataSource>(
        () => AdminDataSourceImpl(),
      );
    }

    // Repository
    if (!getIt.isRegistered<AdminRepository>()) {
      getIt.registerLazySingleton<AdminRepository>(
        () => AdminRepositoryImpl(
          dataSource: getIt<AdminDataSource>(),
          featureFlagService: getIt<FeatureFlagService>(),
        ),
      );
    }

    // UseCases
    if (!getIt.isRegistered<GetAdminSettingsUseCase>()) {
      getIt.registerLazySingleton<GetAdminSettingsUseCase>(
        () => GetAdminSettingsUseCase(getIt<AdminRepository>()),
      );
    }

    if (!getIt.isRegistered<UpdateAdminSettingsUseCase>()) {
      getIt.registerLazySingleton<UpdateAdminSettingsUseCase>(
        () => UpdateAdminSettingsUseCase(getIt<AdminRepository>()),
      );
    }
  }
}
