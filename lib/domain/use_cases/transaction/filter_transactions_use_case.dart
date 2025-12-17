import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/repositories/transaction_repository.dart';

class FilterTransactionsUseCase {
  final TransactionRepository repository;

  FilterTransactionsUseCase(this.repository);

  Future<Either<Failure, List<Transaction>>> execute({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getTransactions(
      category: category,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
