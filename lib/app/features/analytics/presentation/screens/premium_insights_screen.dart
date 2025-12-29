import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';

class PremiumInsightsScreen extends ConsumerWidget {
  const PremiumInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final walletState = ref.watch(walletStateProvider);
    final transactions = walletState.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Insights'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSummaryCard(context, transactions),
          const SizedBox(height: 32),
          Text(
            'Spending Breakdown',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSpendingPieChart(context, transactions),
          const SizedBox(height: 32),
          Text(
            'Spending Trends',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSpendingLineChart(context, transactions),
          const SizedBox(height: 32),
          _buildInsightCards(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, List<Transaction> transactions) {
    final theme = Theme.of(context);
    final totalSpent = transactions
        .where((tx) => tx.type == TransactionType.debit)
        .fold(0.0, (sum, tx) => sum + tx.amount);

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
          const Text('Total Spent this Month',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            '\$${totalSpent.toStringAsFixed(2)}',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingPieChart(
      BuildContext context, List<Transaction> transactions) {
    final categoryMap = <String, double>{};

    for (final tx
        in transactions.where((tx) => tx.type == TransactionType.debit)) {
      categoryMap[tx.description] =
          (categoryMap[tx.description] ?? 0.0) + tx.amount;
    }

    final sortedItems = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final chartData = sortedItems.take(5).map((e) {
      return PieChartSectionData(
        value: e.value,
        title: '',
        radius: 60,
        color: _getChartColor(sortedItems.indexOf(e)),
      );
    }).toList();

    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: chartData,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sortedItems.take(5).map((e) {
              final index = sortedItems.indexOf(e);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getChartColor(index),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      e.key.length > 12
                          ? '${e.key.substring(0, 10)}...'
                          : e.key,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingLineChart(
      BuildContext context, List<Transaction> transactions) {
    final theme = Theme.of(context);
    // Group by day for simple trend
    final dailyMap = <int, double>{};
    for (final tx
        in transactions.where((tx) => tx.type == TransactionType.debit)) {
      final day = tx.date.day;
      dailyMap[day] = (dailyMap[day] ?? 0.0) + tx.amount;
    }

    final sortedDays = dailyMap.keys.toList()..sort();
    final spots = sortedDays
        .map((day) => FlSpot(day.toDouble(), dailyMap[day]!))
        .toList();

    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCards(BuildContext context) {
    return Column(
      children: [
        _insightCard(
          context,
          Icons.trending_up_rounded,
          'Increased Spending',
          'Your spending on Food & Dining is up 12% compared to last week.',
          Colors.orange,
        ),
        const SizedBox(height: 16),
        _insightCard(
          context,
          Icons.savings_rounded,
          'Saving Opportunity',
          'You could save \$40/month by switching to a cheaper internet plan.',
          Colors.green,
        ),
      ],
    );
  }

  Widget _insightCard(BuildContext context, IconData icon, String title,
      String desc, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getChartColor(int index) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal
    ];
    return colors[index % colors.length];
  }
}
