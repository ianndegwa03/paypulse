import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/app/features/wallet/presentation/state/sms_analytics_provider.dart';
import 'package:paypulse/core/services/sms_service.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/core/theme/app_colors.dart';
import 'package:paypulse/core/theme/app_theme.dart';
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
    final user = ref.watch(authNotifierProvider).currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = user?.isPremiumUser ?? false;

    // Merge internal and external transactions
    List<Transaction> allTransactions = [...walletState.transactions];
    if (smsState.isEnabled) {
      allTransactions.addAll(smsState.transactions.map((t) => t.transaction));
    }

    // Calculations
    double income = smsState.summary?.totalIncome ?? 0;
    double expense = smsState.summary?.totalExpense ?? 0;

    // Fallback to wallet data if SMS not enabled
    if (!smsState.isEnabled) {
      for (var tx in walletState.transactions) {
        if (tx.type == TransactionType.credit) {
          income += tx.amount;
        } else {
          expense += tx.amount.abs();
        }
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Effects
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
                      // Main Stats Card
                      _buildMainStatsCard(context, income, expense, theme)
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      // SMS Sync Banner
                      _buildSMSSyncBanner(theme, smsState),

                      const SizedBox(height: 28),

                      // AI Insights (Premium)
                      if (isPremium && smsState.insights.isNotEmpty)
                        _buildAIInsightsSection(theme, smsState.insights)
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.1),

                      if (isPremium && smsState.insights.isNotEmpty)
                        const SizedBox(height: 28),

                      // Spending Heatmap
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

                      // Category Breakdown
                      _buildSectionHeader(
                          theme, 'Spending Breakdown', Icons.pie_chart_rounded),
                      const SizedBox(height: 16),
                      _buildCategoryBreakdown(theme, smsState)
                          .animate()
                          .fadeIn(delay: 400.ms),

                      const SizedBox(height: 28),

                      // Spending Trend
                      _buildSectionHeader(
                          theme, 'Spending Pulse', Icons.show_chart_rounded),
                      const SizedBox(height: 16),
                      _buildSpendingPulse(theme, smsState)
                          .animate()
                          .fadeIn(delay: 500.ms),

                      const SizedBox(height: 28),

                      // Top Merchants
                      if (smsState.topMerchants.isNotEmpty) ...[
                        _buildSectionHeader(theme, 'Top Merchants',
                            Icons.store_mall_directory_rounded),
                        const SizedBox(height: 16),
                        _buildTopMerchants(theme, smsState)
                            .animate()
                            .fadeIn(delay: 600.ms),
                        const SizedBox(height: 28),
                      ],

                      // Provider Stats
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
          // Gradient orb top-left
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
          // Gradient orb bottom-right
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
                    AppColors.secondary.withOpacity(isDark ? 0.1 : 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Blur overlay
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'FINANCIAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                if (smsState.isSyncing) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              'Intelligence',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            children: [
              if (smsState.isEnabled) ...[
                const PulsingDot(color: AppColors.accent, size: 8),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              CircleAvatar(
                backgroundColor: theme.colorScheme.surface,
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
    BuildContext context,
    double income,
    double expense,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final net = income - expense;
    final savingsRate = income > 0 ? ((net / income) * 100) : 0;

    return GlassCard(
      padding: const EdgeInsets.all(28),
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
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${net.toStringAsFixed(0)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                      color: net >= 0 ? AppColors.income : AppColors.expense,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (net >= 0 ? AppColors.income : AppColors.expense)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  net >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: net >= 0 ? AppColors.income : AppColors.expense,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  theme,
                  'Income',
                  '\$${income.toStringAsFixed(0)}',
                  AppColors.income,
                  Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  theme,
                  'Expense',
                  '\$${expense.toStringAsFixed(0)}',
                  AppColors.expense,
                  Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  theme,
                  'Savings',
                  '${savingsRate.toStringAsFixed(0)}%',
                  AppColors.info,
                  Icons.savings_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    ThemeData theme,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
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
          ? AppColors.income.withOpacity(0.3)
          : theme.colorScheme.primary.withOpacity(0.2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (smsState.isEnabled
                      ? AppColors.income
                      : theme.colorScheme.primary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Icon(
              smsState.isEnabled ? Icons.sync_rounded : Icons.hub_rounded,
              color: smsState.isEnabled
                  ? AppColors.income
                  : theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      smsState.isEnabled ? 'SMS SYNCED' : 'NETWORK SYNC',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: smsState.isEnabled
                            ? AppColors.income
                            : theme.colorScheme.primary,
                      ),
                    ),
                    if (smsState.isEnabled && smsState.isSyncing) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.income,
                        ),
                      ),
                    ],
                  ],
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                'ENABLE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            IconButton(
              onPressed: () {
                ref.read(smsAnalyticsNotifierProvider.notifier).sync();
              },
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.income,
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }

  Widget _buildAIInsightsSection(
      ThemeData theme, List<SpendingInsight> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'AI Insights', Icons.auto_awesome_rounded),
        const SizedBox(height: 16),
        ...insights.take(3).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final insight = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInsightCard(theme, insight)
                .animate()
                .fadeIn(delay: Duration(milliseconds: 100 * index))
                .slideX(begin: 0.05),
          );
        }),
      ],
    );
  }

  Widget _buildInsightCard(ThemeData theme, SpendingInsight insight) {
    Color color;
    IconData icon;

    switch (insight.iconType) {
      case IconType.warning:
        color = AppColors.pending;
        icon = Icons.warning_amber_rounded;
        break;
      case IconType.success:
        color = AppColors.income;
        icon = Icons.check_circle_rounded;
        break;
      case IconType.trending:
        color = AppColors.info;
        icon = Icons.trending_up_rounded;
        break;
      case IconType.savings:
        color = AppColors.accent;
        icon = Icons.savings_rounded;
        break;
      default:
        color = theme.colorScheme.primary;
        icon = Icons.lightbulb_rounded;
    }

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  insight.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingHeatmap(ThemeData theme, WidgetRef ref) {
    final heatmap = ref.watch(weeklySpendingHeatmapProvider);
    final maxSpend = heatmap.fold<double>(
      0,
      (max, week) => week.fold<double>(max, (m, v) => v > m ? v : m),
    );

    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((d) {
              return SizedBox(
                width: 36,
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          ...heatmap.asMap().entries.map((weekEntry) {
            final weekIndex = weekEntry.key;
            final week = weekEntry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: week.asMap().entries.map((dayEntry) {
                  final amount = dayEntry.value;
                  final intensity = maxSpend > 0 ? amount / maxSpend : 0;

                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: intensity > 0
                          ? Color.lerp(
                              AppColors.income.withOpacity(0.1),
                              AppColors.expense,
                              intensity.toDouble(),
                            )
                          : theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: intensity > 0.5
                        ? Center(
                            child: Text(
                              '\$${amount.toInt()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : null,
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(
                            milliseconds: 50 * (weekIndex * 7 + dayEntry.key)),
                      )
                      .scale(begin: const Offset(0.8, 0.8));
                }).toList(),
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Less', style: theme.textTheme.labelSmall),
              const SizedBox(width: 8),
              ...List.generate(5, (i) {
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      theme.colorScheme.surfaceContainerHighest,
                      AppColors.expense,
                      i / 4,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text('More', style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(ThemeData theme, SMSAnalyticsState smsState) {
    final categories = smsState.topCategories;

    if (categories.isEmpty) {
      return _buildEmptyState(theme, 'No spending data yet');
    }

    final total = categories.fold<double>(0, (sum, e) => sum + e.value);

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Pie Chart
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 35,
                sections: categories.asMap().entries.map((entry) {
                  final color = AppColors
                      .chartColors[entry.key % AppColors.chartColors.length];
                  return PieChartSectionData(
                    color: color,
                    value: entry.value.value,
                    title: '',
                    radius: 18,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.asMap().entries.map((entry) {
                final color = AppColors
                    .chartColors[entry.key % AppColors.chartColors.length];
                final percent = (entry.value.value / total * 100);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value.key,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 180,
        child: dailySpending.isEmpty
            ? Center(
                child: Text(
                  'Enable SMS sync to see trends',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              )
            : LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.onSurface.withOpacity(0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailySpending.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.amount);
                      }).toList(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.25),
                            theme.colorScheme.primary.withOpacity(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTopMerchants(ThemeData theme, SMSAnalyticsState smsState) {
    return Column(
      children:
          smsState.topMerchants.take(4).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final merchant = entry.value;
        final color =
            AppColors.chartColors[index % AppColors.chartColors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SurfaceCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Center(
                    child: Text(
                      merchant.key.isNotEmpty ? merchant.key[0] : '?',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    merchant.key,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '\$${merchant.value.toStringAsFixed(0)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 * index))
              .slideX(begin: 0.05),
        );
      }).toList(),
    );
  }

  Widget _buildProviderStats(ThemeData theme, SMSAnalyticsState smsState) {
    final providers = smsState.summary?.transactionsByProvider ?? {};
    final total = providers.values.fold<int>(0, (sum, v) => sum + v);

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: providers.entries.take(4).map((entry) {
          final percent = total > 0 ? (entry.value / total * 100) : 0;
          return Column(
            children: [
              Text(
                entry.value.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                entry.key,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 12),
            Text(
              msg,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        title: const Text('Permission Required'),
        content: const Text(
          'PayPulse needs SMS access to provide financial intelligence. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('OPEN SETTINGS'),
          ),
        ],
      ),
    );
  }
}
