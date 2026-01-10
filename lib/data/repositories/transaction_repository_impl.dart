import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/data/models/transaction_model.dart';
import 'package:paypulse/data/remote/datasources/transaction_datasource.dart';
import 'package:paypulse/data/local/datasources/hive_transaction_data_source.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart' as entity;
import 'package:paypulse/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDataSource _remoteDataSource;
  final TransactionLocalDataSource _localDataSource;
  final FirebaseAuth _firebaseAuth;

  TransactionRepositoryImpl({
    required TransactionDataSource remoteDataSource,
    required TransactionLocalDataSource localDataSource,
    FirebaseAuth? firebaseAuth,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String get _userId => _firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, entity.Transaction>> createTransaction(
      entity.Transaction transaction) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final model = TransactionModel(
        id: '',
        amount: transaction.amount,
        description: transaction.description,
        date: transaction.date,
        categoryId: transaction.categoryId,
        paymentMethodId: transaction.paymentMethodId,
        type: transaction.type,
        currencyCode: transaction.currencyCode,
        targetCurrencyCode: transaction.targetCurrencyCode,
        exchangeRate: transaction.exchangeRate,
        status: transaction.status,
      );

      final created = await _remoteDataSource.createTransaction(_userId, model);
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, List<entity.Transaction>>> getTransactions({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      try {
        // Try remote first
        final transactions = await _remoteDataSource.getTransactions(
          _userId,
          category: category,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
          offset: offset,
        );

        // Cache if it's the main feed (no filters)
        if (category == null && startDate == null && endDate == null) {
          await _localDataSource.cacheTransactions(transactions);
        }

        return Right(transactions);
      } catch (e) {
        // Fallback to cache if remote fails and we are looking for main feed
        if (category == null && startDate == null && endDate == null) {
          final cached = await _localDataSource.getLastTransactions();
          if (cached.isNotEmpty) {
            return Right(cached);
          }
        }
        rethrow;
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, entity.Transaction>> getTransaction(String id) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final transaction = await _remoteDataSource.getTransaction(_userId, id);
      return Right(transaction);
    } catch (e) {
      if (e.toString().contains('not found')) {
        return const Left(CacheFailure(message: 'Transaction not found'));
      }
      return Left(ServerFailure(message: 'Failed to get transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, List<entity.Transaction>>> searchTransactions(
      String query) async {
    try {
      final result = await getTransactions(limit: 50);
      return result.fold((failure) => Left(failure), (transactions) {
        final filtered = transactions
            .where((t) =>
                t.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return Right(filtered);
      });
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> exportTransactions(
      {String format = 'csv'}) async {
    try {
      final result = await getTransactions(limit: 1000);
      return result.fold(
        (failure) => Left(failure),
        (transactions) {
          final buffer = StringBuffer();
          buffer.writeln('ID,Amount,Description,Date,Category,Type,Status');
          for (var tx in transactions) {
            buffer.writeln(
                '${tx.id},${tx.amount},"${tx.description}",${tx.date},${tx.categoryId},${tx.type.name},${tx.status.name}');
          }
          return Right(buffer.toString());
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Export failed: $e'));
    }
  }

  @override
  Future<Either<Failure, entity.Transaction>> categorizeTransaction(
      String id, String categoryId) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final updated = await _remoteDataSource.categorizeTransaction(
          _userId, id, categoryId);
      return Right(updated);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to categorize transaction: $e'));
    }
  }
}
