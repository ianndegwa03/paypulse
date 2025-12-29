import 'package:paypulse/domain/entities/log_entity.dart';
import 'package:paypulse/domain/repositories/admin_repository.dart';

class GetRecentLogsUseCase {
  final AdminRepository repository;

  GetRecentLogsUseCase(this.repository);

  Stream<List<LogEntity>> call() {
    return repository.getRecentLogs();
  }
}
