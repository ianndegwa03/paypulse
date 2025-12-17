import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/use_cases/wallet/get_wallet_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/create_transaction_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/get_transactions_use_case.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_state.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  final GetWalletUseCase _getWalletUseCase;
  final GetTransactionsUseCase
      _getTransactionsUseCase; // Using use case instead of repo
  final CreateTransactionUseCase _createTransactionUseCase; // Using use case

  StreamSubscription? _walletSubscription;
  StreamSubscription? _transactionsSubscription;

  WalletNotifier({
    required GetWalletUseCase getWalletUseCase,
    required GetTransactionsUseCase getTransactionsUseCase,
    required CreateTransactionUseCase createTransactionUseCase,
  })  : _getWalletUseCase = getWalletUseCase,
        _getTransactionsUseCase = getTransactionsUseCase,
        _createTransactionUseCase = createTransactionUseCase,
        super(WalletInitial()) {
    _loadWalletData();
  }

  void _loadWalletData() {
    _walletSubscription = _getWalletUseCase.executeStream().listen((wallet) {
      // Assuming we need to listen to transactions separately or wallet stream includes them?
      // RepositoryImpl separates them.
      // We don't have UseCase for transaction STREAM.
      // The previous code had stream for transactions.
      // I should update GetTransactionsUseCase to support stream or add GetTransactionsStreamUseCase.
      // For now, let's assume we fetch them once or polling?
      // Wait, repository has getTransactionsStream().
      // Let's use direct repo stream access via Use Case?
      // Or better, let's fetch them on wallet update.
      _fetchTransactions(wallet);
    });
  }

  Future<void> _fetchTransactions(wallet) async {
    final result = await _getTransactionsUseCase.execute(limit: 10);
    result.fold(
      (failure) => state = WalletError(failure.message),
      (transactions) => state = WalletLoaded(wallet, transactions),
    );
  }

  @override
  void dispose() {
    _walletSubscription?.cancel();
    _transactionsSubscription?.cancel();
    super.dispose();
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      final result = await _createTransactionUseCase.execute(transaction);
      result.fold((failure) => state = WalletError(failure.message), (newTx) {
        // Success, logic to update state or let stream update do it
      });
    } catch (e) {
      state = WalletError(e.toString());
    }
  }
}

// Provider moved to wallet_providers.dart
