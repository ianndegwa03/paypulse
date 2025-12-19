import 'dart:math';
import 'package:logger/logger.dart';
import 'package:paypulse/core/ai/ai_client.dart';
import 'package:paypulse/core/analytics/analytics_service.dart';
import 'package:paypulse/core/services/local_storage/storage_service.dart';
import 'package:paypulse/app/di/config/di_config.dart';
import 'dart:convert';
import 'package:paypulse/app/config/feature_flags.dart';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:get_it/get_it.dart';

abstract class BehavioralCoachingService {
  Future<Map<String, dynamic>> analyzeSpendingHabits(
      Map<String, dynamic> transactionData);
  Future<List<Map<String, dynamic>>> getPersonalizedCoachingTips(String userId);
  Future<Map<String, dynamic>> createBehavioralGoal(
      String userId, String goalType);
  Future<Map<String, dynamic>> trackProgress(String userId, String goalId);
  Future<double> calculateFinancialHealthScore(String userId);
  Future<Map<String, dynamic>> getWeeklyReport(String userId);
  Future<void> sendMotivationalNotification(String userId);
  Future<Map<String, dynamic>> predictFutureBehavior(
      Map<String, dynamic> historicalData);
}

class BehavioralCoachingServiceImpl implements BehavioralCoachingService {
  final AIClient _aiClient;
  final AnalyticsService _analyticsService;
  final StorageService _storageService;
  final DIConfig _config;
  final Logger _logger = Logger();

  BehavioralCoachingServiceImpl({
    required AIClient aiClient,
    required AnalyticsService analyticsService,
    required StorageService storageService,
    required DIConfig config,
  })  : _aiClient = aiClient,
        _analyticsService = analyticsService,
        _storageService = storageService,
        _config = config;

  @override
  Future<Map<String, dynamic>> analyzeSpendingHabits(
      Map<String, dynamic> transactionData) async {
    try {
      if (!_config.featureFlags.isEnabled(Feature.behavioralCoaching)) {
        throw BehavioralCoachingException(
            message: 'Behavioral coaching features disabled');
      }

      final analysis = await _aiClient.analyzeFinancialData(transactionData);

      // Extract behavioral patterns
      final patterns = _extractBehavioralPatterns(transactionData);

      // Calculate habit scores
      final habitScores = _calculateHabitScores(transactionData);

      // Generate recommendations
      final recommendations = await _generateBehavioralRecommendations(
        transactionData,
        patterns,
        habitScores,
      );

      final result = {
        'analysis': analysis['analysis'],
        'behavioral_patterns': patterns,
        'habit_scores': habitScores,
        'recommendations': recommendations,
        'analysis_date': DateTime.now().toIso8601String(),
      };

      // Log coaching event
      await _analyticsService
          .logEvent('behavioral_analysis_completed', parameters: {
        'patterns_identified': patterns.length,
        'average_habit_score': _calculateAverageScore(habitScores),
        'user_id': transactionData['user_id'],
      });

      return result;
    } catch (e) {
      throw BehavioralCoachingException(
        message: 'Failed to analyze spending habits: $e',
        data: {'error': e.toString()},
      );
    }
  }

  Map<String, dynamic> _extractBehavioralPatterns(Map<String, dynamic> data) {
    final transactions = data['transactions'] as List<dynamic>;
    final patterns = <String, dynamic>{};

    // Analyze frequency patterns
    patterns['frequency'] = _analyzeFrequencyPatterns(transactions);

    // Analyze amount patterns
    patterns['amount_distribution'] = _analyzeAmountPatterns(transactions);

    // Analyze time-based patterns
    patterns['time_patterns'] = _analyzeTimePatterns(transactions);

    // Analyze category patterns
    patterns['category_distribution'] = _analyzeCategoryPatterns(transactions);

    return patterns;
  }

  Map<String, dynamic> _analyzeFrequencyPatterns(List<dynamic> transactions) {
    final dailyCount = <String, int>{};

    for (final transaction in transactions) {
      final date = DateTime.parse(transaction['date'] as String)
          .toIso8601String()
          .split('T')[0];
      dailyCount.update(date, (value) => value + 1, ifAbsent: () => 1);
    }

    final averageDaily = dailyCount.values.isNotEmpty
        ? dailyCount.values.reduce((a, b) => a + b) / dailyCount.length
        : 0;

    return {
      'average_daily_transactions': averageDaily,
      'most_active_day': _findMostActiveDay(dailyCount),
      'consistency_score':
          _calculateConsistencyScore(dailyCount.values.toList()),
    };
  }

