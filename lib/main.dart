import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PayPulseApp());
}


// lib/main.dart
import 'package:flutter/material.dart';
import 'package:paypulse/app/app.dart';
import 'package:paypulse/app/di/service_locator.dart';
import 'package:paypulse/app/di/setup/di_setup.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup error handling
  await setupErrorHandling();
  
  // Initialize dependency injection
  await setupDependencies(environment: Environment.dev);
  
  // Register services
  ServiceLocator.init();
  
  // Run the app
  runApp(const PayPulseApp());
}

Future<void> setupErrorHandling() async {
  // Setup Flutter error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Log to analytics
    ServiceLocator.analyticsService.recordError(details.exception, details.stack);
  };
  
  // Setup platform error handling
  PlatformDispatcher.instance.onError = (error, stack) {
    ServiceLocator.analyticsService.recordError(error, stack);
    return true;
  };
}