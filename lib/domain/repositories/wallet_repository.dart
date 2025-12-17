import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';

abstract class WalletRepository {
  Stream<Wallet> getWalletStream();
  Stream<List<Transaction>> getTransactionsStream();
  Future<Either<Failure, Wallet>> getWallet();
  Future<Either<Failure, void>> addMoney(String amount, String currency);
  Future<Either<Failure, void>> transferMoney({
    required String recipientId,
    required String amount,
    required String currency,
  });
  Future<Either<Failure, List<Transaction>>> getTransactions(
      {int limit = 10, int offset = 0});
  Future<Either<Failure, Map<String, dynamic>>> getWalletAnalytics();
}
