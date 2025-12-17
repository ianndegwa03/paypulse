import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/admin_settings_entity.dart';
import 'package:paypulse/domain/repositories/admin_repository.dart';

class GetAdminSettingsUseCase {
  final AdminRepository repository;

  GetAdminSettingsUseCase(this.repository);

  Future<Either<Failure, AdminSettingsEntity>> call() {
    return repository.getSettings();
  }
}
