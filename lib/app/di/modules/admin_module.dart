import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:paypulse/core/services/feature_flag_service.dart';
import 'package:paypulse/data/remote/datasources/admin_datasource.dart';
import 'package:paypulse/data/repositories/admin_repository_impl.dart';
import 'package:paypulse/domain/repositories/admin_repository.dart';
import 'package:paypulse/domain/use_cases/admin/get_admin_settings_use_case.dart';
import 'package:paypulse/domain/use_cases/admin/update_admin_settings_use_case.dart';
import 'package:paypulse/domain/use_cases/admin/get_system_stats_use_case.dart';
import 'package:paypulse/domain/use_cases/admin/get_recent_logs_use_case.dart';

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
        () => AdminDataSourceImpl(
          firestore: FirebaseFirestore.instance,
        ),
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

    if (!getIt.isRegistered<GetSystemStatsUseCase>()) {
      getIt.registerLazySingleton<GetSystemStatsUseCase>(
        () => GetSystemStatsUseCase(getIt<AdminRepository>()),
      );
    }

    if (!getIt.isRegistered<GetRecentLogsUseCase>()) {
      getIt.registerLazySingleton<GetRecentLogsUseCase>(
        () => GetRecentLogsUseCase(getIt<AdminRepository>()),
      );
    }
  }
}
