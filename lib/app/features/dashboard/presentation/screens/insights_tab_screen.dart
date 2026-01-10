import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/app/features/wallet/presentation/state/sms_analytics_provider.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';
import 'package:paypulse/core/widgets/premium_cards.dart';
import 'package:permission_handler/permission_handler.dart';

class InsightsTabScreen extends ConsumerStatefulWidget {
  const InsightsTabScreen({super.key});

  @override
  ConsumerState<InsightsTabScreen> createState() => _InsightsTabScreenState();
}

class _InsightsTabScreenState extends ConsumerState<InsightsTabScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  static const List<Color> chartColors = [
    PulseDesign.primary,
    PulseDesign.accent,
    PulseDesign.success,
    PulseDesign.warning,
    PulseDesign.error,
    Color(0xFF06B6D4), // Cyan
    Color(0xFFE11D48), // Rose
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletStateProvider);
    final smsState = ref.watch(smsAnalyticsNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

    final isPremium =
        ref.watch(authNotifierProvider).currentUser?.isPremiumUser ?? false;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildBackgroundEffects(theme, isDark),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverHeader(theme, smsState),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainStatsCard(context, income, expense, theme)
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.1),
                      const SizedBox(height: 24),
                      _buildSMSSyncBanner(theme, smsState),
                      const SizedBox(height: 28),
                      if (isPremium && smsState.insights.isNotEmpty)
                        _buildAIInsightsSection(theme, smsState.insights)
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.1),
                      if (isPremium && smsState.insights.isNotEmpty)
                        const SizedBox(height: 28),
                      if (smsState.isEnabled && smsState.summary != null) ...[
                        _buildSectionHeader(
                            theme, 'Spending Heatmap', Icons.grid_on_rounded),
                        const SizedBox(height: 16),
                        _buildSpendingHeatmap(theme, ref)
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .scale(begin: const Offset(0.95, 0.95)),
                        const SizedBox(height: 28),
                      ],
                      _buildSectionHeader(
                          theme, 'Spending Breakdown', Icons.pie_chart_rounded),
                      const SizedBox(height: 16),
                      _buildCategoryBreakdown(theme, smsState)
                          .animate()
                          .fadeIn(delay: 400.ms),
                      const SizedBox(height: 28),
                      _buildSectionHeader(
                          theme, 'Spending Pulse', Icons.show_chart_rounded),
                      const SizedBox(height: 16),
                      _buildSpendingPulse(theme, smsState)
                          .animate()
                          .fadeIn(delay: 500.ms),
                      const SizedBox(height: 28),
                      if (smsState.topMerchants.isNotEmpty) ...[
                        _buildSectionHeader(theme, 'Top Merchants',
                            Icons.store_mall_directory_rounded),
                        const SizedBox(height: 16),
                        _buildTopMerchants(theme, smsState)
                            .animate()
                            .fadeIn(delay: 600.ms),
                        const SizedBox(height: 28),
                      ],
                      if (smsState.summary?.transactionsByProvider.isNotEmpty ??
                          false) ...[
                        _buildSectionHeader(theme, 'By Provider',
                            Icons.account_balance_rounded),
                        const SizedBox(height: 16),
                        _buildProviderStats(theme, smsState)
                            .animate()
                            .fadeIn(delay: 700.ms),
                      ],
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundEffects(ThemeData theme, bool isDark) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    PulseDesign.accent.withOpacity(isDark ? 0.1 : 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(ThemeData theme, SMSAnalyticsState smsState) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          'Financial Insights',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            children: [
              if (smsState.isEnabled) ...[
                _PulsingDot(
                    color: PulseDesign.accent, controller: _pulseController),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: PulseDesign.accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              CircleAvatar(
                backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
                radius: 18,
                child: Icon(
                  Icons.auto_graph_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatsCard(
      BuildContext context, double income, double expense, ThemeData theme) {
    final net = income - expense;
    final total = income + expense;
    final savingsRate = total > 0 ? (income / total * 100) : 0.0;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NET FLOW',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'KES ${net.toStringAsFixed(0)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: net >= 0 ? PulseDesign.success : PulseDesign.error,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (net >= 0 ? PulseDesign.success : PulseDesign.error)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  net >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: net >= 0 ? PulseDesign.success : PulseDesign.error,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat(
                  theme,
                  'Income',
                  'KES ${income.toStringAsFixed(0)}',
                  PulseDesign.success,
                  Icons.arrow_downward_rounded),
              _buildMiniStat(
                  theme,
                  'Expense',
                  'KES ${expense.toStringAsFixed(0)}',
                  PulseDesign.error,
                  Icons.arrow_upward_rounded),
              _buildMiniStat(
                  theme,
                  'Savings',
                  '${savingsRate.toStringAsFixed(0)}%',
                  PulseDesign.warning,
                  Icons.savings_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      ThemeData theme, String label, String value, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSMSSyncBanner(ThemeData theme, SMSAnalyticsState smsState) {
    return GlassCard(
      onTap: smsState.isEnabled
          ? null
          : () async {
              HapticFeedback.lightImpact();
              final notifier = ref.read(smsAnalyticsNotifierProvider.notifier);
              final success = await notifier.enable();
              if (!success && mounted) {
                _showPermissionDialog();
              }
            },
      padding: const EdgeInsets.all(18),
      borderColor: smsState.isEnabled
          ? PulseDesign.success.withOpacity(0.3)
          : theme.colorScheme.primary.withOpacity(0.2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (smsState.isEnabled
                      ? PulseDesign.success
                      : theme.colorScheme.primary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              smsState.isEnabled ? Icons.sync_rounded : Icons.hub_rounded,
              color: smsState.isEnabled
                  ? PulseDesign.success
                  : theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  smsState.isEnabled ? 'SMS SYNCED' : 'FINANCIAL SYNC',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: smsState.isEnabled
                        ? PulseDesign.success
                        : theme.colorScheme.primary,
                  ),
                ),
                Text(
                  smsState.isEnabled
                      ? '${smsState.transactions.length} transactions tracked'
                      : 'Enable SMS sync for real-time insights',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          if (!smsState.isEnabled)
            const Icon(Icons.chevron_right_rounded, color: Colors.grey)
          else
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                ref.read(smsAnalyticsNotifierProvider.notifier).sync();
              },
              icon: const Icon(Icons.refresh_rounded,
                  color: PulseDesign.success, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsSection(
      ThemeData theme, List<SpendingInsight> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            theme, 'AI Smart Insights', Icons.auto_awesome_rounded),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: insights.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildInsightCard(theme, insights[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(ThemeData theme, SpendingInsight insight) {
    Color color;
    IconData icon;
    switch (insight.iconType) {
      case IconType.warning:
        color = PulseDesign.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case IconType.success:
        color = PulseDesign.success;
        icon = Icons.check_circle_rounded;
        break;
      case IconType.trending:
        color = Colors.blue;
        icon = Icons.trending_up_rounded;
        break;
      case IconType.savings:
        color = PulseDesign.accent;
        icon = Icons.savings_rounded;
        break;
      default:
        color = theme.colorScheme.primary;
        icon = Icons.lightbulb_rounded;
    }

    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(insight.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text(insight.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingHeatmap(ThemeData theme, WidgetRef ref) {
    final heatmap = ref.watch(weeklySpendingHeatmapProvider);
    final maxSpend = heatmap.fold<double>(
        0, (max, week) => week.fold<double>(max, (m, v) => v > m ? v : m));
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days
                .map((d) => SizedBox(
                    width: 32,
                    child: Text(d,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey, fontWeight: FontWeight.bold))))
                .toList(),
          ),
          const SizedBox(height: 12),
          ...heatmap.toList().asMap().entries.map((weekEntry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    weekEntry.value.toList().asMap().entries.map((dayEntry) {
                  final amount = dayEntry.value;
                  final intensity = maxSpend > 0 ? amount / maxSpend : 0;
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: intensity > 0
                          ? Color.lerp(PulseDesign.success.withOpacity(0.1),
                              PulseDesign.error, intensity.toDouble())
                          : theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ).animate().fadeIn(
                      delay: Duration(
                          milliseconds:
                              20 * (weekEntry.key * 7 + dayEntry.key)));
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(ThemeData theme, SMSAnalyticsState smsState) {
    final categories = smsState.topCategories;
    if (categories.isEmpty) return const SizedBox.shrink();
    final total = categories.fold<double>(0, (sum, e) => sum + e.value);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
              height: 120,
              width: 120,
              child: PieChart(PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 35,
                sections: categories
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) => PieChartSectionData(
                        color: chartColors[entry.key % chartColors.length],
                        value: entry.value.value,
                        title: '',
                        radius: 15))
                    .toList(),
              ))),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children:
                  categories.take(4).toList().asMap().entries.map((entry) {
                final percent = (entry.value.value / total * 100);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color:
                                  chartColors[entry.key % chartColors.length],
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(entry.value.key,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis)),
                      Text('${percent.toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingPulse(ThemeData theme, SMSAnalyticsState smsState) {
    final dailySpending = smsState.summary?.dailySpending ?? [];
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 160,
        child: dailySpending.isEmpty
            ? const Center(
                child: Text("Track SMS to see activity",
                    style: TextStyle(color: Colors.grey, fontSize: 12)))
            : LineChart(LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: dailySpending
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
                        .toList(),
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.2),
                              Colors.transparent
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)),
                  )
                ],
              )),
      ),
    );
  }

  Widget _buildTopMerchants(ThemeData theme, SMSAnalyticsState smsState) {
    return Column(
      children: smsState.topMerchants
          .take(3)
          .map((m) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      child: Text(m.key[0],
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold))),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Text(m.key,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                  Text('KES ${m.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: PulseDesign.accent)),
                ]),
              ))
          .toList(),
    );
  }

  Widget _buildProviderStats(ThemeData theme, SMSAnalyticsState smsState) {
    final providers = smsState.summary?.transactionsByProvider ?? {};
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: providers.entries
          .take(3)
          .map((e) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: theme.cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    Text(e.value.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 18)),
                    Text(e.key.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 9, color: Colors.grey, letterSpacing: 1)),
                  ]),
                ),
              ))
          .toList(),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('SMS Access Required'),
        content: const Text(
            'PayPulse AI needs to read transaction SMS to provide deep financial insights and automated tracking.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('LATER')),
          ElevatedButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: const Text('ENABLE IN SETTINGS')),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  final Color color;
  final AnimationController controller;
  const _PulsingDot({required this.color, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(1 - controller.value),
              blurRadius: 10 * controller.value,
              spreadRadius: 5 * controller.value,
            ),
          ],
        ),
      ),
    );
  }
}
