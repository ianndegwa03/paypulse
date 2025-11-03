// lib/app/di/service_locator.dart
import 'package:paypulse/app/di/injector.dart';

class ServiceLocator {
  static void init() {
    configureDependencies();
  }

  // Core Services
  static T get<T extends Object>() => getIt<T>();
  static T getWithParam<T extends Object, P>(P param) => getIt<T>(param1: param);
  
  // Lazy getters for frequently used services
  static StorageService get storage => getIt<StorageService>();
  static ApiService get api => getIt<ApiService>();
  static AuthRepository get authRepo => getIt<AuthRepository>();
  static NotificationService get notifications => getIt<NotificationService>();
  
  // Feature-specific getters
  static WalletRepository get walletRepo => getIt<WalletRepository>();
  static TransactionRepository get transactionRepo => getIt<TransactionRepository>();
  static InvestmentRepository get investmentRepo => getIt<InvestmentRepository>();
  static AiRepository get aiRepo => getIt<AiRepository>();
  
  // Premium features with null-safety
  static FinancialAdvisorRepository? get advisorRepo => 
      getIt.isRegistered<FinancialAdvisorRepository>() 
        ? getIt<FinancialAdvisorRepository>() 
        : null;
}

// Extension for easy access
extension ServiceLocatorExtension on GetIt {
  T getOrNull<T extends Object>() {
    try {
      return get<T>();
    } catch (e) {
      return null as T;
    }
  }
}