import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/investment_entity.dart';
import 'package:paypulse/domain/repositories/investment_repository.dart';
import 'package:paypulse/data/remote/datasources/investment_datasource.dart';

class InvestmentRepositoryImpl implements InvestmentRepository {
  final InvestmentDataSource dataSource;

  InvestmentRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<InvestmentEntity>>> getInvestments() async {
    try {
      final investments = await dataSource.getInvestments();
      return Right(investments);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch investments: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> invest(String symbol, double amount) async {
    try {
      await dataSource.invest(symbol, amount);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to invest: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sell(String investmentId, double amount) async {
    try {
      await dataSource.sell(investmentId, amount);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sell: $e'));
    }
  }
}
