import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/core/services/sms_service.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';

/// State for SMS analytics
class SMSAnalyticsState {
  final bool isEnabled;
  final bool isSyncing;
  final bool hasPermission;
  final List<ParsedSMSTransaction> transactions;
  final SMSAnalyticsSummary? summary;
  final DateTime? lastSyncedAt;
  final String? error;

  // Computed insights
  final List<SpendingInsight> insights;
  final Map<String, CategoryTrend> categoryTrends;

  SMSAnalyticsState({
    this.isEnabled = false,
    this.isSyncing = false,
    this.hasPermission = false,
    this.transactions = const [],
    this.summary,
    this.lastSyncedAt,
    this.error,
    this.insights = const [],
    this.categoryTrends = const {},
  });

  SMSAnalyticsState copyWith({
    bool? isEnabled,
    bool? isSyncing,
    bool? hasPermission,
    List<ParsedSMSTransaction>? transactions,
    SMSAnalyticsSummary? summary,
    DateTime? lastSyncedAt,
    String? error,
    List<SpendingInsight>? insights,
    Map<String, CategoryTrend>? categoryTrends,
  }) {
    return SMSAnalyticsState(
      isEnabled: isEnabled ?? this.isEnabled,
      isSyncing: isSyncing ?? this.isSyncing,
      hasPermission: hasPermission ?? this.hasPermission,
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      error: error,
      insights: insights ?? this.insights,
      categoryTrends: categoryTrends ?? this.categoryTrends,
    );
  }

  /// Hours since last sync
  int get hoursSinceSync {
    if (lastSyncedAt == null) return -1;
    return DateTime.now().difference(lastSyncedAt!).inHours;
  }

  /// Get top spending categories
  List<MapEntry<String, double>> get topCategories {
    final cats = summary?.categoryBreakdown.entries.toList() ?? [];
    cats.sort((a, b) => b.value.compareTo(a.value));
    return cats.take(5).toList();
  }

  /// Get top merchants
  List<MapEntry<String, double>> get topMerchants {
    final merchants = summary?.merchantBreakdown.entries.toList() ?? [];
    merchants.sort((a, b) => b.value.compareTo(a.value));
    return merchants.take(5).toList();
  }
}

/// Spending insight generated from SMS data
class SpendingInsight {
  final String title;
  final String description;
  final InsightType type;
  final double? value;
  final String? category;
  final IconType iconType;

  SpendingInsight({
    required this.title,
    required this.description,
    required this.type,
    this.value,
    this.category,
    this.iconType = IconType.info,
  });
}

enum InsightType { alert, tip, achievement, prediction }

enum IconType { warning, success, info, trending, savings }

/// Category trend data
class CategoryTrend {
  final String category;
  final double currentWeek;
  final double previousWeek;
  final double percentChange;
  final bool isIncreasing;

  CategoryTrend({
    required this.category,
    required this.currentWeek,
    required this.previousWeek,
  })  : percentChange = previousWeek > 0
            ? ((currentWeek - previousWeek) / previousWeek) * 100
            : 0,
        isIncreasing = currentWeek > previousWeek;
}

/// SMS Analytics Notifier
class SMSAnalyticsNotifier extends StateNotifier<SMSAnalyticsState> {
  final SMSService _smsService;

  SMSAnalyticsNotifier(this._smsService) : super(SMSAnalyticsState()) {
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await _smsService.hasPermission();
    state = state.copyWith(hasPermission: hasPermission);
  }

