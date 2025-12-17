import 'package:paypulse/app/config/environment/environment.dart';

/// Loads the appropriate environment configuration
class EnvironmentLoader {
  /// Load environment configuration based on compile-time flags
  static Future<Environment> loadEnvironment() async {
    // In production, you might check for environment variables or config files
    // For now, default to development environment
    const String envName = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );

    switch (envName.toLowerCase()) {
      case 'production':
      case 'prod':
        return ProductionEnvironment();
      case 'staging':
        return StagingEnvironment();
      case 'development':
      case 'dev':
      default:
        return DevelopmentEnvironment();
    }
  }
}

/// Production environment configuration
class ProductionEnvironment implements Environment {
  @override
  String get appName => 'PayPulse';

  @override
  String get apiBaseUrl => 'https://api.paypulse.com/v1';

  @override
  String get socketBaseUrl => 'wss://ws.paypulse.com';

  @override
  String get firebaseProjectId => 'paypulse-prod';

  @override
  String get sentryDsn => 'https://prod-sentry-key@sentry.io/project-id';

  @override
  String get amplitudeApiKey => 'prod-amplitude-key';

  @override
  String get mixpanelToken => 'prod-mixpanel-token';

  @override
  bool get enableLogging => false;

  @override
  bool get enableCrashlytics => true;

  @override
  bool get enableAnalytics => true;

  @override
  bool get enablePerformanceMonitoring => true;

  @override
  String get plaidClientId => 'prod-plaid-client-id';

  @override
  String get plaidSecret => 'prod-plaid-secret';

  @override
  String get stripePublishableKey => 'pk_live_xxx';

  @override
  String get openAIApiKey => 'prod-openai-key';

  @override
  String get googleMapsApiKey => 'prod-google-maps-key';

  @override
  String get web3RpcUrl => 'https://mainnet.infura.io/v3/prod-project-id';

  @override
  int get web3ChainId => 1;
}

/// Staging environment configuration
class StagingEnvironment implements Environment {
  @override
  String get appName => 'PayPulse Staging';

  @override
  String get apiBaseUrl => 'https://api.staging.paypulse.com/v1';

  @override
  String get socketBaseUrl => 'wss://ws.staging.paypulse.com';

  @override
  String get firebaseProjectId => 'paypulse-staging';

  @override
  String get sentryDsn => 'https://staging-sentry-key@sentry.io/project-id';

  @override
  String get amplitudeApiKey => 'staging-amplitude-key';

  @override
  String get mixpanelToken => 'staging-mixpanel-token';

  @override
  bool get enableLogging => true;

  @override
  bool get enableCrashlytics => true;

  @override
  bool get enableAnalytics => true;

  @override
  bool get enablePerformanceMonitoring => true;

  @override
  String get plaidClientId => 'staging-plaid-client-id';

  @override
  String get plaidSecret => 'staging-plaid-secret';

  @override
  String get stripePublishableKey => 'pk_test_xxx';

  @override
  String get openAIApiKey => 'staging-openai-key';

  @override
  String get googleMapsApiKey => 'staging-google-maps-key';

  @override
  String get web3RpcUrl => 'https://goerli.infura.io/v3/staging-project-id';

  @override
  int get web3ChainId => 5;
}
