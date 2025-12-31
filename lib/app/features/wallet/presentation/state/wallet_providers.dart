import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/domain/use_cases/wallet/get_wallet_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/get_transactions_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/create_transaction_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/link_card_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/update_wallet_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/transfer_money_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/create_vault_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/fund_vault_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/create_virtual_card_use_case.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_notifier.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_state.dart';

import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/domain/services/exchange_rate_service.dart';
import 'package:paypulse/data/services/exchange_rate_service_impl.dart';

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  return ExchangeRateServiceImpl();
});

final walletStateProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final userId = ref.watch(authNotifierProvider).userId;

  final notifier = WalletNotifier(
    getWalletUseCase: getIt<GetWalletUseCase>(),
    getTransactionsUseCase: getIt<GetTransactionsUseCase>(),
    createTransactionUseCase: getIt<CreateTransactionUseCase>(),
    linkCardUseCase: getIt<LinkCardUseCase>(),
    updateWalletUseCase: getIt<UpdateWalletUseCase>(),
    transferMoneyUseCase: getIt<TransferMoneyUseCase>(),
    createVaultUseCase: getIt<CreateVaultUseCase>(),
    fundVaultUseCase: getIt<FundVaultUseCase>(),
    createVirtualCardUseCase: getIt<CreateVirtualCardUseCase>(),
  );

  if (userId != null && userId.isNotEmpty) {
    notifier.loadWallet(userId);
  }

  return notifier;
});