  /// Enable SMS analytics and request permission
  Future<bool> enable() async {
    state = state.copyWith(isSyncing: true, error: null);

    try {
      final granted = await _smsService.requestPermission();

      if (granted) {
        state = state.copyWith(
          isEnabled: true,
          hasPermission: true,
        );
        await sync();
        return true;
      } else {
        state = state.copyWith(
          isSyncing: false,
          hasPermission: false,
          error: 'SMS permission denied',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: 'Failed to enable: $e',
      );
      return false;
    }
  }

  /// Disable SMS analytics
  void disable() {
    state = SMSAnalyticsState(hasPermission: state.hasPermission);
  }

  /// Sync SMS data
  Future<void> sync() async {
    if (!state.isEnabled || !state.hasPermission) return;

    state = state.copyWith(isSyncing: true, error: null);

    try {
      // Fetch transactions and summary in parallel
      final results = await Future.wait([
        _smsService.getFinancialTransactions(
          since: DateTime.now().subtract(const Duration(days: 90)),
        ),
        _smsService.getAnalyticsSummary(
          since: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ]);

      final transactions = results[0] as List<ParsedSMSTransaction>;
      final summary = results[1] as SMSAnalyticsSummary;

      // Generate insights
      final insights = _generateInsights(transactions, summary);
      final categoryTrends = _calculateCategoryTrends(transactions);

      state = state.copyWith(
        transactions: transactions,
        summary: summary,
        insights: insights,
        categoryTrends: categoryTrends,
        isSyncing: false,
        lastSyncedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: 'Failed to sync: $e',
      );
    }
  }

  List<SpendingInsight> _generateInsights(
    List<ParsedSMSTransaction> transactions,
    SMSAnalyticsSummary summary,
  ) {
    final insights = <SpendingInsight>[];

    // Savings rate insight
    if (summary.savingsRate > 0) {
      if (summary.savingsRate >= 20) {
        insights.add(SpendingInsight(
          title: 'Great Savings!',
          description:
              'You\'re saving ${summary.savingsRate.toStringAsFixed(1)}% of your income. Keep it up!',
          type: InsightType.achievement,
          value: summary.savingsRate,
          iconType: IconType.success,
        ));
      } else if (summary.savingsRate < 10) {
        insights.add(SpendingInsight(
          title: 'Low Savings Alert',
          description:
              'Your savings rate is ${summary.savingsRate.toStringAsFixed(1)}%. Consider reducing non-essential spending.',
          type: InsightType.alert,
          value: summary.savingsRate,
          iconType: IconType.warning,
        ));
      }
    }

    // Top spending category
    if (summary.categoryBreakdown.isNotEmpty) {
      final topCategory = summary.categoryBreakdown.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add(SpendingInsight(
        title: 'Top Spending: ${topCategory.key}',
        description:
            'You spent ${topCategory.value.toStringAsFixed(0)} on ${topCategory.key} this month.',
        type: InsightType.tip,
        value: topCategory.value,
        category: topCategory.key,
        iconType: IconType.trending,
      ));
    }

    // Frequent merchant insight
    if (summary.merchantBreakdown.isNotEmpty) {
      final topMerchant = summary.merchantBreakdown.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add(SpendingInsight(
        title: 'Frequent Spending',
        description:
            '${topMerchant.key} is your most visited merchant (${topMerchant.value.toStringAsFixed(0)} spent).',
        type: InsightType.tip,
        iconType: IconType.info,
      ));
    }

    // Transaction volume insight
    insights.add(SpendingInsight(
      title: '${summary.totalTransactions} Transactions',
      description:
          'Tracked ${summary.totalTransactions} transactions this month via SMS.',
      type: InsightType.tip,
      value: summary.totalTransactions.toDouble(),
      iconType: IconType.info,
    ));

    // Prediction insight
    final avgDailySpend = summary.totalExpense / 30;
    final projectedMonthly = avgDailySpend * 30;
    insights.add(SpendingInsight(
      title: 'Spending Forecast',
      description:
          'At this rate, you\'ll spend ~${projectedMonthly.toStringAsFixed(0)} this month.',
      type: InsightType.prediction,
      value: projectedMonthly,
      iconType: IconType.trending,
    ));

    return insights;
  }

  Map<String, CategoryTrend> _calculateCategoryTrends(
    List<ParsedSMSTransaction> transactions,
  ) {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    final currentWeek = <String, double>{};
    final previousWeek = <String, double>{};

    for (var tx in transactions) {
      if (tx.transaction.type == TransactionType.debit) {
        final cat = tx.transaction.categoryId;
        final amount = tx.transaction.amount;

        if (tx.transaction.date.isAfter(oneWeekAgo)) {
          currentWeek[cat] = (currentWeek[cat] ?? 0) + amount;
        } else if (tx.transaction.date.isAfter(twoWeeksAgo)) {
          previousWeek[cat] = (previousWeek[cat] ?? 0) + amount;
        }
      }
    }

    final trends = <String, CategoryTrend>{};
    final allCategories = {...currentWeek.keys, ...previousWeek.keys};

    for (var cat in allCategories) {
      trends[cat] = CategoryTrend(
        category: cat,
        currentWeek: currentWeek[cat] ?? 0,
        previousWeek: previousWeek[cat] ?? 0,
      );
    }

    return trends;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

final smsAnalyticsNotifierProvider =
    StateNotifierProvider<SMSAnalyticsNotifier, SMSAnalyticsState>((ref) {
  final smsService = ref.watch(smsServiceProvider);
  return SMSAnalyticsNotifier(smsService);
});

/// Quick access to whether SMS analytics is enabled
final isSmsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(smsAnalyticsNotifierProvider).isEnabled;
});

/// Quick access to SMS analytics summary
final smsSummaryProvider = Provider<SMSAnalyticsSummary?>((ref) {
  return ref.watch(smsAnalyticsNotifierProvider).summary;
});

/// Get spending insights
final spendingInsightsProvider = Provider<List<SpendingInsight>>((ref) {
  return ref.watch(smsAnalyticsNotifierProvider).insights;
});

/// Weekly spending for heatmap (last 4 weeks, by day)
final weeklySpendingHeatmapProvider = Provider<List<List<double>>>((ref) {
  final state = ref.watch(smsAnalyticsNotifierProvider);
  final summary = state.summary;

  if (summary == null) return [];

  // Create 4x7 grid (4 weeks x 7 days)
  final heatmap = List.generate(4, (_) => List.filled(7, 0.0));

  for (var day in summary.dailySpending) {
    final weeksAgo = DateTime.now().difference(day.date).inDays ~/ 7;
    if (weeksAgo < 4) {
      final dayOfWeek = day.date.weekday - 1; // 0 = Monday
      heatmap[weeksAgo][dayOfWeek] = day.amount;
    }
  }

  return heatmap;
});
