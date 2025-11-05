// lib/app/config/environment/environment.dart
abstract class AppEnvironment {
  String get baseUrl;
  String get apiKey;
  bool get enableAnalytics;
  bool get enableCrashReporting;
  Map<String, bool> get featureFlags;
  LogLevel get logLevel;
}