import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/repositories/transaction_repository.dart';

class GetTransactionUseCase {
  final TransactionRepository repository;

  GetTransactionUseCase(this.repository);

  Future<Either<Failure, Transaction>> execute(String id) async {
    return await repository.getTransaction(id);
  }
}
