import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/domain/use_cases/wallet/get_wallet_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/get_transactions_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/create_transaction_use_case.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_notifier.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_state.dart';

final walletStateProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(
    getWalletUseCase: getIt<GetWalletUseCase>(),
    getTransactionsUseCase: getIt<GetTransactionsUseCase>(),
    createTransactionUseCase: getIt<CreateTransactionUseCase>(),
  );
});
