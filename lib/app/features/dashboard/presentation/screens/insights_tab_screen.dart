import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/domain/entities/enums.dart';

class InsightsTabScreen extends ConsumerWidget {
  const InsightsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletStateProvider);
    final transactions = walletState.transactions;
    final theme = Theme.of(context);

    double income = 0;
    double expense = 0;
    for (var tx in transactions) {
      if (tx.type == TransactionType.credit)
        income += tx.amount;
      else
        expense += tx.amount.abs();
    }

    final maxY = (income > expense ? income : expense) * 1.2;
    final chartMaxY = maxY == 0 ? 100.0 : maxY;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Analytics',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Summary Card
            _buildNetFlowCard(context, income, expense),
            const SizedBox(height: 32),

            Text("Cash Flow Analysis",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Modern Chart Container
            Container(
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: theme.colorScheme.primaryContainer,
                      getTooltipItem: (g, gi, r, ri) => BarTooltipItem(
                          "\$${r.toY.toInt()}",
                          TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) {
                          final style = TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12);
                          if (v == 0)
                            return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text("INCOME", style: style));
                          if (v == 1)
                            return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text("EXPENSE", style: style));
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _barGroup(0, income, theme.colorScheme.primary),
                    _barGroup(1, expense, Colors.redAccent),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Text("Breakdown",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _insightRow(context, "Monthly Earnings", income,
                Icons.arrow_upward_rounded, Colors.green),
            _insightRow(context, "Spendings", expense,
                Icons.arrow_downward_rounded, Colors.red),
            _insightRow(
                context,
                "Savings Rate",
                income > 0 ? ((income - expense) / income * 100) : 0,
                Icons.pie_chart_outline_rounded,
                Colors.orange,
                isPercent: true),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          backDrawRodData: BackgroundBarChartRodData(
              show: true, toY: 100, color: color.withOpacity(0.05)),
        ),
      ],
    );
  }

  Widget _buildNetFlowCard(
      BuildContext context, double income, double expense) {
    final theme = Theme.of(context);
    final net = income - expense;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withBlue(255)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("NET FLOW",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          Text("\$${net.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Row(
            children: [
              _miniStat(Icons.trending_up, "+\$${income.toInt()}", "Inflow"),
              const SizedBox(width: 40),
              _miniStat(
                  Icons.trending_down, "-\$${expense.toInt()}", "Outflow"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(val,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
      ],
    );
  }

  Widget _insightRow(BuildContext context, String title, double val,
      IconData icon, Color color,
      {bool isPercent = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => HapticFeedback.lightImpact(),
        tileColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: Text(
          isPercent ? "${val.toInt()}%" : "\$${val.toInt()}",
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
