import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/bill_entity.dart';
import 'package:paypulse/domain/repositories/bills_repository.dart';

class GetBillsUseCase {
  final BillsRepository repository;

  GetBillsUseCase(this.repository);

  Future<Either<Failure, List<BillEntity>>> call() {
    return repository.getBills();
  }
}
