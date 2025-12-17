import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/gamification_profile_entity.dart';

abstract class GamificationRepository {
  Future<Either<Failure, GamificationProfileEntity>> getProfile();
  Future<Either<Failure, void>> addPoints(int points);
}
