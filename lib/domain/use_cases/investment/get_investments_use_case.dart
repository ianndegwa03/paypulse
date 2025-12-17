import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/investment_entity.dart';
import 'package:paypulse/domain/repositories/investment_repository.dart';

class GetInvestmentsUseCase {
  final InvestmentRepository repository;

  GetInvestmentsUseCase(this.repository);

  Future<Either<Failure, List<InvestmentEntity>>> call() {
    return repository.getInvestments();
  }
}
