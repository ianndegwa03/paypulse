import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';

/// Spending heatmap calendar showing daily spending intensity
class SpendingHeatmapCalendar extends StatelessWidget {
  final Map<DateTime, double> spendingData; // Date -> total spent
  final double maxDailySpend;

  const SpendingHeatmapCalendar({
    super.key,
    required this.spendingData,
    this.maxDailySpend = 500,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final startWeekday = firstDayOfMonth.weekday % 7; // 0-6 (Sun-Sat)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            DateFormat('MMMM yyyy').format(now).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: PulseDesign.primary,
            ),
          ),
        ),
        // Day labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((d) => SizedBox(
                    width: 36,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startWeekday) {
              return const SizedBox.shrink();
            }

            final day = index - startWeekday + 1;
            final date = DateTime(now.year, now.month, day);
            final spent = spendingData[date] ?? 0;
            final intensity = (spent / maxDailySpend).clamp(0.0, 1.0);

            return _DayCell(
              day: day,
              intensity: intensity,
              isToday: day == now.day,
              theme: theme,
            );
          },
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Less', style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(width: 8),
            ...List.generate(5, (i) {
              return Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _getHeatColor(i / 4),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
            const SizedBox(width: 8),
            Text('More', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Color _getHeatColor(double intensity) {
    if (intensity < 0.2) return Colors.green.shade100;
    if (intensity < 0.4) return Colors.yellow.shade300;
    if (intensity < 0.6) return Colors.orange.shade400;
    if (intensity < 0.8) return Colors.deepOrange.shade500;
    return Colors.red.shade600;
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final double intensity;
  final bool isToday;
  final ThemeData theme;

  const _DayCell({
    required this.day,
    required this.intensity,
    required this.isToday,
    required this.theme,
  });

  Color get _cellColor {
    if (intensity < 0.2) return Colors.green.shade100;
    if (intensity < 0.4) return Colors.yellow.shade300;
    if (intensity < 0.6) return Colors.orange.shade400;
    if (intensity < 0.8) return Colors.deepOrange.shade500;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: intensity > 0 ? _cellColor : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: isToday
            ? Border.all(color: PulseDesign.primary, width: 2)
            : Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
            color: intensity > 0.5
                ? Colors.white
                : theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
