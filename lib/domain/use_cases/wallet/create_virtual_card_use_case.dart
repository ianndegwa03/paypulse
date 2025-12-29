import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/virtual_card_entity.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class CreateVirtualCardUseCase {
  final WalletRepository repository;

  CreateVirtualCardUseCase(this.repository);

  Future<Either<Failure, void>> execute(VirtualCardEntity card) async {
    return await repository.createVirtualCard(card);
  }
}
