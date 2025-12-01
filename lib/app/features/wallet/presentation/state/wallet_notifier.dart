import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_state.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _walletRepository;
  StreamSubscription? _walletSubscription;
  StreamSubscription? _transactionsSubscription;

  WalletNotifier(this._walletRepository) : super(WalletInitial()) {
    _walletSubscription = _walletRepository.getWallet().listen((wallet) {
      _transactionsSubscription = _walletRepository.getTransactions().listen((transactions) {
        state = WalletLoaded(wallet, transactions);
      });
    });
  }

  @override
  void dispose() {
    _walletSubscription?.cancel();
    _transactionsSubscription?.cancel();
    super.dispose();
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _walletRepository.addTransaction(transaction);
    } catch (e) {
      state = WalletError(e.toString());
    }
  }
}
