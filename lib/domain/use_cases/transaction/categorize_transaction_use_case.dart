import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/repositories/transaction_repository.dart';

class CategorizeTransactionUseCase {
  final TransactionRepository repository;

  CategorizeTransactionUseCase(this.repository);

  Future<Either<Failure, Transaction>> execute({
    required String transactionId,
    required String categoryId,
  }) async {
    return await repository.categorizeTransaction(transactionId, categoryId);
  }
}
