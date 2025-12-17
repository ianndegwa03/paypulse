import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/data/remote/datasources/wallet_datasource.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart' as domain;
import 'package:paypulse/domain/entities/wallet_entity.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletDataSource _dataSource;
  final FirebaseAuth _firebaseAuth;

  WalletRepositoryImpl({
    required WalletDataSource dataSource,
    FirebaseAuth? firebaseAuth,
  })  : _dataSource = dataSource,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String get _userId => _firebaseAuth.currentUser?.uid ?? '';

  @override
  Stream<Wallet> getWalletStream() {
    if (_userId.isEmpty) return const Stream.empty();
    return _dataSource.getWalletStream(_userId);
  }

  @override
  Stream<List<domain.Transaction>> getTransactionsStream() {
    if (_userId.isEmpty) return const Stream.empty();
    return _dataSource.getTransactionsStream(_userId);
  }

  @override
  Future<Either<Failure, Wallet>> getWallet() async {
    try {
      if (_userId.isEmpty)
        return Left(AuthFailure(message: 'User not authenticated'));

      final wallet = await _dataSource.getWallet(_userId);
      return Right(wallet);
    } catch (e) {
      if (e.toString().contains('Wallet not found')) {
        return Left(CacheFailure(message: 'Wallet not found'));
      }
      return Left(ServerFailure(message: 'Failed to get wallet: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addMoney(String amount, String currency) async {
    try {
      if (_userId.isEmpty)
        return Left(AuthFailure(message: 'User not authenticated'));

      await _dataSource.addMoney(_userId, amount, currency);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add money: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> transferMoney({
    required String recipientId,
    required String amount,
    required String currency,
  }) async {
    try {
      if (_userId.isEmpty)
        return Left(AuthFailure(message: 'User not authenticated'));

      await _dataSource.transferMoney(
        userId: _userId,
        recipientId: recipientId,
        amount: amount,
        currency: currency,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to transfer money: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Transaction>>> getTransactions(
      {int limit = 10, int offset = 0}) async {
    try {
      if (_userId.isEmpty)
        return Left(AuthFailure(message: 'User not authenticated'));

      final transactions = await _dataSource.getTransactions(
        _userId,
        limit: limit,
        offset: offset,
      );
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWalletAnalytics() async {
    try {
      if (_userId.isEmpty)
        return Left(AuthFailure(message: 'User not authenticated'));

      final analytics = await _dataSource.getWalletAnalytics(_userId);
      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get analytics: $e'));
    }
  }
}