  String _findMostActiveDay(Map<String, int> dailyCount) {
    if (dailyCount.isEmpty) return 'No data';

    return dailyCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double _calculateConsistencyScore(List<int> dailyCounts) {
    if (dailyCounts.isEmpty) return 0;

    final average = dailyCounts.reduce((a, b) => a + b) / dailyCounts.length;
    final variance = dailyCounts
            .map((count) => pow(count - average, 2))
            .reduce((a, b) => a + b) /
        dailyCounts.length;
    final stdDev = sqrt(variance);

    // Lower standard deviation = more consistent
    return (1 / (1 + stdDev)) * 100;
  }

  Map<String, dynamic> _analyzeAmountPatterns(List<dynamic> transactions) {
    final amounts = transactions.map((t) => t['amount'] as double).toList();

    if (amounts.isEmpty) {
      return {
        'average_amount': 0,
        'median_amount': 0,
        'largest_transaction': 0,
        'smallest_transaction': 0,
      };
    }

    amounts.sort();

    return {
      'average_amount': amounts.reduce((a, b) => a + b) / amounts.length,
      'median_amount': amounts[amounts.length ~/ 2],
      'largest_transaction': amounts.last,
      'smallest_transaction': amounts.first,
      'spending_range': amounts.last - amounts.first,
    };
  }

  Map<String, dynamic> _analyzeTimePatterns(List<dynamic> transactions) {
    final hourlyPattern = List<int>.filled(24, 0);
    final weeklyPattern = List<int>.filled(7, 0);

    for (final transaction in transactions) {
      final date = DateTime.parse(transaction['date'] as String);
      final hour = date.hour;
      final weekday = date.weekday - 1; // 0 = Monday

      hourlyPattern[hour]++;
      weeklyPattern[weekday]++;
    }

    return {
      'peak_hour':
          hourlyPattern.indexOf(hourlyPattern.reduce((a, b) => a > b ? a : b)),
      'peak_day': _getWeekdayName(
          weeklyPattern.indexOf(weeklyPattern.reduce((a, b) => a > b ? a : b))),
      'hourly_distribution': hourlyPattern,
      'weekly_distribution': weeklyPattern,
    };
  }

  String _getWeekdayName(int index) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[index];
  }

  Map<String, dynamic> _analyzeCategoryPatterns(List<dynamic> transactions) {
    final categoryCount = <String, int>{};
    final categoryAmount = <String, double>{};

    for (final transaction in transactions) {
      final category = transaction['category'] as String? ?? 'Unknown';
      final amount = transaction['amount'] as double;

      categoryCount.update(category, (value) => value + 1, ifAbsent: () => 1);
      categoryAmount.update(category, (value) => value + amount,
          ifAbsent: () => amount);
    }

    return {
      'most_frequent_category': categoryCount.isNotEmpty
          ? categoryCount.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : 'None',
      'highest_spending_category': categoryAmount.isNotEmpty
          ? categoryAmount.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : 'None',
      'category_distribution': categoryAmount,
    };
  }

  Map<String, double> _calculateHabitScores(Map<String, dynamic> data) {
    final transactions = data['transactions'] as List<dynamic>;

    return {
      'budget_adherence': _calculateBudgetAdherenceScore(data),
      'savings_consistency': _calculateSavingsConsistencyScore(transactions),
      'impulse_control': _calculateImpulseControlScore(transactions),
      'financial_planning': _calculateFinancialPlanningScore(data),
      'debt_management': _calculateDebtManagementScore(data),
    };
  }

  double _calculateBudgetAdherenceScore(Map<String, dynamic> data) {
    final budget = data['monthly_budget'] as double? ?? 0;
    final actualSpending = data['total_spent'] as double? ?? 0;

    if (budget == 0) return 50; // Neutral score if no budget set

    final adherence = (budget - actualSpending) / budget * 100;
    return adherence.clamp(0, 100).toDouble();
  }

  double _calculateSavingsConsistencyScore(List<dynamic> transactions) {
    final savingsTransactions = transactions
        .where((t) =>
            (t['category'] as String? ?? '')
                .toLowerCase()
                .contains('savings') ||
            (t['type'] as String? ?? '') == 'saving')
        .toList();

    if (savingsTransactions.isEmpty) return 0;

    // Score based on frequency and amount consistency
    final monthsWithSavings = savingsTransactions
        .map((t) {
          final date = DateTime.parse(t['date'] as String);
          return '${date.year}-${date.month}';
        })
        .toSet()
        .length;

    return (monthsWithSavings / 12 * 100).clamp(0, 100).toDouble();
  }

