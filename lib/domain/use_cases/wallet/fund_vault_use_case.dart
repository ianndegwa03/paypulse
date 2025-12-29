import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class FundVaultUseCase {
  final WalletRepository repository;

  FundVaultUseCase(this.repository);

  Future<Either<Failure, void>> execute(String vaultId, double amount) async {
    return await repository.fundVault(vaultId, amount);
  }
}
