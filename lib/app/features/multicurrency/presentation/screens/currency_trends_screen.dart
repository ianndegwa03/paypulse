import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:paypulse/app/features/wallet/presentation/state/currency_provider.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/domain/entities/enums.dart';

class CurrencyTrendsScreen extends ConsumerWidget {
  const CurrencyTrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyState = ref.watch(currencyProvider);
    final walletState = ref.watch(walletStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("PRO Market Insights",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPerformanceSummary(context, currencyState, walletState),
            const SizedBox(height: 32),
            Text("TREND ANALYSIS",
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
            const SizedBox(height: 16),
            _buildMarketChart(context, currencyState.selectedCurrency),
            const SizedBox(height: 32),
            Text("SMART CONVERT ALERTS",
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
            const SizedBox(height: 16),
            _buildSmartAlerts(context, currencyState),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary(
      BuildContext context, CurrencyState currencyState, dynamic walletState) {
    final theme = Theme.of(context);

    // Calculate total unrealized P/L in USD
    double totalPLVal = 0.0;
    walletState.wallet?.balances.forEach((code, amount) {
      if (code == 'USD') return;
      final type = CurrencyType.values
          .firstWhere((e) => e.name == code, orElse: () => CurrencyType.USD);
      final currentRate = currencyState.getRate(CurrencyType.USD, type);
      final basisRate = walletState.wallet?.costBasis[code] ?? currentRate;

      if (basisRate > 0 && currentRate > 0) {
        final currentUSDValue = amount / currentRate;
        final costUSDValue = amount / basisRate;
        totalPLVal += (currentUSDValue - costUSDValue);
      }
    });

    final isProfit = totalPLVal >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Portfolio Yield (Unrealized)",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      (isProfit ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  "${isProfit ? '▲' : '▼'} ${totalPLVal.abs().toStringAsFixed(2)} USD",
                  style: TextStyle(
                    color: isProfit ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            "Based on live multi-source market spreads. Pulse Premium selects the optimized rate for your holdings.",
            style: TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMarketChart(BuildContext context, CurrencyType selected) {
    final theme = Theme.of(context);

    // Mock trend data
    final dataPoints = [
      const FlSpot(0, 150),
      const FlSpot(1, 152),
      const FlSpot(2, 148),
      const FlSpot(3, 145),
      const FlSpot(4, 147),
      const FlSpot(5, 142),
      const FlSpot(6, 140),
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 24, right: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartAlerts(BuildContext context, CurrencyState state) {
    return Column(
      children: [
        _buildAlertItem(
          context,
          "JPY Opportunity",
          "Yen has dropped 3% against USD. Smart Convert suggests increasing JPY holdings for upcoming travels.",
          Icons.trending_down_rounded,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildAlertItem(
          context,
          "KES Strength",
          "KES is at a 6-month high. Consider moving profits to USD to lock in gains.",
          Icons.trending_up_rounded,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildAlertItem(BuildContext context, String title, String description,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ),
        ],
      ),
    );
  }
}
