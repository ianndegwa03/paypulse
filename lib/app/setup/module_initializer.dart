// lib/app/setup/module_initializer.dart
class ModuleInitializer {
  Future<void> initializeCoreFinance() async {
    // Lazy initialization - only load when needed
    getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
    getIt.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl());
    getIt.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl());
  }
  
  Future<void> initializeGamification() async {
    // Heavy services loaded only when feature is used
    getIt.registerLazySingleton<RewardsEngine>(() => RewardsEngine());
    getIt.registerLazySingleton<AchievementService>(() => AchievementService());
    
    // Pre-warm cache for better UX
    await getIt<RewardsEngine>().preloadUserProgress();
  }
  
  Future<void> initializeAIPersonalization() async {
    // AI models loaded asynchronously
    final aiModel = await AIClient.loadModel();
    getIt.registerSingleton<AIClient>(aiModel);
    
    getIt.registerLazySingleton<PersonalizationEngine>(() => PersonalizationEngine());
  }
}