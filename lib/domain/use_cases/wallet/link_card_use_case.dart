import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/card_entity.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class LinkCardUseCase {
  final WalletRepository repository;

  LinkCardUseCase(this.repository);

  Future<Either<Failure, void>> execute(CardEntity card) async {
    return await repository.linkCard(card);
  }
}
