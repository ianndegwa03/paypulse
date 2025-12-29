import 'package:paypulse/core/base/base_state.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';
import 'package:paypulse/domain/entities/split_request_entity.dart';

class WalletState extends BaseState {
  final Wallet? wallet;
  final List<Transaction> transactions;
  final List<SplitRequest> pendingRequests;

  const WalletState({
    super.isLoading = false,
    this.wallet,
    this.transactions = const [],
    this.pendingRequests = const [],
    super.errorMessage,
    super.successMessage,
  });

  @override
  WalletState copyWith({
    bool? isLoading,
    Wallet? wallet,
    List<Transaction>? transactions,
    List<SplitRequest>? pendingRequests,
    String? errorMessage,
    String? successMessage,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props =>
      [wallet, transactions, pendingRequests, ...super.props];
}
