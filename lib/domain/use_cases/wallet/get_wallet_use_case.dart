import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/wallet_entity.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class GetWalletUseCase {
  final WalletRepository repository;

  GetWalletUseCase(this.repository);

  // Return stream for real-time updates
  Stream<Wallet> executeStream() {
    return repository.getWalletStream();
  }

  // Return future for one-time fetch
  Future<Either<Failure, Wallet>> execute() async {
    return repository.getWallet();
  }
}
