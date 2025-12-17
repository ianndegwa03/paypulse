import 'package:paypulse/app/config/environment/environment.dart';
import 'package:paypulse/app/config/flavor_config.dart';
import 'package:paypulse/app/config/feature_flags.dart';

abstract class AppConfig {
  static late Environment environment;
  static late AppFlavor flavor;
  static late FeatureFlags featureFlags;
  
  static void initialize({
    required Environment env,
    required AppFlavor flav,
    required FeatureFlags flags,
  }) {
    environment = env;
    flavor = flav;
    featureFlags = flags;
  }
  
  static bool get isDevelopment => flavor == AppFlavor.development;
  static bool get isStaging => flavor == AppFlavor.staging;
  static bool get isProduction => flavor == AppFlavor.production;
  
  static String get apiBaseUrl => environment.apiBaseUrl;
  static String get appName => environment.appName;
  static bool get enableLogging => environment.enableLogging;
  static bool get enableCrashlytics => environment.enableCrashlytics;
  static bool get enableAnalytics => environment.enableAnalytics;
  
  static bool isFeatureEnabled(Feature feature) {
    return featureFlags.isEnabled(feature);
  }
}