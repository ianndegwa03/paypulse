import 'package:paypulse/app/config/feature_flags.dart';
import 'package:paypulse/app/config/environment/environment.dart';

class DIConfig {
  final Environment environment;
  final FeatureFlags featureFlags;
  final bool enableMockServices;
  
  DIConfig({
    required this.environment,
    required this.featureFlags,
    this.enableMockServices = false,
  });
}