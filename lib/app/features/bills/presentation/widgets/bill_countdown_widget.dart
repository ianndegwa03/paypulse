import 'package:flutter/material.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';

/// Countdown widget showing days until bill is due
class BillCountdownWidget extends StatelessWidget {
  final String billName;
  final double amount;
  final int daysUntilDue;
  final bool isPaid;
  final VoidCallback? onTap;

  const BillCountdownWidget({
    super.key,
    required this.billName,
    required this.amount,
    required this.daysUntilDue,
    this.isPaid = false,
    this.onTap,
  });

  Color get _statusColor {
    if (isPaid) return PulseDesign.success;
    if (daysUntilDue < 0) return PulseDesign.error;
    if (daysUntilDue <= 3) return PulseDesign.warning;
    return PulseDesign.primary;
  }

  String get _statusText {
    if (isPaid) return 'PAID';
    if (daysUntilDue < 0) return 'OVERDUE';
    if (daysUntilDue == 0) return 'DUE TODAY';
    if (daysUntilDue == 1) return 'TOMORROW';
    return '$daysUntilDue DAYS';
  }

  IconData get _statusIcon {
    if (isPaid) return Icons.check_circle_rounded;
    if (daysUntilDue < 0) return Icons.error_rounded;
    if (daysUntilDue <= 3) return Icons.warning_rounded;
    return Icons.schedule_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _statusColor.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _statusColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Countdown circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _statusColor,
                    _statusColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Center(
                child: isPaid
                    ? Icon(Icons.check_rounded, color: Colors.white, size: 28)
                    : Text(
                        '${daysUntilDue.abs()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Bill info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    billName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isPaid ? Colors.grey : theme.colorScheme.onSurface,
                    decoration: isPaid
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                if (!isPaid)
                  Text(
                    'due',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal list of upcoming bills
class BillsCountdownList extends StatelessWidget {
  final List<BillCountdownData> bills;

  const BillsCountdownList({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedBills = [...bills]
      ..sort((a, b) => a.daysUntilDue.compareTo(b.daysUntilDue));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.receipt_long_rounded,
                  size: 18, color: PulseDesign.primary),
              const SizedBox(width: 8),
              Text(
                'UPCOMING BILLS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: PulseDesign.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedBills.length,
            itemBuilder: (context, index) {
              final bill = sortedBills[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _CompactBillChip(
                  name: bill.name,
                  amount: bill.amount,
                  daysUntilDue: bill.daysUntilDue,
                  isPaid: bill.isPaid,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CompactBillChip extends StatelessWidget {
  final String name;
  final double amount;
  final int daysUntilDue;
  final bool isPaid;

  const _CompactBillChip({
    required this.name,
    required this.amount,
    required this.daysUntilDue,
    required this.isPaid,
  });

  Color get _color {
    if (isPaid) return PulseDesign.success;
    if (daysUntilDue < 0) return PulseDesign.error;
    if (daysUntilDue <= 3) return PulseDesign.warning;
    return PulseDesign.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_color, _color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            isPaid
                ? 'Paid ✓'
                : (daysUntilDue == 0 ? 'Today!' : '${daysUntilDue}d left'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple data class for bill countdown
class BillCountdownData {
  final String name;
  final double amount;
  final int daysUntilDue;
  final bool isPaid;

  const BillCountdownData({
    required this.name,
    required this.amount,
    required this.daysUntilDue,
    this.isPaid = false,
  });
}
