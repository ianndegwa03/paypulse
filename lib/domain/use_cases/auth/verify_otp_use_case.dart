import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, void>> execute(String otp,
      {required bool isEmail}) async {
    if (isEmail) {
      // In a real scenario, this might need a token which is the OTP
      return await repository.verifyEmail(otp);
    } else {
      return await repository.verifyPhone(otp);
    }
  }
}
