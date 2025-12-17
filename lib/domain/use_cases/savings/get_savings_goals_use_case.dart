import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/savings_goal_entity.dart';
import 'package:paypulse/domain/repositories/savings_repository.dart';

class GetSavingsGoalsUseCase {
  final SavingsRepository repository;

  GetSavingsGoalsUseCase(this.repository);

  Future<Either<Failure, List<SavingsGoalEntity>>> call() {
    return repository.getSavingsGoals();
  }
}
