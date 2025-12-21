import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/core/theme/app_colors.dart';

class InsightsTabScreen extends ConsumerWidget {
  const InsightsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletStateProvider);
    final transactions = walletState.transactions;
    final theme = Theme.of(context);

    double totalIncome = 0;
    double totalExpense = 0;
    double maxTx = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.credit) {
        totalIncome += tx.amount;
      } else {
        totalExpense +=
            tx.amount.abs(); // stored as negative? Check DataSource.
        // Step 622: transferMoney sets amount: -amountVal. So yes, negative.
        // But getWalletAnalytics step 625 used just amount check.
        // Entity might store raw amount.
        // Let's assume Entity field amount is Signed.
        // So .abs() is safe.
      }
      if (tx.amount.abs() > maxTx) maxTx = tx.amount.abs();
    }

    // Fix for totalExpense if logic above was flawed (e.g. if debit is positive in entity but type is debit):
    // TransactionEntity usually reflects DB.
    // If DB has -50, Entity has -50.

    // Chart Y Axis Max
    final maxY =
        (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.2;
    final effectiveMaxY = maxY == 0 ? 100.0 : maxY;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Insights'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cash Flow',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: effectiveMaxY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        // tooltipBgColor: Colors.blueGrey, // Removed due to deprecation potential or theme usage
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.toStringAsFixed(1),
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Income',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold));
                              case 1:
                                return const Text('Expense',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold));
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                              showTitles:
                                  false)), // Hide Y numbers for clean look
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                            toY: totalIncome,
                            color: Colors.green,
                            width: 40,
                            borderRadius: BorderRadius.circular(4))
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                            toY: totalExpense,
                            color: Colors.red,
                            width: 40,
                            borderRadius: BorderRadius.circular(4))
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Highlights',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              context,
              'Total Income',
              '+ ${totalIncome.toStringAsFixed(2)}',
              Icons.arrow_upward,
              Colors.green,
            ),
            _buildInsightCard(
              context,
              'Total Expense',
              '- ${totalExpense.toStringAsFixed(2)}',
              Icons.arrow_downward,
              Colors.red,
            ),
            _buildInsightCard(
              context,
              'Net Flow',
              (totalIncome - totalExpense).toStringAsFixed(2),
              Icons.account_balance,
              (totalIncome - totalExpense) >= 0 ? Colors.blue : Colors.orange,
            ),
            if (transactions.isNotEmpty)
              _buildInsightCard(
                context,
                'Largest Transaction',
                maxTx.toStringAsFixed(2),
                Icons.star,
                Colors.purple,
              ),
            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("No transactions yet."),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side:
            BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
