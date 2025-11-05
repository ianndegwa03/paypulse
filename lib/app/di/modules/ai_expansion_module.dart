// lib/app/di/modules/ai_expansion_module.dart
@module
abstract class AiExpansionModule {
  
  @singleton
  PersonalizationRepository get personalizationRepository => 
      PersonalizationRepositoryImpl();
  
  @singleton
  SentimentAnalysisRepository get sentimentAnalysisRepository => 
      SentimentAnalysisRepositoryImpl();
  
  @singleton
  FraudDetectionRepository get fraudDetectionRepository => 
      FraudDetectionRepositoryImpl();
  
  @singleton
  PersonalizationBloc get personalizationBloc => PersonalizationBloc(
    analyzeBehaviorPatternsUseCase: getIt<AnalyzeBehaviorPatternsUseCase>(),
    generatePersonalizedRecommendationsUseCase: getIt<GeneratePersonalizedRecommendationsUseCase>(),
  );
  
  @singleton
  SentimentAnalysisBloc get sentimentAnalysisBloc => SentimentAnalysisBloc(
    analyzeMarketSentimentUseCase: getIt<AnalyzeMarketSentimentUseCase>(),
    generateSentimentAlertsUseCase: getIt<GenerateSentimentAlertsUseCase>(),
  );
}