// lib/app/di/config/environment_config.dart
import 'package:injectable/injectable.dart';

const dev = Environment('dev');
const prod = Environment('prod');
const staging = Environment('staging');
const test = Environment('test');

// lib/app/di/config/di_config.dart
class DIConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.paypulse.dev',
  );
  
  static const bool enablePremiumFeatures = bool.fromEnvironment(
    'ENABLE_PREMIUM_FEATURES',
    defaultValue: false,
  );
  
  static const bool enableAiFeatures = bool.fromEnvironment(
    'ENABLE_AI_FEATURES', 
    defaultValue: true,
  );
}