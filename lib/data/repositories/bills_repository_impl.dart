import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';

import 'package:paypulse/data/remote/datasources/bills_datasource.dart';
import 'package:paypulse/domain/entities/bill_entity.dart';
import 'package:paypulse/domain/repositories/bills_repository.dart';

class BillsRepositoryImpl implements BillsRepository {
  final BillsDataSource dataSource;

  BillsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<BillEntity>>> getBills() async {
    try {
      final bills = await dataSource.getBills();
      return Right(bills);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch bills: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> payBill(String billId) async {
    try {
      await dataSource.payBill(billId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to pay bill: $e'));
    }
  }
}
