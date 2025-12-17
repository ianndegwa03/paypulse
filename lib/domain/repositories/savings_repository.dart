import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/domain/entities/savings_goal_entity.dart';

abstract class SavingsRepository {
  Future<Either<Failure, List<SavingsGoalEntity>>> getSavingsGoals();
  Future<Either<Failure, void>> createGoal(SavingsGoalEntity goal);
  Future<Either<Failure, void>> contribute(String goalId, double amount);
}
