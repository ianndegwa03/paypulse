import 'package:paypulse/core/logging/logger_service.dart';

class AutomationModule {
  Future<void> init() async {
    LoggerService.instance.d('Initializing AutomationModule...');
  }
}