  double _calculateImpulseControlScore(List<dynamic> transactions) {
    // Identify impulse purchases (large, unplanned, entertainment/shopping categories)
    final impulseCategories = ['Entertainment', 'Shopping', 'Dining'];
    final impulseTransactions = transactions.where((t) {
      final category = t['category'] as String? ?? '';
      final amount = t['amount'] as double;
      return impulseCategories.contains(category) && amount > 50;
    }).toList();

    final totalTransactions = transactions.length;
    if (totalTransactions == 0) return 100;

    final impulseRatio = impulseTransactions.length / totalTransactions;
    return (100 - (impulseRatio * 100)).clamp(0, 100).toDouble();
  }

  double _calculateFinancialPlanningScore(Map<String, dynamic> data) {
    final factors = <String, bool>{
      'has_budget': (data['has_budget'] as bool? ?? false),
      'has_goals': (data['has_goals'] as bool? ?? false),
      'has_investments': (data['has_investments'] as bool? ?? false),
      'has_emergency_fund': (data['has_emergency_fund'] as bool? ?? false),
    };

    final trueCount = factors.values.where((v) => v).length;
    return (trueCount / factors.length * 100).clamp(0, 100).toDouble();
  }

  double _calculateDebtManagementScore(Map<String, dynamic> data) {
    final totalDebt = data['total_debt'] as double? ?? 0;
    final monthlyIncome = data['monthly_income'] as double? ?? 1;
    final debtToIncomeRatio = totalDebt / monthlyIncome;

    // Lower ratio = better score
    final score = (1 - debtToIncomeRatio.clamp(0, 1)) * 100;
    return score.clamp(0, 100).toDouble();
  }

  Future<List<Map<String, dynamic>>> _generateBehavioralRecommendations(
    Map<String, dynamic> transactionData,
    Map<String, dynamic> patterns,
    Map<String, dynamic> habitScores,
  ) async {
    final recommendations = <Map<String, dynamic>>[];

    // Generate recommendations based on low habit scores
    for (final entry in (habitScores as Map<String, double>).entries) {
      if (entry.value < 60) {
        recommendations.add(await _generateRecommendationForHabit(
          entry.key,
          entry.value,
          patterns,
        ));
      }
    }

    // Add pattern-based recommendations
    final patternRecommendations =
        await _generatePatternBasedRecommendations(patterns);
    recommendations.addAll(patternRecommendations);

    return recommendations;
  }

