import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';
import 'package:paypulse/domain/entities/card_entity.dart';
import 'package:paypulse/domain/entities/vault_entity.dart';
import 'package:paypulse/domain/entities/virtual_card_entity.dart';

abstract class WalletRepository {
  Stream<Wallet> getWalletStream();
  Stream<List<Transaction>> getTransactionsStream();
  Future<Either<Failure, Wallet>> getWallet();
  Future<Either<Failure, void>> addMoney(String amount, String currency);
  Future<Either<Failure, void>> transferMoney({
    required String recipientId,
    required String amount,
    required String currency,
    double fee = 0.0,
  });
  Future<Either<Failure, List<Transaction>>> getTransactions(
      {int limit = 10, int offset = 0});
  Future<Either<Failure, Map<String, dynamic>>> getWalletAnalytics();
  Future<Either<Failure, void>> updateWallet(Wallet wallet);
  Future<Either<Failure, void>> linkCard(CardEntity card);
  Future<Either<Failure, void>> createVault(VaultEntity vault);
  Future<Either<Failure, void>> fundVault(String vaultId, double amount);
  Future<Either<Failure, void>> createVirtualCard(VirtualCardEntity card);
  Future<Either<Failure, void>> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    required double rate,
  });
}
