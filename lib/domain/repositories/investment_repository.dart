import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/investment_entity.dart';

abstract class InvestmentRepository {
  Future<Either<Failure, List<InvestmentEntity>>> getInvestments();
  Future<Either<Failure, void>> invest(String symbol, double amount);
  Future<Either<Failure, void>> sell(String investmentId, double amount);
}
