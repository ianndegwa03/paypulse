import 'package:get_it/get_it.dart';
import 'package:paypulse/app/di/config/di_config.dart';
import 'package:paypulse/app/di/modules/core_module.dart';
import 'package:paypulse/app/di/modules/auth_module.dart';
import 'package:paypulse/app/di/modules/wallet_module.dart';
import 'package:paypulse/app/di/modules/transaction_module.dart';
import 'package:paypulse/app/di/modules/healthcare_finance_module.dart';

import 'package:paypulse/app/di/modules/quantum_security_module.dart';
import 'package:paypulse/app/di/modules/investment_module.dart';
import 'package:paypulse/app/di/modules/savings_module.dart';
import 'package:paypulse/app/di/modules/bills_module.dart';
import 'package:paypulse/app/di/modules/gamification_module.dart';
import 'package:paypulse/app/di/modules/social_module.dart';
import 'package:paypulse/app/di/modules/user_module.dart';

final GetIt getIt = GetIt.instance;

class UserInjector {
  static Future<void> init({
    required DIConfig config,
  }) async {
    // Register configuration
    if (!getIt.isRegistered<DIConfig>()) {
      getIt.registerSingleton<DIConfig>(config);
    }

    // Initialize core module
    await CoreModule().init();

    // Initialize shared feature modules
    await AuthModule().init();
    await WalletModule().init();
    await TransactionModule().init();
    // await BehavioralCoachingModule().init(); // Removed AI Feature
    await HealthcareFinanceModule().init();
    // await PredictiveAnalyticsModule().init(); // Removed AI Feature
    await QuantumSecurityModule().init();
    await InvestmentModule().init();
    await SavingsModule().init();
    await BillsModule().init();
    await GamificationModule().init();
    await SocialModule().init();
    await UserModule().init();

    // NO AdminModule here
  }
}
