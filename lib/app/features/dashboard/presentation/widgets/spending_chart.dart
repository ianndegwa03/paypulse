import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';

class SpendingChart extends StatelessWidget {
  final List<Transaction> transactions;

  const SpendingChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (transactions.isEmpty) {
      return Center(
        child: Text(
          "No activity to display",
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      );
    }

    // Prepare Spot Data
    // We will just take the last 7 transactions or so for simplicity
    // in a real app, we would aggregate by day.

    // Sort by date
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Take last 7
    final displayData =
        sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;

    final spots = displayData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.amount);
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, right: 10.0, left: 10),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: theme.colorScheme.onSurface.withOpacity(0.8),
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '\$${spot.y.toStringAsFixed(2)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 50,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.outline.withOpacity(0.05),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < displayData.length) {
                    final date = displayData[index].date;
                    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    return Text(
                      days[date.weekday - 1],
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (displayData.length - 1).toDouble() > 0
              ? (displayData.length - 1).toDouble()
              : 6,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
