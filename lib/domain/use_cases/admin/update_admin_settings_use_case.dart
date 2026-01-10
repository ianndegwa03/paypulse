import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures/failure.dart';
import 'package:paypulse/domain/entities/admin_settings_entity.dart';
import 'package:paypulse/domain/repositories/admin_repository.dart';

class UpdateAdminSettingsUseCase {
  final AdminRepository repository;

  UpdateAdminSettingsUseCase(this.repository);

  Future<Either<Failure, void>> call(AdminSettingsEntity settings) async {
    return await repository.updateAdminSettings(settings);
  }
}
