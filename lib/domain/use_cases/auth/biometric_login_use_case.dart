import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';
import 'package:paypulse/domain/entities/user_entity.dart';
import 'package:paypulse/core/services/biometric/biometric_service.dart';

class BiometricLoginUseCase {
  final AuthRepository repository;
  final BiometricService biometricService;

  BiometricLoginUseCase(this.repository, this.biometricService);

  Future<Either<Failure, UserEntity>> execute() async {
    try {
      // 1. Authenticate with biometrics
      final didAuth = await biometricService.authenticateForLogin();
      if (!didAuth) {
        return const Left(
            AuthFailure(message: 'Biometric authentication cancelled'));
      }

      // 2. Retrieve stored credentials
      final credsJson =
          await biometricService.getBiometricCredentials('default');
      if (credsJson == null) {
        return const Left(AuthFailure(
            message:
                'No biometric credentials found. Please login manually first.'));
      }

      final creds = json.decode(credsJson);
      final email = creds['email'] as String;
      final password = creds['password'] as String;

      // 3. Perform login
      return await repository.login(email, password);
    } catch (e) {
      return Left(AuthFailure(message: 'Biometric login failed: $e'));
    }
  }
}
