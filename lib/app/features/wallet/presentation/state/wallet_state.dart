import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final List<Transaction> transactions;

  const WalletLoaded(this.wallet, this.transactions);

  @override
  List<Object?> get props => [wallet, transactions];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
