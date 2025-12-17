import 'package:paypulse/app/config/app_config.dart';
import 'package:paypulse/app/config/environment/environment.dart';
import 'package:paypulse/app/config/environment/environment_loader.dart';
import 'package:paypulse/app/config/flavor_config.dart';
import 'package:paypulse/app/config/feature_flags.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/core/network/connectivity/connectivity_service.dart';
import 'package:paypulse/core/security/encryption/key_manager.dart';

class Bootstrapper {
  /// Bootstraps command services (Config, Logging, Connectivity)
  /// Returns the environment and flags needed for DI configuration
  static Future<BootstrapResult> bootstrapCommon() async {
    try {
      // 1. Load environment configuration
      final environment = await EnvironmentLoader.loadEnvironment();

      // 2. Determine app flavor
      final flavor = FlavorConfig.determineFlavor();

      // 3. Load feature flags
      final featureFlags = await FeatureFlags.defaultFlags();

      // 4. Initialize app configuration
      AppConfig.initialize(
        env: environment,
        flav: flavor,
        flags: featureFlags,
      );

      // 5. Initialize logging
      await LoggerService.instance.initialize(
        enableFileLogging: AppConfig.enableLogging,
        enableCrashlytics: AppConfig.enableCrashlytics,
      );

      // 6. Initialize encryption keys
      await KeyManager.instance.initialize();

      // 7. Initialize connectivity service
      await ConnectivityService.instance.initialize();

      LoggerService.instance.i('Common bootstrap completed successfully');

      return BootstrapResult(
        environment: environment,
        flavor: flavor,
        featureFlags: featureFlags,
      );
    } catch (e, stackTrace) {
      LoggerService.instance
          .e('Bootstrap failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

class BootstrapResult {
  final Environment environment;
  final AppFlavor flavor;
  final FeatureFlags featureFlags;

  BootstrapResult({
    required this.environment,
    required this.flavor,
    required this.featureFlags,
  });
}