  Future<Map<String, dynamic>> _generateRecommendationForHabit(
    String habit,
    double score,
    Map<String, dynamic> patterns,
  ) async {
    final prompt = '''
    Generate a specific, actionable recommendation to improve $habit (current score: ${score.toStringAsFixed(1)}/100).
    
    User's spending patterns:
    ${json.encode(patterns)}
    
    Provide recommendation in this format:
    1. Specific action to take
    2. Expected benefit
    3. Timeframe
    4. Difficulty level (Easy/Medium/Hard)
    ''';

    final response = await _aiClient.generateResponse(prompt);

    return {
      'habit': habit,
      'current_score': score,
      'recommendation': response,
      'priority': _determinePriority(score),
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> _generatePatternBasedRecommendations(
    Map<String, dynamic> patterns,
  ) async {
    final recommendations = <Map<String, dynamic>>[];

    // Analyze patterns and generate recommendations
    final frequencyPatterns = patterns['frequency'] as Map<String, dynamic>;
    if (frequencyPatterns['consistency_score'] < 70) {
      recommendations.add({
        'type': 'consistency',
        'title': 'Improve Spending Consistency',
        'description':
            'Try to maintain more consistent daily spending patterns.',
        'action': 'Set daily spending limits',
        'priority': 'medium',
      });
    }

    final timePatterns = patterns['time_patterns'] as Map<String, dynamic>;
    if (timePatterns['peak_hour'] >= 18 && timePatterns['peak_hour'] <= 23) {
      recommendations.add({
        'type': 'timing',
        'title': 'Evening Spending Alert',
        'description':
            'Most spending occurs in the evening. Consider planning purchases earlier in the day.',
        'action': 'Implement evening spending review',
        'priority': 'low',
      });
    }

    return recommendations;
  }

  String _determinePriority(double score) {
    if (score < 30) return 'high';
    if (score < 60) return 'medium';
    return 'low';
  }

  double _calculateAverageScore(Map<String, dynamic> habitScores) {
    final scores = (habitScores as Map<String, double>).values.toList();
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  @override
  Future<List<Map<String, dynamic>>> getPersonalizedCoachingTips(
      String userId) async {
    try {
      // Load user data
      final userData = await _loadUserData(userId);
      final transactionData = await _loadTransactionData(userId);

      // Analyze habits
      final analysis = await analyzeSpendingHabits({
        ...userData,
        'transactions': transactionData,
      });

      // Generate personalized tips
      final tips = await _generatePersonalizedTips(analysis, userData);

      // Track coaching session
      await _analyticsService.logEvent('coaching_tips_generated', parameters: {
        'user_id': userId,
        'tips_count': tips.length,
        'average_habit_score': analysis['habit_scores'] != null
            ? _calculateAverageScore(
                analysis['habit_scores'] as Map<String, dynamic>)
            : 0,
      });

      return tips;
    } catch (e) {
      throw BehavioralCoachingException(
        message: 'Failed to get personalized coaching tips: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }

  Future<Map<String, dynamic>> _loadUserData(String userId) async {
    final data = await _storageService.getObject('user_$userId');
    return data ?? {'user_id': userId};
  }

  Future<List<dynamic>> _loadTransactionData(String userId) async {
    final data = await _storageService.getList('transactions_$userId');
    return data ?? [];
  }

  Future<List<Map<String, dynamic>>> _generatePersonalizedTips(
    Map<String, dynamic> analysis,
    Map<String, dynamic> userData,
  ) async {
    final tips = <Map<String, dynamic>>[];
    final habitScores = analysis['habit_scores'] as Map<String, double>? ?? {};

    // Generate tip for each habit that needs improvement
    for (final entry in habitScores.entries) {
      if (entry.value < 70) {
        final tip = await _createTipForHabit(entry.key, entry.value, userData);
        tips.add(tip);
      }
    }

    // Add general financial wellness tips
    tips.addAll(_getGeneralWellnessTips());

    return tips.take(5).toList(); // Return top 5 tips
  }

  Future<Map<String, dynamic>> _createTipForHabit(
    String habit,
    double score,
    Map<String, dynamic> userData,
  ) async {
    const tipTemplates = {
      'budget_adherence': [
        'Try the 50/30/20 rule: 50% needs, 30% wants, 20% savings',
        'Use envelope budgeting for better control',
        'Review your budget every Sunday evening',
      ],
      'savings_consistency': [
        'Set up automatic transfers to savings',
        'Save your change with round-up apps',
        'Create a savings challenge with friends',
      ],
      'impulse_control': [
        'Implement a 24-hour waiting rule for purchases over \$50',
        'Unsubscribe from shopping newsletters',
        'Use cash for discretionary spending',
      ],
    };

    final templates = tipTemplates[habit] ??
        [
          'Track your ${habit.replaceAll('_', ' ')} daily',
          'Set small, achievable goals for improvement',
          'Celebrate small wins in your journey',
        ];

    final random = Random();
    final selectedTemplate = templates[random.nextInt(templates.length)];

    return {
      'habit': habit,
      'score': score,
      'tip': selectedTemplate,
      'personalized': true,
      'estimated_impact': _estimateImpact(score),
      'time_commitment': '5-10 minutes daily',
    };
  }

  List<Map<String, dynamic>> _getGeneralWellnessTips() {
    return [
      {
        'tip': 'Review your financial goals weekly',
        'category': 'planning',
        'benefit': 'Keeps you focused on long-term objectives',
      },
      {
        'tip': 'Celebrate financial milestones, no matter how small',
        'category': 'motivation',
        'benefit': 'Builds positive reinforcement',
      },
      {
        'tip': 'Share your financial journey with a trusted friend',
        'category': 'accountability',
        'benefit': 'Increases commitment and support',
      },
    ];
  }

  String _estimateImpact(double score) {
    if (score < 30) {
      return 'High impact - could significantly improve financial health';
    }
    if (score < 60) return 'Medium impact - good opportunity for improvement';
    return 'Low impact - maintaining good habits';
  }

  @override
  Future<Map<String, dynamic>> createBehavioralGoal(
      String userId, String goalType) async {
    try {
      final goalId = 'goal_${DateTime.now().millisecondsSinceEpoch}';

      final goal = {
        'id': goalId,
        'user_id': userId,
        'type': goalType,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'active',
        'progress': 0.0,
        'milestones': await _generateGoalMilestones(goalType),
      };

      await _storageService.saveObject('goal_${userId}_$goalId', goal);

      await _analyticsService.logEvent('behavioral_goal_created', parameters: {
        'user_id': userId,
        'goal_type': goalType,
        'goal_id': goalId,
      });

      return goal;
    } catch (e) {
      throw BehavioralCoachingException(
        message: 'Failed to create behavioral goal: $e',
        data: {'userId': userId, 'goalType': goalType, 'error': e.toString()},
      );
    }
  }

  Future<List<Map<String, dynamic>>> _generateGoalMilestones(
      String goalType) async {
    const milestones = {
      'budget_adherence': [
        {'target': 'Track spending for 7 days', 'reward': 'Understanding'},
        {'target': 'Stay within budget for 2 weeks', 'reward': 'Consistency'},
        {'target': 'Achieve 90% adherence for 1 month', 'reward': 'Mastery'},
      ],
      'savings_increase': [
        {'target': 'Save \$100', 'reward': 'Starter'},
        {'target': 'Save \$500', 'reward': 'Builder'},
        {'target': 'Save \$1000', 'reward': 'Achiever'},
      ],
      'debt_reduction': [
        {'target': 'Pay off smallest debt', 'reward': 'Snowball Starter'},
        {'target': 'Reduce total debt by 25%', 'reward': 'Progress Maker'},
        {'target': 'Become debt-free', 'reward': 'Financial Freedom'},
      ],
    };

    return milestones[goalType] ??
        [
          {'target': 'Complete first week', 'reward': 'Getting Started'},
          {'target': 'Maintain for 30 days', 'reward': 'Habit Formed'},
          {'target': 'Sustain for 90 days', 'reward': 'Lifestyle Change'},
        ];
  }

  @override
  Future<Map<String, dynamic>> trackProgress(
      String userId, String goalId) async {
    try {
      final goal = await _storageService.getObject('goal_${userId}_$goalId');
      if (goal == null) {
        throw BehavioralCoachingException(message: 'Goal not found');
      }

      // Calculate progress based on goal type
      final progress = await _calculateGoalProgress(userId, goal);

      final updatedGoal = {
        ...goal,
        'progress': progress,
        'last_updated': DateTime.now().toIso8601String(),
        'status': progress >= 100 ? 'completed' : 'active',
      };

      await _storageService.saveObject('goal_${userId}_$goalId', updatedGoal);

      // Send progress notification if significant
      if (_isSignificantProgress(goal['progress'] as double, progress)) {
        await sendMotivationalNotification(userId);
      }

      await _analyticsService.logEvent('goal_progress_updated', parameters: {
        'user_id': userId,
        'goal_id': goalId,
        'progress': progress,
        'status': updatedGoal['status'],
      });

      return updatedGoal;
    } catch (e) {
      throw BehavioralCoachingException(
        message: 'Failed to track progress: $e',
        data: {'userId': userId, 'goalId': goalId, 'error': e.toString()},
      );
    }
  }

  Future<double> _calculateGoalProgress(
      String userId, Map<String, dynamic> goal) async {
    final goalType = goal['type'] as String;

    switch (goalType) {
      case 'budget_adherence':
        return await _calculateBudgetAdherenceProgress(userId);
      case 'savings_increase':
        return await _calculateSavingsProgress(userId, goal);
      case 'debt_reduction':
        return await _calculateDebtReductionProgress(userId, goal);
      default:
        return 0.0;
    }
  }

  Future<double> _calculateBudgetAdherenceProgress(String userId) async {
    // Simplified progress calculation
    return 50.0; // Example value
  }

  Future<double> _calculateSavingsProgress(
      String userId, Map<String, dynamic> goal) async {
    // Simplified progress calculation
    return 75.0; // Example value
  }

  Future<double> _calculateDebtReductionProgress(
      String userId, Map<String, dynamic> goal) async {
    // Simplified progress calculation
    return 30.0; // Example value
  }

  bool _isSignificantProgress(double oldProgress, double newProgress) {
    return newProgress - oldProgress >= 10; // 10% increase is significant
  }

  @override
  Future<double> calculateFinancialHealthScore(String userId) async {
    try {
      final userData = await _loadUserData(userId);
      final transactionData = await _loadTransactionData(userId);

      final analysis = await analyzeSpendingHabits({
        ...userData,
        'transactions': transactionData,
      });

      final habitScores =
          analysis['habit_scores'] as Map<String, double>? ?? {};
      final averageScore = _calculateAverageScore(habitScores);

      // Adjust based on additional factors
      final adjustments = await _calculateHealthScoreAdjustments(userData);
      final finalScore = (averageScore * 0.7 + adjustments * 0.3).clamp(0, 100);

      await _storageService.saveObject('health_score_$userId', {
        'score': finalScore,
        'calculated_at': DateTime.now().toIso8601String(),
        'components': {
          'habit_score': averageScore,
          'adjustments': adjustments,
        },
      });

      await _analyticsService
          .logEvent('financial_health_score_calculated', parameters: {
        'user_id': userId,
        'score': finalScore,
        'average_habit_score': averageScore,
      });

      return finalScore.toDouble();
    } catch (e) {
      throw BehavioralCoachingException(
        message: 'Failed to calculate financial health score: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }

  Future<double> _calculateHealthScoreAdjustments(
      Map<String, dynamic> userData) async {
    double adjustments = 50; // Base score

    // Positive adjustments
    if (userData['has_emergency_fund'] == true) adjustments += 10;
    if (userData['has_investments'] == true) adjustments += 15;
    if (userData['has_retirement_plan'] == true) adjustments += 10;

    // Negative adjustments
    if (userData['has_high_interest_debt'] == true) adjustments -= 20;
    if (userData['living_paycheck_to_paycheck'] == true) adjustments -= 15;

    return adjustments.clamp(0, 100).toDouble();
  }

  @override
  Future<Map<String, dynamic>> getWeeklyReport(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final report = {
        'user_id': userId,
        'week_start': weekStart.toIso8601String(),
        'week_end': now.toIso8601String(),
        'generated_at': now.toIso8601String(),
        'summary': await _generateWeeklySummary(userId, weekStart, now),
        'achievements': await _getWeeklyAchievements(userId),
        'areas_for_improvement': await _identifyImprovementAreas(userId),
        'next_steps': await _suggestNextSteps(userId),
        'motivational_quote': _getMotivationalQuote(),
      };

      await _storageService.saveObject(
          'weekly_report_${userId}_${now.millisecondsSinceEpoch}', report);

      await _analyticsService.logEvent('weekly_report_generated', parameters: {
        'user_id': userId,
        'report_id': now.millisecondsSinceEpoch.toString(),
      });

      return report;
    } catch (e) {
      throw BehavioralCoachingException(
        message: 'Failed to generate weekly report: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }

  Future<Map<String, dynamic>> _generateWeeklySummary(
    String userId,
    DateTime weekStart,
    DateTime weekEnd,
  ) async {
    // Simplified weekly summary
    return {
      'total_spent': 0.0,
      'total_saved': 0.0,
      'budget_adherence': 0.0,
      'notable_events': [],
    };
  }

  Future<List<Map<String, dynamic>>> _getWeeklyAchievements(
      String userId) async {
    // Simplified achievements
    return [
      {
        'achievement': 'Consistent tracking',
        'description': 'Logged transactions for 7 consecutive days',
        'badge': 'tracker_streak',
      },
    ];
  }

  Future<List<String>> _identifyImprovementAreas(String userId) async {
    // Simplified improvement areas
    return [
      'Evening impulse spending',
      'Dining out frequency',
      'Subscription management',
    ];
  }

  Future<List<Map<String, dynamic>>> _suggestNextSteps(String userId) async {
    // Simplified next steps
    return [
      {
        'step': 'Review subscription services',
        'priority': 'high',
        'time_estimate': '15 minutes',
      },
      {
        'step': 'Set up automatic savings transfer',
        'priority': 'medium',
        'time_estimate': '5 minutes',
      },
    ];
  }

  String _getMotivationalQuote() {
    final quotes = [
      'Financial freedom is available to those who learn about it and work for it.',
      'The best time to plant a tree was 20 years ago. The second best time is now.',
      'Small daily improvements over time lead to stunning results.',
      'Wealth is not about having a lot of money; it\'s about having a lot of options.',
    ];

    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }

  @override
  Future<void> sendMotivationalNotification(String userId) async {
    try {
      final notifications = [
        'Great progress this week! Keep up the momentum! 🎉',
        'Your financial discipline is showing results! 💪',
        'Small steps lead to big changes. You\'re doing amazing! 👏',
        'Financial freedom is built one good decision at a time. Stay focused! ✨',
      ];

      final random = Random();
      final message = notifications[random.nextInt(notifications.length)];

      // In production, this would integrate with your notification service
      _logger.d('Sending motivational notification to user $userId: $message');

      await _analyticsService
          .logEvent('motivational_notification_sent', parameters: {
        'user_id': userId,
        'message': message,
      });
    } catch (e) {
      _logger.e('Failed to send motivational notification: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> predictFutureBehavior(
      Map<String, dynamic> historicalData) async {
    try {
      final prediction = await _aiClient.predictSpending(historicalData);

      return {
        'predicted_spending': prediction,
        'confidence_level': 0.85,
        'prediction_date': DateTime.now().toIso8601String(),
        'timeframe': 'next_month',
        'key_factors': _identifyPredictionFactors(historicalData),
        'recommendations': await _generatePredictionRecommendations(
            prediction, historicalData),
      };
    } catch (e) {
      throw BehavioralCoachingException(
        message: 'Failed to predict future behavior: $e',
        data: {'error': e.toString()},
      );
    }
  }

  List<String> _identifyPredictionFactors(Map<String, dynamic> historicalData) {
    final factors = <String>[];

    if (historicalData['seasonal_patterns'] == true) {
      factors.add('Seasonal spending patterns');
    }
    if (historicalData['income_regularity'] == true) {
      factors.add('Regular income schedule');
    }
    if (historicalData['life_events'] != null) {
      factors.add('Upcoming life events');
    }

    return factors.isNotEmpty ? factors : ['Historical spending averages'];
  }

  Future<List<Map<String, dynamic>>> _generatePredictionRecommendations(
    double predictedSpending,
    Map<String, dynamic> historicalData,
  ) async {
    final recommendations = <Map<String, dynamic>>[];

    final averageSpending =
        historicalData['average_monthly_spending'] as double? ?? 0;

    if (predictedSpending > averageSpending * 1.2) {
      recommendations.add({
        'type': 'spending_warning',
        'title': 'Higher than usual spending predicted',
        'action': 'Review discretionary categories',
        'urgency': 'medium',
      });
    }

    if (predictedSpending < averageSpending * 0.8) {
      recommendations.add({
        'type': 'savings_opportunity',
        'title': 'Opportunity to increase savings',
        'action': 'Consider boosting savings contributions',
        'urgency': 'low',
      });
    }

    return recommendations;
  }
}

class BehavioralCoachingModule {
  Future<void> init() async {
    final getIt = GetIt.instance;
    final config = getIt<DIConfig>();

    // Register Service
    if (!getIt.isRegistered<BehavioralCoachingService>()) {
      getIt.registerLazySingleton<BehavioralCoachingService>(() {
        if (!config.featureFlags.isEnabled(Feature.behavioralCoaching)) {
          return _MockBehavioralCoachingService();
        }
        return BehavioralCoachingServiceImpl(
          aiClient: getIt<AIClient>(),
          analyticsService: getIt<AnalyticsService>(),
          storageService: getIt<StorageService>(),
          config: config,
        );
      });
    }

    // Register HabitTracker
    if (!getIt.isRegistered<HabitTracker>()) {
      getIt.registerLazySingleton<HabitTracker>(
        () => HabitTracker(),
      );
    }

    // Register FinancialCoach
    if (!getIt.isRegistered<FinancialCoach>()) {
      getIt.registerLazySingleton<FinancialCoach>(
        () => FinancialCoach(service: getIt<BehavioralCoachingService>()),
      );
    }
  }
}

class _MockBehavioralCoachingService implements BehavioralCoachingService {
  final Logger _logger = Logger();

  @override
  Future<Map<String, dynamic>> analyzeSpendingHabits(
      Map<String, dynamic> transactionData) async {
    return {
      'note': 'Behavioral coaching features disabled',
      'mock_analysis': 'Enable features for detailed analysis',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getPersonalizedCoachingTips(
      String userId) async {
    return [
      {
        'tip': 'Enable behavioral coaching features for personalized tips',
        'category': 'system',
        'priority': 'high',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> createBehavioralGoal(
      String userId, String goalType) async {
    return {
      'id': 'mock_goal',
      'note': 'Behavioral coaching features disabled',
      'status': 'inactive',
    };
  }

  @override
  Future<Map<String, dynamic>> trackProgress(
      String userId, String goalId) async {
    return {
      'progress': 0,
      'note': 'Behavioral coaching features disabled',
    };
  }

  @override
  Future<double> calculateFinancialHealthScore(String userId) async {
    return 50.0; // Neutral score
  }

  @override
  Future<Map<String, dynamic>> getWeeklyReport(String userId) async {
    return {
      'note': 'Behavioral coaching features disabled',
      'mock_report': true,
    };
  }

  @override
  Future<void> sendMotivationalNotification(String userId) async {
    _logger.d('Behavioral coaching features disabled - skipping notification');
  }

  @override
  Future<Map<String, dynamic>> predictFutureBehavior(
      Map<String, dynamic> historicalData) async {
    return {
      'note': 'Behavioral coaching features disabled',
      'mock_prediction': true,
    };
  }
}

class HabitTracker {
  HabitTracker();

  Future<Map<String, dynamic>> trackDailyHabits(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      const dailyHabits = [
        'tracked_spending',
        'reviewed_budget',
        'saved_money',
        'avoided_impulse_purchase',
      ];

      final habitLog = <String, bool>{};
      for (final habit in dailyHabits) {
        habitLog[habit] = Random().nextBool(); // Mock data
      }

      final streak = await _calculateStreak(userId, habitLog);

      return {
        'date': today,
        'habits': habitLog,
        'completion_rate': _calculateCompletionRate(habitLog),
        'current_streak': streak,
        'points_earned': _calculatePoints(habitLog),
      };
    } catch (e) {
      throw BehavioralCoachingException(
        message: 'Failed to track daily habits: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }

  Future<int> _calculateStreak(
      String userId, Map<String, bool> todayHabits) async {
    // Simplified streak calculation
    return Random().nextInt(10);
  }

  double _calculateCompletionRate(Map<String, bool> habits) {
    final completed = habits.values.where((v) => v).length;
    return (completed / habits.length * 100);
  }

  int _calculatePoints(Map<String, bool> habits) {
    return habits.values.where((v) => v).length * 10;
  }
}

class FinancialCoach {
  final BehavioralCoachingService _service;

  FinancialCoach({required BehavioralCoachingService service})
      : _service = service;

  Future<Map<String, dynamic>> getPersonalizedCoachingPlan(
      String userId) async {
    try {
      final healthScore = await _service.calculateFinancialHealthScore(userId);
      final tips = await _service.getPersonalizedCoachingTips(userId);

      return {
        'coaching_plan': {
          'health_score': healthScore,
          'recommended_focus': _determineFocusArea(healthScore),
          'weekly_tasks': _generateWeeklyTasks(tips),
          'monthly_goals': _generateMonthlyGoals(healthScore),
          'resources': _recommendResources(healthScore),
        },
        'generated_at': DateTime.now().toIso8601String(),
        'plan_duration': '30_days',
      };
    } catch (e) {
      throw BehavioralCoachingException(
        message: 'Failed to create coaching plan: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }

  String _determineFocusArea(double healthScore) {
    if (healthScore < 40) return 'Basic Financial Foundations';
    if (healthScore < 70) return 'Habit Building & Optimization';
    return 'Advanced Wealth Building';
  }

  List<Map<String, dynamic>> _generateWeeklyTasks(
      List<Map<String, dynamic>> tips) {
    return tips.take(3).map((tip) {
      return {
        'task': tip['tip'] as String,
        'category': tip['category'] as String? ?? 'general',
        'estimated_time': '15-30 minutes',
        'priority': tip['priority'] as String? ?? 'medium',
      };
    }).toList();
  }

  List<Map<String, dynamic>> _generateMonthlyGoals(double healthScore) {
    if (healthScore < 40) {
      return [
        {
          'goal': 'Create and stick to a basic budget',
          'metric': 'budget_adherence'
        },
        {'goal': 'Build \$500 emergency fund', 'metric': 'savings_balance'},
      ];
    } else if (healthScore < 70) {
      return [
        {'goal': 'Increase savings rate by 5%', 'metric': 'savings_rate'},
        {
          'goal': 'Reduce discretionary spending by 10%',
          'metric': 'spending_reduction'
        },
      ];
    } else {
      return [
        {
          'goal': 'Start or increase investment contributions',
          'metric': 'investment_amount'
        },
        {
          'goal': 'Review and optimize insurance coverage',
          'metric': 'protection_level'
        },
      ];
    }
  }

  List<String> _recommendResources(double healthScore) {
    if (healthScore < 40) {
      return [
        'Budgeting Basics Guide',
        'Emergency Fund Calculator',
        'Debt Snowball Method',
      ];
    } else if (healthScore < 70) {
      return [
        'Advanced Budgeting Strategies',
        'Investment 101 Course',
        'Tax Planning Basics',
      ];
    } else {
      return [
        'Advanced Investment Strategies',
        'Estate Planning Guide',
        'Tax Optimization Techniques',
      ];
    }
  }
}

class BehavioralCoachingException extends AppException {
  BehavioralCoachingException({
    required super.message,
    super.statusCode,
    super.data,
  });
}
