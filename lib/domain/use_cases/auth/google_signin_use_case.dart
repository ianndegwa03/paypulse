import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';
import 'package:paypulse/domain/entities/user_entity.dart';

/// Use case for Google Sign-In
class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute() async {
    return await repository.signInWithGoogle();
  }
}
