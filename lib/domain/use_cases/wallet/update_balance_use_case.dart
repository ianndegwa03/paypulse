import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class UpdateBalanceUseCase {
  final WalletRepository repository;

  UpdateBalanceUseCase(this.repository);

  Future<Either<Failure, void>> execute() async {
    // This could trigger a sync with backend
    final result = await repository.getWallet();
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null), // Successfully fetched updated wallet
    );
  }
}
