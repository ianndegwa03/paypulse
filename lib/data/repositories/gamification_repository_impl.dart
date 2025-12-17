import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/data/remote/datasources/gamification_datasource.dart';
import 'package:paypulse/domain/entities/gamification_profile_entity.dart';
import 'package:paypulse/domain/repositories/gamification_repository.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationDataSource dataSource;

  GamificationRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, GamificationProfileEntity>> getProfile() async {
    try {
      final profile = await dataSource.getProfile();
      return Right(profile);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to fetch gamification profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addPoints(int points) async {
    try {
      await dataSource.addPoints(points);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add points: $e'));
    }
  }
}
