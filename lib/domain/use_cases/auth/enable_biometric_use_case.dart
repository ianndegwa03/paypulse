import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/repositories/auth_repository.dart';

class EnableBiometricUseCase {
  final AuthRepository _repository;

  EnableBiometricUseCase(this._repository);

  Future<Either<Failure, void>> execute(bool enable) async {
    return await _repository.enableBiometric(enable);
  }
}
