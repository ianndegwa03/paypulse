import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';
import 'package:paypulse/domain/entities/user_entity.dart';

class PinLoginUseCase {
  final AuthRepository repository;

  PinLoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute(String pin) async {
    return await repository.loginWithPin(pin);
  }
}
