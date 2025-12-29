import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/vault_entity.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class CreateVaultUseCase {
  final WalletRepository repository;

  CreateVaultUseCase(this.repository);

  Future<Either<Failure, void>> execute(VaultEntity vault) async {
    return await repository.createVault(vault);
  }
}
