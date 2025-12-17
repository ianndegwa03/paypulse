import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';
import 'package:paypulse/domain/entities/user_entity.dart';

class BiometricLoginUseCase {
  final AuthRepository repository;

  BiometricLoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute() async {
    // Check if biometric is enabled locally
    // In a real flow, this would trigger local auth and then perhaps exchange a stored token
    // For now, we'll try to get the current user if authenticated

    final authenticated = await repository.isAuthenticated();
    return authenticated.fold((failure) => Left(failure), (isAuth) async {
      if (isAuth) {
        return await repository.getCurrentUser();
      } else {
        return const Left(AuthFailure(
            message: 'Biometric authentication failed or not available'));
      }
    });
  }
}
