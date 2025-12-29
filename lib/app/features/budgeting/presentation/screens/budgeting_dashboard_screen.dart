import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/budgeting/presentation/state/budget_provider.dart';
import 'package:paypulse/domain/entities/budget_entity.dart';

class BudgetingDashboardScreen extends ConsumerWidget {
  const BudgetingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final budgetState = ref.watch(budgetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgeting'),
      ),
      body: budgetState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildOverviewCard(context, budgetState),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category Budgets',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (budgetState.budgets.isEmpty)
                  _buildEmptyState(context)
                else
                  ...budgetState.budgets
                      .map((budget) => _BudgetCard(budget: budget)),
              ],
            ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, BudgetState state) {
    final theme = Theme.of(context);
    final totalBudget =
        state.budgets.fold(0.0, (sum, b) => sum + b.limitAmount);
    final totalSpent =
        state.budgets.fold(0.0, (sum, b) => sum + b.currentSpent);
    final progress = totalBudget > 0 ? totalSpent / totalBudget : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Overview',
                  style: TextStyle(color: Colors.grey)),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color:
                      progress > 0.9 ? Colors.red : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress > 1.0 ? 1.0 : progress,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.9 ? Colors.red : theme.colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem('Total Budget', '\$${totalBudget.toStringAsFixed(0)}'),
              _statItem('Spent', '\$${totalSpent.toStringAsFixed(0)}'),
              _statItem('Remaining',
                  '\$${(totalBudget - totalSpent).toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No budgets set yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;

  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = budget.progress;
    final isOver = budget.isOverBudget;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.category_rounded,
                        size: 20, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    budget.categoryId ?? 'Uncategorized',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '\$${budget.limitAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress > 1.0 ? 1.0 : progress,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(
              isOver ? Colors.red : theme.colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${budget.currentSpent.toStringAsFixed(0)} spent',
                style: TextStyle(
                    fontSize: 12, color: isOver ? Colors.red : Colors.grey),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
