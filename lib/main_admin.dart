import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paypulse/app/app.dart';
import 'package:paypulse/app/config/flavor_config.dart';
import 'package:paypulse/app/di/config/di_config.dart';
import 'package:paypulse/app/di/admin_injector.dart'; // Admin Injector
import 'package:paypulse/app/router/admin_router.dart'; // Admin Router
import 'package:paypulse/app/setup/bootstrapper.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (details) {
    LoggerService.instance.e(
      'Flutter Error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    LoggerService.instance
        .e('Platform Error: $error', error: error, stackTrace: stack);
    return true;
  };

  // 1. Common Bootstrap
  final bootstrapResult = await Bootstrapper.bootstrapCommon();

  // 2. Admin DI Initialization
  await AdminInjector.init(
    config: DIConfig(
      environment: bootstrapResult.environment,
      featureFlags: bootstrapResult.featureFlags,
      enableMockServices: bootstrapResult.flavor == AppFlavor.development,
    ),
  );

  // 3. Run Admin App
  runApp(PayPulseApp(
    routerConfig: AdminRouter.router,
  ));
}
