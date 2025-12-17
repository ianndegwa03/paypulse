import 'package:paypulse/core/logging/logger_service.dart';

class AnalyticsModule {
  Future<void> init() async {
    LoggerService.instance.d('Initializing AnalyticsModule...');
  }
}
