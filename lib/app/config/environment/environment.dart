abstract class Environment {
  String get appName;
  String get apiBaseUrl;
  String get socketBaseUrl;
  String get firebaseProjectId;
  String get sentryDsn;
  String get amplitudeApiKey;
  String get mixpanelToken;
  bool get enableLogging;
  bool get enableCrashlytics;
  bool get enableAnalytics;
  bool get enablePerformanceMonitoring;
  String get plaidClientId;
  String get plaidSecret;
  String get stripePublishableKey;
  String get openAIApiKey;
  String get googleMapsApiKey;
  String get web3RpcUrl;
  int get web3ChainId;
}

class DevelopmentEnvironment implements Environment {
  @override
  String get appName => 'PayPulse Dev';

  @override
  String get apiBaseUrl => 'https://api.dev.paypulse.com/v1';

  @override
  String get socketBaseUrl => 'wss://ws.dev.paypulse.com';

  @override
  String get firebaseProjectId => 'paypulse-dev';

  @override
  String get sentryDsn => 'https://dev-sentry-key@sentry.io/project-id';

  @override
  String get amplitudeApiKey => 'dev-amplitude-key';

  @override
  String get mixpanelToken => 'dev-mixpanel-token';

  @override
  bool get enableLogging => true;

  @override
  bool get enableCrashlytics => false;

  @override
  bool get enableAnalytics => false;

  @override
  bool get enablePerformanceMonitoring => false;

  @override
  String get plaidClientId => 'dev-plaid-client-id';

  @override
  String get plaidSecret => 'dev-plaid-secret';

  @override
  String get stripePublishableKey => 'pk_test_xxx';

  @override
  String get openAIApiKey => 'dev-openai-key';

  @override
  String get googleMapsApiKey => 'dev-google-maps-key';

  @override
  String get web3RpcUrl => 'https://mainnet.infura.io/v3/your-project-id';

  @override
  int get web3ChainId => 1;
}
