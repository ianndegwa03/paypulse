import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/analytics/presentation/state/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pulse Analytics",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        actions: [
          IconButton(
            onPressed: () => ref.read(analyticsProvider.notifier).loadData(),
            icon: const Icon(Icons.refresh_rounded),
          )
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Financial Health (6 Months)",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final now = DateTime.now();
                                    final monthDate = DateTime(now.year,
                                        now.month - (6 - value.toInt()));
                                    final labels = [
                                      'Jan',
                                      'Feb',
                                      'Mar',
                                      'Apr',
                                      'May',
                                      'Jun',
                                      'Jul',
                                      'Aug',
                                      'Sep',
                                      'Oct',
                                      'Nov',
                                      'Dec'
                                    ];

                                    if (value.toInt() >= 1 &&
                                        value.toInt() <= 6) {
                                      return Text(labels[monthDate.month - 1],
                                          style: const TextStyle(fontSize: 10));
                                    }
                                    return const Text('');
                                  },
                                  interval: 1)),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: state.incomeData,
                            isCurved: true,
                            color: Colors.greenAccent,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                                show: true,
                                color: Colors.greenAccent.withOpacity(0.1)),
                          ),
                          LineChartBarData(
                            spots: state.expenseData,
                            isCurved: true,
                            color: Colors.redAccent,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                                show: true,
                                color: Colors.redAccent.withOpacity(0.1)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendItem(Colors.greenAccent, "Income"),
                      const SizedBox(width: 16),
                      _legendItem(Colors.redAccent, "Expenses"),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text("Spending Breakdown",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _getPieSections(state.categories),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...state.categories.entries.map((e) => ListTile(
                        leading: CircleAvatar(
                            backgroundColor: _getColor(e.key), radius: 6),
                        title: Text(e.key),
                        trailing: Text("\$${e.value.toStringAsFixed(0)}",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        dense: true,
                      )),
                ],
              ),
            ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  List<PieChartSectionData> _getPieSections(Map<String, double> categories) {
    return categories.entries.map((e) {
      return PieChartSectionData(
        color: _getColor(e.key),
        value: e.value,
        title:
            '${(e.value / _totalSpending(categories) * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  double _totalSpending(Map<String, double> categories) {
    return categories.values.fold(0, (sum, item) => sum + item);
  }

  Color _getColor(String key) {
    switch (key) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Rent':
        return Colors.purple;
      case 'Entertainment':
        return Colors.pink;
      case 'Shopping':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
