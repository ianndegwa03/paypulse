import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:paypulse/domain/use_cases/wallet/get_wallet_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/get_transactions_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/create_transaction_use_case.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_notifier.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_state.dart';

// No longer direct Repository Provider needed for Notifier if we inject Use Cases directly via GetIt
// But if we want to expose it:
// final walletRepositoryProvider = ...

final walletStateProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(
    getWalletUseCase: GetIt.instance<GetWalletUseCase>(),
    getTransactionsUseCase: GetIt.instance<GetTransactionsUseCase>(),
    createTransactionUseCase: GetIt.instance<CreateTransactionUseCase>(),
  );
});
