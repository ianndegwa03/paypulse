import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paypulse/app/app.dart';
import 'package:paypulse/app/config/flavor_config.dart';
import 'package:paypulse/app/di/config/di_config.dart';
import 'package:paypulse/app/di/user_injector.dart'; // Standard User Injector only
import 'package:paypulse/app/router/user_router.dart'; // Standard User Router only
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

  // 1. Common Bootstrap (Config, Logging, etc.)
  final bootstrapResult = await Bootstrapper.bootstrapCommon();

  // 2. Strict DI Initialization (User Modules ONLY)
  await UserInjector.init(
    config: DIConfig(
      environment: bootstrapResult.environment,
      featureFlags: bootstrapResult.featureFlags,
      enableMockServices: bootstrapResult.flavor == AppFlavor.development,
    ),
  );

  // 3. Run User App
  runApp(PayPulseApp(
    routerConfig: UserRouter.router,
  ));
}
