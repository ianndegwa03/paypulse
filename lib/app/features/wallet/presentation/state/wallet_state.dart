import 'package:paypulse/core/base/base_state.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';

class WalletState extends BaseState {
  final Wallet? wallet;
  final List<Transaction> transactions;

  const WalletState({
    super.isLoading = false,
    this.wallet,
    this.transactions = const [],
    super.errorMessage,
    super.successMessage,
  });

  @override
  WalletState copyWith({
    bool? isLoading,
    Wallet? wallet,
    List<Transaction>? transactions,
    String? errorMessage,
    String? successMessage,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [wallet, transactions, ...super.props];
}
