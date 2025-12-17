import 'package:get_it/get_it.dart';
import 'package:paypulse/app/config/app_config.dart';
import 'package:paypulse/app/config/environment/environment.dart';
import 'package:paypulse/core/logging/logger_service.dart';

/// Module for providing environment configuration
class EnvironmentConfigModule {
  Future<void> init() async {
    final getIt = GetIt.instance;
    // Environment
    if (!getIt.isRegistered<Environment>()) {
      getIt.registerSingleton<Environment>(AppConfig.environment);
    }

    LoggerService.instance.d('EnvironmentConfigModule initialized', tag: 'DI');
  }
}
