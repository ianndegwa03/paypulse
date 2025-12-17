import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/transaction_repository.dart';

class ExportTransactionsUseCase {
  final TransactionRepository repository;

  ExportTransactionsUseCase(this.repository);

  Future<Either<Failure, String>> execute({String format = 'csv'}) async {
    return await repository.exportTransactions(format: format);
  }
}
