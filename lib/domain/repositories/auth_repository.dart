import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);

  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
    String firstName,
    String lastName,
  );

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, bool>> isAuthenticated();

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, void>> forgotPassword(String email);

  Future<Either<Failure, void>> resetPassword(
    String token,
    String newPassword,
  );

  Future<Either<Failure, void>> updateProfile(UserEntity user);

  Future<Either<Failure, void>> enableBiometric(bool enable);

  Future<Either<Failure, void>> verifyEmail(String token);

  Future<Either<Failure, void>> verifyPhone(String code);

  // Social login methods
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, UserEntity>> signInWithApple();
}
