// lib/app/config/environment/dev_environment.dart
class DevEnvironment implements AppEnvironment {
  @override
  String get baseUrl => 'https://api.paypulse.dev';
  
  @override
  String get apiKey => 'dev_key_123';
  
  @override
  bool get enableAnalytics => true;
  
  @override
  bool get enableCrashReporting => false; // Don't report crashes in dev
  
  @override
  Map<String, bool> get featureFlags => {
    'gamification': true,
    'ai_personalization': true,
    'social_finance': true,
    'crypto_integration': false, // Disabled in dev
  };
  
  @override
  LogLevel get logLevel => LogLevel.debug;
}