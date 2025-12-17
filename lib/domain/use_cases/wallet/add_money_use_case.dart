import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class AddMoneyUseCase {
  final WalletRepository repository;

  AddMoneyUseCase(this.repository);

  Future<Either<Failure, void>> execute(String amount, String currency) async {
    return await repository.addMoney(amount, currency);
  }
}
