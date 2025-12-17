import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, Transaction>> createTransaction(
      Transaction transaction);
  Future<Either<Failure, List<Transaction>>> getTransactions({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  });
  Future<Either<Failure, Transaction>> getTransaction(String id);
  Future<Either<Failure, List<Transaction>>> searchTransactions(String query);
  Future<Either<Failure, String>> exportTransactions({String format = 'csv'});
  Future<Either<Failure, Transaction>> categorizeTransaction(
      String id, String categoryId);
}
