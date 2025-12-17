import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/bill_entity.dart';

abstract class BillsRepository {
  Future<Either<Failure, List<BillEntity>>> getBills();
  Future<Either<Failure, void>> payBill(String billId);
}
