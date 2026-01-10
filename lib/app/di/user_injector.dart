import 'package:get_it/get_it.dart';
import 'package:paypulse/app/di/config/di_config.dart';
import 'package:paypulse/app/di/modules/core_module.dart';
import 'package:paypulse/app/di/modules/auth_module.dart';
import 'package:paypulse/app/di/modules/wallet_module.dart';
import 'package:paypulse/app/di/modules/transaction_module.dart';
import 'package:paypulse/app/di/modules/user_module.dart';
import 'package:paypulse/app/di/modules/admin_module.dart';
import 'package:paypulse/app/di/modules/community_module.dart';

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

    // Initialize core feature modules
    await AuthModule().init();
    await WalletModule().init();
    await TransactionModule().init();
    await UserModule().init();
    await AdminModule().init();
    await CommunityModule().init();
  }
}
