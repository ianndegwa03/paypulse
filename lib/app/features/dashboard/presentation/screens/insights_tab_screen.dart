import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:paypulse/core/theme/app_colors.dart';

class InsightsTabScreen extends StatelessWidget {
  const InsightsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Insights'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
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
                    maxY: 1000,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment'];
                            if (value.toInt() < categories.length) {
                              return Text(categories[value.toInt()], style: const TextStyle(fontSize: 12));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text('\$${value.toInt()}');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 450, color: AppColors.primary)]),
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 320, color: AppColors.secondary)]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 680, color: AppColors.accent)]),
                      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 520, color: Colors.orange)]),
                      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 280, color: Colors.purple)]),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Key Insights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              'Highest Spending',
              'Shopping - \$680',
              Icons.shopping_cart,
              AppColors.accent,
            ),
            _buildInsightCard(
              'Monthly Savings',
              '\$1,250 saved this month',
              Icons.savings,
              Colors.green,
            ),
            _buildInsightCard(
              'Budget Alert',
              'Entertainment budget exceeded by 15%',
              Icons.warning,
              Colors.red,
            ),
            _buildInsightCard(
              'Trend',
              'Spending decreased by 8% from last month',
              Icons.trending_down,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
