import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/admin_settings_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminSettingsEntity>> getSettings();
  Future<Either<Failure, void>> updateSettings(AdminSettingsEntity settings);
}
