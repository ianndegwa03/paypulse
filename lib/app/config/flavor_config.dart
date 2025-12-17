/// App flavor enumeration
enum AppFlavor {
  development,
  staging,
  production,
}

/// Flavor configuration utility
class FlavorConfig {
  /// Determine the current app flavor from compile-time environment
  static AppFlavor determineFlavor() {
    const String flavorName = String.fromEnvironment(
      'FLAVOR',
      defaultValue: 'development',
    );

    switch (flavorName.toLowerCase()) {
      case 'production':
      case 'prod':
        return AppFlavor.production;
      case 'staging':
        return AppFlavor.staging;
      case 'development':
      case 'dev':
      default:
        return AppFlavor.development;
    }
  }

  /// Check if current flavor is development
  static bool get isDevelopment => determineFlavor() == AppFlavor.development;

  /// Check if current flavor is staging
  static bool get isStaging => determineFlavor() == AppFlavor.staging;

  /// Check if current flavor is production
  static bool get isProduction => determineFlavor() == AppFlavor.production;
}
