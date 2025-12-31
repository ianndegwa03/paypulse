import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/app/features/wallet/presentation/state/sms_analytics_provider.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/core/theme/app_colors.dart';

class InsightsTabScreen extends ConsumerStatefulWidget {
  const InsightsTabScreen({super.key});

  @override
  ConsumerState<InsightsTabScreen> createState() => _InsightsTabScreenState();
}

class _InsightsTabScreenState extends ConsumerState<InsightsTabScreen> {
  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletStateProvider);
    final smsState = ref.watch(smsAnalyticsNotifierProvider);
    final theme = Theme.of(context);

    // Aggregate data
    double income = smsState.summary?.totalIncome ?? 0;
    double expense = smsState.summary?.totalExpense ?? 0;

    if (!smsState.isEnabled) {
      for (var tx in walletState.transactions) {
        if (tx.type == TransactionType.credit)
          income += tx.amount;
        else
          expense += tx.amount.abs();
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(theme),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSummaryCard(theme, income, expense)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                const SizedBox(height: 48),
                _buildSectionHeader(
                    theme, "Spending Breakdown", Icons.pie_chart_rounded),
                const SizedBox(height: 20),
                _buildCategoryChart(theme, smsState)
                    .animate()
                    .fadeIn(delay: 200.ms),
                const SizedBox(height: 48),
                _buildSectionHeader(
                    theme, "Top Velocity Merchants", Icons.storefront_rounded),
                const SizedBox(height: 20),
                _buildMerchantList(theme, smsState)
                    .animate()
                    .fadeIn(delay: 400.ms),
                const SizedBox(height: 140),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          'Financial Insights',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, double income, double expense) {
    final net = income - expense;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(theme, "Income", income, AppColors.income),
              _statItem(theme, "Expenses", expense, AppColors.expense),
            ],
          ),
          const Divider(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Net Cashflow",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                "${net >= 0 ? '+' : ''}\$${net.toStringAsFixed(0)}",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: net >= 0 ? AppColors.income : AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(ThemeData theme, String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 4),
        Text("\$${amount.toStringAsFixed(0)}",
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCategoryChart(ThemeData theme, SMSAnalyticsState smsState) {
    final categories = smsState.topCategories;
    if (categories.isEmpty)
      return const Center(child: Text("No data to display"));

    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 30,
                sections: categories.asMap().entries.map((e) {
                  return PieChartSectionData(
                    radius: 20,
                    value: e.value.value,
                    color: AppColors
                        .chartColors[e.key % AppColors.chartColors.length],
                    title: '',
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: categories
                  .take(4)
                  .map((c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(c.key,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis)),
                            Text("${c.value.toInt()}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantList(ThemeData theme, SMSAnalyticsState smsState) {
    final merchants = smsState.topMerchants;
    if (merchants.isEmpty)
      return const Center(child: Text("No merchants tracked"));

    return Column(
      children: merchants
          .take(5)
          .map((m) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: Icon(Icons.storefront_rounded,
                          size: 18, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Text(m.key,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
                    Text("\$${m.value.toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
