import 'package:get_it/get_it.dart';
import 'package:paypulse/app/di/config/di_config.dart';
import 'package:paypulse/app/config/feature_flags.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/core/ai/ai_client.dart';
import 'package:paypulse/core/ai/models/cost_tracker.dart';
import 'package:paypulse/core/ai/context/memory_manager.dart';
import 'package:paypulse/core/ai/context/user_preference_manager.dart';
import 'package:paypulse/core/ai/providers/openai_provider.dart';
import 'package:paypulse/core/ai/providers/gemini_provider.dart';

final getIt = GetIt.instance;

/// Module for providing AI dependencies
class AIModule {
  Future<void> init() async {
    final config = getIt<DIConfig>();

    // Register singletons
    if (!getIt.isRegistered<CostTracker>()) {
      getIt.registerSingleton(CostTracker());
    }

    if (!getIt.isRegistered<MemoryManager>()) {
      getIt.registerSingleton(MemoryManager());
    }

    if (!getIt.isRegistered<UserPreferenceManager>()) {
      getIt.registerSingleton(UserPreferenceManager());
    }

    // Register Providers
    if (!getIt.isRegistered<OpenAIProvider>()) {
      getIt.registerSingleton(OpenAIProvider());
    }
    if (!getIt.isRegistered<GeminiProvider>()) {
      getIt.registerSingleton(GeminiProvider());
    }

    // Register AI Client based on feature flags and config
    if (!getIt.isRegistered<AIClient>()) {
      if (!config.featureFlags.isEnabled(Feature.aiFinancialAssistant)) {
        // TODO: Register a null-safe or basic implementation if disabled, or handle at usage site
        LoggerService.instance.d('AI Financial Assistant disabled', tag: 'DI');
      } else {
        // TODO: Implement actual AI Client registration with selected provider
        // For now, we will assume generic initialization is enough or specific client impl required
      }
    }

    LoggerService.instance.d('AIModule initialized', tag: 'DI');
  }
}
