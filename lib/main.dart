import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/app.dart';
import 'package:paypulse/app/di/modules/auth_module.dart';
import 'package:paypulse/app/di/modules/firestore_module.dart';
import 'package:paypulse/app/di/modules/network_module.dart';
import 'package:paypulse/app/di/modules/repository_module.dart';
import 'package:paypulse/app/di/modules/secure_storage_service_module.dart';
import 'package:paypulse/app/di/modules/storage_module.dart';
import 'package:paypulse/app/di/modules/storage_service_module.dart';
import 'package:paypulse/firebase_options.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependency injection modules
  registerFirestoreModule();
  registerNetworkModule();
  await registerStorageModule();
  registerStorageServiceModule();
  registerSecureStorageServiceModule();
  registerAuthModule();
  registerRepositoryModule();

  // Run the app
  runApp(const ProviderScope(child: PayPulseApp()));
}
