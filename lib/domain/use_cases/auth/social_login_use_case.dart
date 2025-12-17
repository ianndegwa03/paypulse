import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';
import 'package:paypulse/domain/entities/user_entity.dart';

class SocialLoginUseCase {
  final AuthRepository repository;

  SocialLoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute(
      String provider, String token) async {
    // Placeholder as Repository doesn't support social login yet
    return const Left(AuthFailure(message: 'Social login not yet implemented'));
  }
}
