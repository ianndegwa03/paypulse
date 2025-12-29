import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class UpdateWalletUseCase {
  final WalletRepository repository;

  UpdateWalletUseCase(this.repository);

  Future<Either<Failure, void>> execute(Wallet wallet) async {
    return await repository.updateWallet(wallet);
  }
}
