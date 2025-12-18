import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/use_cases/wallet/get_wallet_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/create_transaction_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/get_transactions_use_case.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_state.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  final GetWalletUseCase _getWalletUseCase;
  final GetTransactionsUseCase _getTransactionsUseCase;
  final CreateTransactionUseCase _createTransactionUseCase;
  final _logger = LoggerService.instance;

  StreamSubscription? _walletSubscription;

  WalletNotifier({
    required GetWalletUseCase getWalletUseCase,
    required GetTransactionsUseCase getTransactionsUseCase,
    required CreateTransactionUseCase createTransactionUseCase,
  })  : _getWalletUseCase = getWalletUseCase,
        _getTransactionsUseCase = getTransactionsUseCase,
        _createTransactionUseCase = createTransactionUseCase,
        super(const WalletState()) {
    _loadWalletData();
  }

  void _loadWalletData() {
    _logger.d('Starting wallet data load', tag: 'WalletNotifier');
    _walletSubscription = _getWalletUseCase.executeStream().listen(
      (wallet) {
        _logger.d('Wallet stream update received', tag: 'WalletNotifier');
        _fetchTransactions(wallet);
      },
      onError: (error) {
        _logger.e('Wallet stream error: $error', tag: 'WalletNotifier');
        state = state.copyWith(errorMessage: error.toString());
      },
    );
  }

  Future<void> _fetchTransactions(wallet) async {
    state = state.copyWith(isLoading: state.wallet == null);
    final result = await _getTransactionsUseCase.execute(limit: 10);
    result.fold(
      (failure) {
        _logger.e('Failed to fetch transactions: ${failure.message}',
            tag: 'WalletNotifier');
        state = state.copyWith(
          isLoading: false,
          wallet: wallet,
          errorMessage: failure.message,
        );
      },
      (transactions) {
        _logger.d('Transactions fetched successfully', tag: 'WalletNotifier');
        state = state.copyWith(
          isLoading: false,
          wallet: wallet,
          transactions: transactions,
        );
      },
    );
  }

  @override
  void dispose() {
    _walletSubscription?.cancel();
    _logger.d('WalletNotifier disposed', tag: 'WalletNotifier');
    super.dispose();
  }

  Future<void> addTransaction(Transaction transaction) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _createTransactionUseCase.execute(transaction);
      result.fold(
        (failure) {
          _logger.e('Failed to add transaction: ${failure.message}',
              tag: 'WalletNotifier');
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (newTx) {
          _logger.i('Transaction added successfully', tag: 'WalletNotifier');
          state = state.copyWith(isLoading: false);
          // Stream will refresh data
        },
      );
    } catch (e) {
      _logger.e('Unexpected error adding transaction: $e',
          tag: 'WalletNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// Provider moved to wallet_providers.dart
