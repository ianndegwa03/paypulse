import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/admin_settings_entity.dart';
import 'package:paypulse/domain/entities/system_stats_entity.dart';
import 'package:paypulse/domain/entities/log_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminSettingsEntity>> getSettings();
  Future<Either<Failure, void>> updateSettings(AdminSettingsEntity settings);
  Future<Either<Failure, SystemStatsEntity>> getSystemStats();
  Stream<List<LogEntity>> getRecentLogs();
}
