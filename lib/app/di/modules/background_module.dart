import 'package:paypulse/core/logging/logger_service.dart';

class BackgroundModule {
  Future<void> init() async {
    LoggerService.instance.d('Initializing BackgroundModule...');
  }
}
