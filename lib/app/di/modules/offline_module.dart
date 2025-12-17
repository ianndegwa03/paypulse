import 'package:paypulse/core/logging/logger_service.dart';

class OfflineModule {
  Future<void> init() async {
    LoggerService.instance.d('Initializing OfflineModule...');

    // Register offline capability services here
    // Example: getIt.registerLazySingleton<OfflineSyncService>(() => ...);
  }
}
