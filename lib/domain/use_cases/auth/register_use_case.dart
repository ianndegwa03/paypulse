import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';
import 'package:paypulse/domain/entities/user_entity.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    return await repository.register(
        email, password, username, firstName, lastName);
  }
}
