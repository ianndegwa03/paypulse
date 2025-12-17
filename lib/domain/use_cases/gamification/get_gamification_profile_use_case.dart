import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/gamification_profile_entity.dart';
import 'package:paypulse/domain/repositories/gamification_repository.dart';

class GetGamificationProfileUseCase {
  final GamificationRepository repository;

  GetGamificationProfileUseCase(this.repository);

  Future<Either<Failure, GamificationProfileEntity>> call() {
    return repository.getProfile();
  }
}
