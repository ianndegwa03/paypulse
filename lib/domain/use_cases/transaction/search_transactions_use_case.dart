import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/repositories/transaction_repository.dart';

class SearchTransactionsUseCase {
  final TransactionRepository repository;

  SearchTransactionsUseCase(this.repository);

  Future<Either<Failure, List<Transaction>>> execute(String query) async {
    return await repository.searchTransactions(query);
  }
}
