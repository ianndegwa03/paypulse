// lib/app/di/modules/core_module.dart
import 'package:injectable/injectable.dart';
import 'package:paypulse/core/network/network_info.dart';
import 'package:paypulse/core/services/local_storage/storage_service.dart';
import 'package:paypulse/core/services/local_storage/hive_storage.dart';
import 'package:paypulse/core/services/local_storage/secure_storage.dart';
import 'package:paypulse/core/services/notification/notification_service.dart';
import 'package:paypulse/core/utils/logger.dart';
import 'package:paypulse/core/theme/theme_controller.dart';
import 'package:paypulse/core/analytics/analytics_service.dart';

@module
abstract class CoreModule {
  
  @singleton
  @preResolve
  Future<StorageService> get storageService => HiveStorage.init();
  
  @singleton
  SecureStorage get secureStorage => SecureStorage();
  
  @singleton
  NetworkInfo get networkInfo => NetworkInfo();
  
  @singleton
  NotificationService get notificationService => NotificationService();
  
  @singleton
  Logger get logger => Logger();
  
  @singleton
  ThemeController get themeController => ThemeController();
  
  @singleton
  AnalyticsService get analyticsService => AnalyticsService();
}