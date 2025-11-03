// lib/app/di/setup/di_setup.dart
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/app/di/modules/core_module.dart';
import 'package:paypulse/app/di/modules/network_module.dart';
import 'package:paypulse/app/di/modules/auth_module.dart';
import 'package:paypulse/app/di/modules/wallet_module.dart';
import 'package:paypulse/app/di/modules/ai_module.dart';
import 'package:paypulse/app/di/modules/security_module.dart';

@injectableInit
void setupDependencies({String environment = Environment.dev}) {
  // Register all modules
  configureDependencies();
  
  // Initialize async dependencies
  _initializeAsyncDependencies();
}

Future<void> _initializeAsyncDependencies() async {
  final storage = getIt<StorageService>();
  await storage.init();
  
  final mlKitService = getIt<MlKitService>();
  await mlKitService.init();
  
  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();
}