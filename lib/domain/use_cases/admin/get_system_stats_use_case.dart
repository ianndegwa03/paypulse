import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/system_stats_entity.dart';
import 'package:paypulse/domain/repositories/admin_repository.dart';

class GetSystemStatsUseCase {
  final AdminRepository repository;

  GetSystemStatsUseCase(this.repository);

  Future<Either<Failure, SystemStatsEntity>> call() {
    return repository.getSystemStats();
  }
}
