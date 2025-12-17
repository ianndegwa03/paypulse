import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class TransferMoneyUseCase {
  final WalletRepository repository;

  TransferMoneyUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String recipientId,
    required String amount,
    required String currency,
  }) async {
    return await repository.transferMoney(
      recipientId: recipientId,
      amount: amount,
      currency: currency,
    );
  }
}
