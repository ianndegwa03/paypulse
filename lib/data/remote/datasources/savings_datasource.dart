import 'package:paypulse/data/models/savings_goal_model.dart';
import 'package:paypulse/domain/entities/enums.dart';

abstract class SavingsDataSource {
  Future<List<SavingsGoalModel>> getSavingsGoals();
  Future<void> createGoal(SavingsGoalModel goal);
  Future<void> contribute(String goalId, double amount);
}

class SavingsDataSourceImpl implements SavingsDataSource {
  @override
  Future<List<SavingsGoalModel>> getSavingsGoals() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      SavingsGoalModel(
        id: '1',
        name: 'New Car',
        targetAmount: 20000.0,
        currentAmount: 5500.0,
        currency: CurrencyType.USD,
        deadline: DateTime.now().add(const Duration(days: 300)),
        imageUrl: 'https://example.com/car.png',
      ),
      SavingsGoalModel(
        id: '2',
        name: 'Europe Trip',
        targetAmount: 5000.0,
        currentAmount: 1200.0,
        currency: CurrencyType.EUR,
        deadline: DateTime.now().add(const Duration(days: 90)),
      ),
    ];
  }

  @override
  Future<void> createGoal(SavingsGoalModel goal) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<void> contribute(String goalId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}
