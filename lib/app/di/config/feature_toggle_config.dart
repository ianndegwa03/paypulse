// lib/app/di/config/feature_toggle_config.dart
class FeatureToggle {
  static bool get enableAiFinancialAdvisor => 
      DIConfig.enablePremiumFeatures && DIConfig.enableAiFeatures;
  
  static bool get enableMultiBankAggregation => 
      DIConfig.enablePremiumFeatures;
  
  static bool get enableBusinessFinance => 
      DIConfig.enablePremiumFeatures;
  
  static bool get enableVoiceAssistant => 
      DIConfig.enableAiFeatures;
  
  static bool get enableAdvancedAnalytics => true;
  
  static bool get enableSocialFeatures => true;
  
  static bool get enableGamification => true;
}

// Conditional registration in modules
@module
abstract class PremiumModule {
  @singleton
  @Environment('prod')
  FinancialAdvisorRepository get financialAdvisorRepository => 
      FeatureToggle.enableAiFinancialAdvisor 
        ? FinancialAdvisorRepositoryImpl() 
        : MockFinancialAdvisorRepository();
}