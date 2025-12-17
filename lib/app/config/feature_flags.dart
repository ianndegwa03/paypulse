enum Feature {
  aiFinancialAssistant,
  biometricAuth,
  cryptoWallet,
  investmentTracking,
  billAutomation,
  voiceCommands,
  socialFeatures,
  gamification,
  offlineMode,
  web3Integration,
  quantumSecurity,
  behavioralCoaching,
  predictiveAnalytics,
  healthcareFinance,
  crossBorderPayments,
}

class FeatureFlags {
  final Map<Feature, bool> _flags;

  FeatureFlags(this._flags);

  bool isEnabled(Feature feature) {
    return _flags[feature] ?? false;
  }

  void updateFlag(Feature feature, bool value) {
    _flags[feature] = value;
  }

  Map<Feature, bool> getAllFlags() => Map.from(_flags);

  factory FeatureFlags.defaultFlags() {
    return FeatureFlags({
      Feature.aiFinancialAssistant: true,
      Feature.biometricAuth: true,
      Feature.cryptoWallet: false,
      Feature.investmentTracking: true,
      Feature.billAutomation: true,
      Feature.voiceCommands: false,
      Feature.socialFeatures: false,
      Feature.gamification: true,
      Feature.offlineMode: true,
      Feature.web3Integration: false,
      Feature.quantumSecurity: false,
      Feature.behavioralCoaching: true,
      Feature.predictiveAnalytics: true,
      Feature.healthcareFinance: false,
      Feature.crossBorderPayments: false,
    });
  }
}