import 'package:dartz/dartz.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/data/models/savings_goal_model.dart';
import 'package:paypulse/data/remote/datasources/savings_datasource.dart';
import 'package:paypulse/domain/entities/savings_goal_entity.dart';
import 'package:paypulse/domain/repositories/savings_repository.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  final SavingsDataSource dataSource;

  SavingsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<SavingsGoalEntity>>> getSavingsGoals() async {
    try {
      final goals = await dataSource.getSavingsGoals();
      return Right(goals);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch savings goals: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createGoal(SavingsGoalEntity goal) async {
    try {
      final model = SavingsGoalModel(
        id: goal.id,
        name: goal.name,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        currency: goal.currency,
        deadline: goal.deadline,
        imageUrl: goal.imageUrl,
      );
      await dataSource.createGoal(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create goal: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> contribute(String goalId, double amount) async {
    try {
      await dataSource.contribute(goalId, amount);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to contribute: $e'));
    }
  }
}
