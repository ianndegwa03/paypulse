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
    bool isPremium = false,
  }) async {
    final double amountVal = double.tryParse(amount) ?? 0.0;
    final double fee =
        isPremium ? 0.0 : (amountVal * 0.015); // 1.5% fee for free users

    return await repository.transferMoney(
      recipientId: recipientId,
      amount: amount,
      currency: currency,
      fee: fee,
    );
  }
}
