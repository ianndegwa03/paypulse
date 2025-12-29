import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/data/remote/datasources/admin_datasource.dart';
import 'package:paypulse/domain/entities/admin_settings_entity.dart';
import 'package:paypulse/domain/entities/system_stats_entity.dart';
import 'package:paypulse/domain/entities/log_entity.dart';
import 'package:paypulse/domain/repositories/admin_repository.dart';
import 'package:paypulse/core/services/feature_flag_service.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminDataSource dataSource;
  final FeatureFlagService featureFlagService;

  AdminRepositoryImpl({
    required this.dataSource,
    required this.featureFlagService,
  });

  @override
  Future<Either<Failure, AdminSettingsEntity>> getSettings() async {
    try {
      final settings = await dataSource.getSettings();
      // Update local feature flags when fetching
      featureFlagService.updateSettings(settings);
      return Right(settings);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch admin settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(
      AdminSettingsEntity settings) async {
    try {
      await dataSource.updateSettings(settings);
      // Update local feature flags immediately after update
      featureFlagService.updateSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to update admin settings: $e'));
    }
  }

  @override
  Future<Either<Failure, SystemStatsEntity>> getSystemStats() async {
    try {
      final stats = await dataSource.getSystemStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch system stats: $e'));
    }
  }

  @override
  Stream<List<LogEntity>> getRecentLogs() {
    return dataSource.getRecentLogs();
  }
}
