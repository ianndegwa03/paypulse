import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';
import 'package:paypulse/domain/entities/card_entity.dart';
import 'package:paypulse/domain/entities/vault_entity.dart';
import 'package:paypulse/domain/entities/virtual_card_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/use_cases/wallet/get_wallet_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/link_card_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/update_wallet_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/create_transaction_use_case.dart';
import 'package:paypulse/domain/use_cases/transaction/get_transactions_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/transfer_money_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/create_vault_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/fund_vault_use_case.dart';
import 'package:paypulse/domain/use_cases/wallet/create_virtual_card_use_case.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_state.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  final GetWalletUseCase _getWalletUseCase;
  final GetTransactionsUseCase _getTransactionsUseCase;
  final CreateTransactionUseCase _createTransactionUseCase;
  final LinkCardUseCase _linkCardUseCase;
  final UpdateWalletUseCase _updateWalletUseCase;
  final TransferMoneyUseCase _transferMoneyUseCase;
  final CreateVaultUseCase _createVaultUseCase;
  final FundVaultUseCase _fundVaultUseCase;
  final CreateVirtualCardUseCase _createVirtualCardUseCase;
  final _logger = LoggerService.instance;

  StreamSubscription? _walletSubscription;

  WalletNotifier({
    required GetWalletUseCase getWalletUseCase,
    required GetTransactionsUseCase getTransactionsUseCase,
    required CreateTransactionUseCase createTransactionUseCase,
    required LinkCardUseCase linkCardUseCase,
    required UpdateWalletUseCase updateWalletUseCase,
    required TransferMoneyUseCase transferMoneyUseCase,
    required CreateVaultUseCase createVaultUseCase,
    required FundVaultUseCase fundVaultUseCase,
    required CreateVirtualCardUseCase createVirtualCardUseCase,
  })  : _getWalletUseCase = getWalletUseCase,
        _getTransactionsUseCase = getTransactionsUseCase,
        _createTransactionUseCase = createTransactionUseCase,
        _linkCardUseCase = linkCardUseCase,
        _updateWalletUseCase = updateWalletUseCase,
        _transferMoneyUseCase = transferMoneyUseCase,
        _createVaultUseCase = createVaultUseCase,
        _fundVaultUseCase = fundVaultUseCase,
        _createVirtualCardUseCase = createVirtualCardUseCase,
        super(const WalletState());

  void loadWallet(String userId) {
    _logger.d('Loading wallet data for user: $userId', tag: 'WalletNotifier');
    _walletSubscription?.cancel();
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

  Future<void> _fetchTransactions(Wallet wallet) async {
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

  Future<void> linkCard(CardEntity card) async {
    state = state.copyWith(isLoading: true);
    final result = await _linkCardUseCase.execute(card);
    result.fold(
      (failure) {
        _logger.e('Failed to link card: ${failure.message}',
            tag: 'WalletNotifier');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        _logger.i('Card linked successfully', tag: 'WalletNotifier');
        state = state.copyWith(
            isLoading: false, successMessage: 'Card linked successfully!');
      },
    );
  }

  Future<void> togglePlatformWallet(bool enabled) async {
    state = state.copyWith(isLoading: true);
    final wallet = state.wallet ??
        Wallet(
          id: '', // repo will inject real ID
          balance: 0,
          currency: CurrencyType.USD,
        );

    final updatedWallet = wallet.copyWith(hasPlatformWallet: enabled);
    final result = await _updateWalletUseCase.execute(updatedWallet);

    result.fold(
      (failure) {
        _logger.e('Failed to update platform wallet: ${failure.message}',
            tag: 'WalletNotifier');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        _logger.i('Platform wallet status updated: $enabled',
            tag: 'WalletNotifier');
        state = state.copyWith(isLoading: false);
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

  Future<void> transferMoney({
    required String recipientId,
    required String amount,
    required String currency,
    bool isPremium = false,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _transferMoneyUseCase.execute(
      recipientId: recipientId,
      amount: amount,
      currency: currency,
      isPremium: isPremium,
    );

    result.fold(
      (failure) {
        _logger.e('Transfer failed: ${failure.message}', tag: 'WalletNotifier');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        _logger.i('Transfer successful', tag: 'WalletNotifier');
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Transferred successfully!',
        );
      },
    );
  }

  Future<void> createVault(VaultEntity vault) async {
    state = state.copyWith(isLoading: true);
    final result = await _createVaultUseCase.execute(vault);
    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) => state =
          state.copyWith(isLoading: false, successMessage: 'Vault created!'),
    );
  }

  Future<void> fundVault(String vaultId, double amount) async {
    state = state.copyWith(isLoading: true);
    final result = await _fundVaultUseCase.execute(vaultId, amount);
    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) => state =
          state.copyWith(isLoading: false, successMessage: 'Vault funded!'),
    );
  }

  Future<void> createVirtualCard(VirtualCardEntity card) async {
    state = state.copyWith(isLoading: true);
    final result = await _createVirtualCardUseCase.execute(card);
    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) => state = state.copyWith(
          isLoading: false, successMessage: 'Virtual card created!'),
    );
  }
}
