import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';
import 'package:paypulse/domain/entities/user_entity.dart';

/// Use case for Apple Sign-In
class AppleSignInUseCase {
  final AuthRepository repository;

  AppleSignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute() async {
    return await repository.signInWithApple();
  }
}
