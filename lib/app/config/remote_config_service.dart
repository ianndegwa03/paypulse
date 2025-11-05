// lib/app/config/remote_config_service.dart
class RemoteConfigService {
  static final _instance = RemoteConfigService._internal();
  final _remoteConfig = FirebaseRemoteConfig.instance;
  final _localConfig = LocalConfigService();
  
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    
    await _remoteConfig.fetchAndActivate();
  }
  
  bool isFeatureEnabled(String feature) {
    // Try remote config first, fallback to local
    try {
      return _remoteConfig.getBool('feature_$feature') ?? 
             _localConfig.isFeatureEnabled(feature);
    } catch (e) {
      return _localConfig.isFeatureEnabled(feature);
    }
  }
  
  Future<void> refresh() async {
    await _remoteConfig.fetchAndActivate();
  }
}

// Usage in modules
// class GamificationModule {
//   static bool get isEnabled => 
//       RemoteConfigService.instance.isFeatureEnabled('gamification');
  
//   static void initializeIfEnabled() {
//     if (isEnabled) {
//       ServiceLocator.get<RewardsEngine>().initialize();
//     }
//   }
// }