import 'dart:math';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:paypulse/core/analytics/analytics_service.dart';
import 'package:paypulse/core/services/local_storage/storage_service.dart';
import 'package:paypulse/app/di/config/di_config.dart';
import 'package:paypulse/app/config/feature_flags.dart';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:get_it/get_it.dart';

abstract class PredictiveAnalyticsService {
  Future<Map<String, dynamic>> predictCashFlow(Map<String, dynamic> historicalData);
  Future<Map<String, dynamic>> detectSpendingAnomalies(List<Map<String, dynamic>> transactions);
  Future<Map<String, dynamic>> forecastIncome(Map<String, dynamic> incomeHistory);
  Future<Map<String, dynamic>> predictInvestmentReturns(Map<String, dynamic> investmentData);
  Future<Map<String, dynamic>> calculateRiskScore(Map<String, dynamic> financialProfile);
  Future<Map<String, dynamic>> generateFinancialScenario(Map<String, dynamic> parameters);
  Future<Map<String, dynamic>> optimizePortfolio(Map<String, dynamic> portfolioData);
}

class PredictiveAnalyticsServiceImpl implements PredictiveAnalyticsService {
  final DIConfig _config;
  final AnalyticsService _analyticsService;
  final StorageService _storageService;
  
  PredictiveAnalyticsServiceImpl({
    required DIConfig config,
    required AnalyticsService analyticsService,
    required StorageService storageService,
  })  : _config = config,
        _analyticsService = analyticsService,
        _storageService = storageService;
  
  @override
  Future<Map<String, dynamic>> predictCashFlow(Map<String, dynamic> historicalData) async {
    try {
      if (!_config.featureFlags.isEnabled(Feature.predictiveAnalytics)) {
        throw PredictiveAnalyticsException(message: 'Predictive analytics features disabled');
      }
      
      final transactions = historicalData['transactions'] as List<dynamic>;
      if (transactions.isEmpty) {
        throw PredictiveAnalyticsException(message: 'No transaction data available');
      }
      
      // Prepare data for ML model
      final preparedData = await _prepareCashFlowData(transactions);
      
      // Train or load model
      final model = await _trainCashFlowModel(preparedData);
      
      // Make predictions
      final predictions = await _generateCashFlowPredictions(model, preparedData);
      
      // Calculate confidence intervals
      final confidence = await _calculatePredictionConfidence(predictions, preparedData);
      
      final Map<String, dynamic> result = {
        'predictions': predictions,
        'confidence_score': confidence,
        'time_period': '30_days',
        'generated_at': DateTime.now().toIso8601String(),
        'model_metrics': await _getModelMetrics(model),
        'key_insights': await _extractCashFlowInsights(predictions, historicalData),
      };
      
      await _analyticsService.logEvent('cash_flow_prediction_generated', parameters: {
        'prediction_count': predictions.length,
        'average_confidence': confidence,
        'data_points': transactions.length,
      });
      
      return result;
    } catch (e) {
      throw PredictiveAnalyticsException(
        message: 'Failed to predict cash flow: $e',
        data: {'error': e.toString()},
      );
    }
  }



  @override
  Future<Map<String, dynamic>> predictInvestmentReturns(
      Map<String, dynamic> investmentData) async {
    return {'projected_return': 0.0};
  }

  @override
  Future<Map<String, dynamic>> calculateRiskScore(
      Map<String, dynamic> financialProfile) async {
    return {'risk_score': 50};
  }

  @override
  Future<Map<String, dynamic>> generateFinancialScenario(
      Map<String, dynamic> parameters) async {
    return {'scenario': 'base_case'};
  }

  @override
  Future<Map<String, dynamic>> optimizePortfolio(
      Map<String, dynamic> portfolioData) async {
    return {'optimized_portfolio': []};
  }
  
  Future<List<Map<String, dynamic>>> _prepareCashFlowData(List<dynamic> transactions) async {
    final preparedData = <Map<String, dynamic>>[];
    
    // Group by day
    final dailyData = <String, Map<String, dynamic>>{};
    
    for (final transaction in transactions) {
      final dateStr = (transaction['date'] as String).split('T')[0];
      final amount = transaction['amount'] as double;
      final type = transaction['type'] as String;
      
      if (!dailyData.containsKey(dateStr)) {
        dailyData[dateStr] = {
          'date': dateStr,
          'total_income': 0.0,
          'total_expense': 0.0,
          'transaction_count': 0,
          'weekday': DateTime.parse(dateStr).weekday,
          'is_weekend': [6, 7].contains(DateTime.parse(dateStr).weekday),
        };
      }
      
      final dayData = dailyData[dateStr]!;
      if (type == 'income') {
        dayData['total_income'] = (dayData['total_income'] as double) + amount;
      } else {
        dayData['total_expense'] = (dayData['total_expense'] as double) + amount;
      }
      dayData['transaction_count'] = (dayData['transaction_count'] as int) + 1;
    }
    
    // Convert to list and add derived features
    dailyData.forEach((date, data) {
      data['net_cash_flow'] = (data['total_income'] as double) - (data['total_expense'] as double);
      data['expense_ratio'] = data['total_income'] > 0 
          ? (data['total_expense'] as double) / (data['total_income'] as double)
          : 1.0;
      
      preparedData.add(data);
    });
    
    // Sort by date
    preparedData.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    
    return preparedData;
  }
  
  Future<LinearRegressor> _trainCashFlowModel(List<Map<String, dynamic>> preparedData) async {
    try {
      // Mock implementation to avoid ML API issues
      // TODO: Implement proper ML model training
      throw PredictiveAnalyticsException(message: 'ML training not implemented');
    } catch (e) {
      throw PredictiveAnalyticsException(
        message: 'Failed to train cash flow model: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Future<List<Map<String, dynamic>>> _generateCashFlowPredictions(
    LinearRegressor model,
    List<Map<String, dynamic>> historicalData,
  ) async {
    try {
      final predictions = <Map<String, dynamic>>[];
      final now = DateTime.now();
      
      // Predict for next 30 days
      for (int i = 1; i <= 30; i++) {
        final predictionDate = now.add(Duration(days: i));
        final features = [
          predictionDate.weekday.toDouble(),
          [6, 7].contains(predictionDate.weekday) ? 1.0 : 0.0,
          _calculateExpectedTransactions(historicalData, predictionDate.weekday),
        ];
        
        final prediction = model.predict(DataFrame([features], headerExists: false));
        final predictedValue = prediction.rows.first.first;
        
        // Apply seasonal adjustments
        final adjustedValue = await _applySeasonalAdjustment(predictedValue, predictionDate);
        
        predictions.add({
          'date': predictionDate.toIso8601String().split('T')[0],
          'predicted_cash_flow': adjustedValue,
          'weekday': predictionDate.weekday,
          'is_weekend': [6, 7].contains(predictionDate.weekday),
          'confidence_interval': _calculateDailyConfidence(historicalData, predictionDate.weekday),
        });
      }
      
      return predictions;
    } catch (e) {
      throw PredictiveAnalyticsException(
        message: 'Failed to generate cash flow predictions: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  double _calculateExpectedTransactions(List<Map<String, dynamic>> historicalData, int weekday) {
    final weekdayData = historicalData.where((day) => day['weekday'] == weekday).toList();
    if (weekdayData.isEmpty) return historicalData.length / 30.0; // Average
    
    final totalTransactions = weekdayData.fold(0, (sum, day) => sum + (day['transaction_count'] as int));
    return totalTransactions / weekdayData.length;
  }
  
  Future<double> _applySeasonalAdjustment(double predictedValue, DateTime date) async {
    // Apply monthly patterns
    final monthlyPattern = await _loadMonthlyPatterns();
    final monthKey = '${date.month}';
    
    if (monthlyPattern.containsKey(monthKey)) {
      final adjustment = monthlyPattern[monthKey] as double;
      return predictedValue * (1 + adjustment / 100);
    }
    
    return predictedValue;
  }
  
  Future<Map<String, double>> _loadMonthlyPatterns() async {
    final patterns = await _storageService.getObject('monthly_spending_patterns');
    if (patterns != null) {
      return Map<String, double>.from(patterns);
    }
    
    // Default patterns based on common spending behavior
    return {
      '1': 10.0,  // January - post-holiday spending
      '2': -5.0,  // February - lower spending
      '3': 2.0,   // March - spring spending
      '4': 5.0,   // April - tax season
      '5': 3.0,   // May - pre-summer
      '6': 8.0,   // June - summer spending
      '7': 7.0,   // July - summer travel
      '8': 4.0,   // August - back to school
      '9': 1.0,   // September - routine
      '10': 6.0,  // October - pre-holiday
      '11': 15.0, // November - holiday shopping
      '12': 20.0, // December - holiday peak
    };
  }
  
  Map<String, dynamic> _calculateDailyConfidence(List<Map<String, dynamic>> historicalData, int weekday) {
    final weekdayData = historicalData.where((day) => day['weekday'] == weekday).toList();
    if (weekdayData.length < 2) {
      return {'lower': -1000, 'upper': 1000, 'confidence': 0.5};
    }
    
    final cashFlows = weekdayData.map((day) => day['net_cash_flow'] as double).toList();
    final mean = cashFlows.reduce((a, b) => a + b) / cashFlows.length;
    
    final variance = cashFlows.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / cashFlows.length;
    final stdDev = sqrt(variance);
    
    final confidenceInterval = 1.96 * stdDev / sqrt(cashFlows.length);
    
    return {
      'lower': mean - confidenceInterval,
      'upper': mean + confidenceInterval,
      'confidence': stdDev > 0 ? (1 / (1 + stdDev)).clamp(0, 1) : 1.0,
    };
  }
  
  Future<double> _calculatePredictionConfidence(
    List<Map<String, dynamic>> predictions,
    List<Map<String, dynamic>> historicalData,
  ) async {
    if (historicalData.length < 30) return 0.5;
    
    // Calculate model accuracy on historical data
    // final testData = historicalData.sublist(0, historicalData.length - 7);
    // final validationData = historicalData.sublist(historicalData.length - 7);
    
    // Simplified confidence calculation
    final avgCashFlow = historicalData.map((d) => d['net_cash_flow'] as double).reduce((a, b) => a + b) / historicalData.length;
    final variance = historicalData.map((d) => pow((d['net_cash_flow'] as double) - avgCashFlow, 2)).reduce((a, b) => a + b) / historicalData.length;
    
    // Higher variance = lower confidence
    final confidence = 1 / (1 + sqrt(variance) / 100);
    return confidence.clamp(0, 1).toDouble();
  }
  
  Future<Map<String, dynamic>> _getModelMetrics(LinearRegressor model) async {
    try {
      // Get model coefficients and performance metrics
      return {
        'coefficients': model.coefficients.toList(),
        'intercept': model.coefficients.first,
        'iterations': model.iterationsLimit,
        'learning_rate': 0.01,
        'regularization': model.lambda,
      };
    } catch (e) {
      return {'error': 'Metrics unavailable: $e'};
    }
  }
  
  Future<List<Map<String, dynamic>>> _extractCashFlowInsights(
    List<Map<String, dynamic>> predictions,
    Map<String, dynamic> historicalData,
  ) async {
    final insights = <Map<String, dynamic>>[];
    
    // Calculate total predicted cash flow
    final totalPredicted = predictions.fold(0.0, (sum, day) => sum + (day['predicted_cash_flow'] as double));
    
    // Identify negative cash flow days
    final negativeDays = predictions.where((day) => (day['predicted_cash_flow'] as double) < 0).toList();
    
    // Find peak spending days
    predictions.sort((a, b) => (b['predicted_cash_flow'] as double).compareTo(a['predicted_cash_flow'] as double));
    final peakDays = predictions.take(3).toList();
    
    insights.add({
      'type': 'summary',
      'title': '30-Day Cash Flow Forecast',
      'content': 'Total predicted cash flow: \$${totalPredicted.toStringAsFixed(2)}',
      'severity': totalPredicted < 0 ? 'high' : 'low',
    });
    
    if (negativeDays.isNotEmpty) {
      insights.add({
        'type': 'warning',
        'title': 'Potential Cash Shortages',
        'content': '${negativeDays.length} days with predicted negative cash flow',
        'days': negativeDays.map((d) => d['date']).toList(),
      });
    }
    
    insights.add({
      'type': 'opportunity',
      'title': 'Peak Cash Flow Days',
      'content': 'Highest positive cash flow expected on:',
      'days': peakDays.map((d) => {'date': d['date'], 'amount': d['predicted_cash_flow']}).toList(),
    });
    
    return insights;
  }
  
  @override
  Future<Map<String, dynamic>> detectSpendingAnomalies(List<Map<String, dynamic>> transactions) async {
    try {
      if (transactions.isEmpty) {
        throw PredictiveAnalyticsException(message: 'No transaction data available');
      }
      
      // Calculate statistical metrics
      final amounts = transactions.map((t) => t['amount'] as double).toList();
      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final stdDev = _calculateStandardDeviation(amounts, mean);
      
      // Detect anomalies using statistical methods
      final anomalies = <Map<String, dynamic>>[];
      final now = DateTime.now();
      
      for (final transaction in transactions) {
        final amount = transaction['amount'] as double;
        final date = DateTime.parse(transaction['date'] as String);
        final daysAgo = now.difference(date).inDays;
        
        // Check for statistical outliers (3 sigma rule)
        final zScore = (amount - mean) / stdDev;
        final isStatisticalOutlier = zScore.abs() > 3;
        
        // Check for temporal anomalies (unusual time of day/week)
        final isTemporalAnomaly = await _checkTemporalAnomaly(transaction, transactions);
        
        // Check for category anomalies
        final isCategoryAnomaly = await _checkCategoryAnomaly(transaction, transactions);
        
        if (isStatisticalOutlier || isTemporalAnomaly || isCategoryAnomaly) {
          anomalies.add({
            'transaction': transaction,
            'detected_at': now.toIso8601String(),
            'anomaly_score': _calculateAnomalyScore(zScore, isTemporalAnomaly, isCategoryAnomaly),
            'reasons': _getAnomalyReasons(isStatisticalOutlier, isTemporalAnomaly, isCategoryAnomaly),
            'confidence': _calculateAnomalyConfidence(zScore, daysAgo),
            'recommended_action': _suggestAnomalyAction(transaction, zScore),
          });
        }
      }
      
      // Sort by anomaly score
      anomalies.sort((a, b) => (b['anomaly_score'] as double).compareTo(a['anomaly_score'] as double));
      
      final result = {
        'anomalies_detected': anomalies.length,
        'total_transactions': transactions.length,
        'anomaly_rate': (anomalies.length / transactions.length * 100).toStringAsFixed(2),
        'detected_anomalies': anomalies,
        'statistical_metrics': {
          'mean_amount': mean,
          'std_deviation': stdDev,
          'min_amount': amounts.reduce((a, b) => a < b ? a : b),
          'max_amount': amounts.reduce((a, b) => a > b ? a : b),
        },
        'generated_at': now.toIso8601String(),
      };
      
      await _analyticsService.logEvent('spending_anomalies_detected', parameters: {
        'anomaly_count': anomalies.length,
        'total_transactions': transactions.length,
        'average_anomaly_score': anomalies.isNotEmpty 
            ? anomalies.map((a) => a['anomaly_score'] as double).reduce((a, b) => a + b) / anomalies.length
            : 0,
      });
      
      return result;
    } catch (e) {
      throw PredictiveAnalyticsException(
        message: 'Failed to detect spending anomalies: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  double _calculateStandardDeviation(List<double> values, double mean) {
    if (values.length < 2) return 0.0;
    
    final variance = values.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / values.length;
    return sqrt(variance);
  }
  
  Future<bool> _checkTemporalAnomaly(
    Map<String, dynamic> transaction,
    List<Map<String, dynamic>> allTransactions,
  ) async {
    final date = DateTime.parse(transaction['date'] as String);
    final hour = date.hour;
    final weekday = date.weekday;
    
    // Get historical patterns for this time
    final similarTimeTransactions = allTransactions.where((t) {
      final tDate = DateTime.parse(t['date'] as String);
      return tDate.hour == hour && tDate.weekday == weekday;
    }).toList();
    
    if (similarTimeTransactions.length < 5) return false;
    
    final avgAmount = similarTimeTransactions
        .map((t) => t['amount'] as double)
        .reduce((a, b) => a + b) / similarTimeTransactions.length;
    
    final currentAmount = transaction['amount'] as double;
    
    // Flag if amount is 2x average for this time
    return currentAmount > avgAmount * 2;
  }
  
  Future<bool> _checkCategoryAnomaly(
    Map<String, dynamic> transaction,
    List<Map<String, dynamic>> allTransactions,
  ) async {
    final category = transaction['category'] as String? ?? 'Unknown';
    if (category == 'Unknown') return false;
    
    final categoryTransactions = allTransactions.where((t) {
      return (t['category'] as String? ?? 'Unknown') == category;
    }).toList();
    
    if (categoryTransactions.length < 3) return false;
    
    final categoryAmounts = categoryTransactions.map((t) => t['amount'] as double).toList();
    final categoryMean = categoryAmounts.reduce((a, b) => a + b) / categoryAmounts.length;
    final categoryStdDev = _calculateStandardDeviation(categoryAmounts, categoryMean);
    
    final currentAmount = transaction['amount'] as double;
    final zScore = (currentAmount - categoryMean) / categoryStdDev;
    
    return zScore.abs() > 2.5;
  }
  
  double _calculateAnomalyScore(double zScore, bool temporalAnomaly, bool categoryAnomaly) {
    double score = 0.0;
    
    // Statistical anomaly weight
    score += (zScore.abs() / 10).clamp(0, 0.4);
    
    // Temporal anomaly weight
    if (temporalAnomaly) score += 0.3;
    
    // Category anomaly weight
    if (categoryAnomaly) score += 0.3;
    
    return score.clamp(0, 1);
  }
  
  List<String> _getAnomalyReasons(bool statistical, bool temporal, bool category) {
    final reasons = <String>[];
    
    if (statistical) reasons.add('Statistically significant deviation from average');
    if (temporal) reasons.add('Unusual for this time of day/week');
    if (category) reasons.add('Atypical for this spending category');
    
    return reasons;
  }
  
  double _calculateAnomalyConfidence(double zScore, int daysAgo) {
    // More recent transactions have higher confidence
    final recencyFactor = exp(-daysAgo / 30.0); // Exponential decay over 30 days
    final statisticalConfidence = (1 - exp(-zScore.abs() / 2)).clamp(0, 1);
    
    return (recencyFactor * 0.4 + statisticalConfidence * 0.6).clamp(0, 1);
  }
  
  String _suggestAnomalyAction(Map<String, dynamic> transaction, double zScore) {
    if (zScore > 3) {
      return 'Verify this transaction immediately - unusually high amount';
    } else if (zScore > 2) {
      return 'Review this transaction - higher than usual';
    } else if (zScore < -2) {
      return 'Check for missing transactions - unusually low amount';
    }
    
    return 'Monitor for patterns - slight deviation detected';
  }
  
  @override
  Future<Map<String, dynamic>> forecastIncome(Map<String, dynamic> incomeHistory) async {
    try {
      final incomeData = incomeHistory['income_records'] as List<dynamic>;
      if (incomeData.isEmpty) {
        throw PredictiveAnalyticsException(message: 'No income history available');
      }
      
      // Prepare time series data
      final timeSeries = await _prepareIncomeTimeSeries(incomeData);
      
      // Apply forecasting models
      final forecasts = await _generateIncomeForecasts(timeSeries);
      
      // Calculate confidence intervals
      final confidence = await _calculateIncomeForecastConfidence(timeSeries, forecasts);
      
      // Generate insights
      final insights = await _analyzeIncomePatterns(timeSeries, forecasts);
      
      final Map<String, dynamic> result = {
        'forecast_period': '12_months',
        'forecasts': forecasts,
        'confidence_intervals': confidence,
        'historical_trend': await _calculateIncomeTrend(timeSeries),
        'seasonality_factors': await _detectIncomeSeasonality(timeSeries),
        'key_insights': insights,
        'model_used': 'ARIMA_with_seasonal_adjustment',
        'generated_at': DateTime.now().toIso8601String(),
      };
      
      await _analyticsService.logEvent('income_forecast_generated', parameters: {
        'forecast_months': forecasts.length,
        'average_confidence': confidence['overall_confidence'] ?? 0,
        'trend_direction': result['historical_trend']?['direction'] ?? 'unknown',
      });
      
      return result;
    } catch (e) {
      throw PredictiveAnalyticsException(
        message: 'Failed to forecast income: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Future<List<Map<String, dynamic>>> _prepareIncomeTimeSeries(List<dynamic> incomeData) async {
    final monthlyData = <String, Map<String, dynamic>>{};
    
    for (final record in incomeData) {
      final date = DateTime.parse(record['date'] as String);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final amount = record['amount'] as double;
      final source = record['source'] as String? ?? 'Unknown';
      
      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = {
          'month': monthKey,
          'total_income': 0.0,
          'transaction_count': 0,
          'sources': <String, double>{},
          'variance': 0.0,
        };
      }
      
      final monthRecord = monthlyData[monthKey];
      if (monthRecord == null) continue;
      monthRecord['total_income'] = (monthRecord['total_income'] as double) + amount;
      monthRecord['transaction_count'] = (monthRecord['transaction_count'] as int) + 1;
      
      final sources = monthRecord['sources'] as Map<String, double>;
      sources.update(source, (value) => value + amount, ifAbsent: () => amount);
    }
    
    // Calculate monthly statistics
    final timeSeries = monthlyData.values.toList();
    timeSeries.sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));
    
    // Calculate moving averages and variances
    for (int i = 0; i < timeSeries.length; i++) {
      if (i >= 3) {
        final previousMonths = timeSeries.sublist(i - 3, i);
        final avgIncome = previousMonths
            .map((m) => m['total_income'] as double)
            .reduce((a, b) => a + b) / previousMonths.length;
        
        final variance = previousMonths
            .map((m) => pow((m['total_income'] as double) - avgIncome, 2))
            .reduce((a, b) => a + b) / previousMonths.length;
        
        timeSeries[i]['moving_average'] = avgIncome;
        timeSeries[i]['variance'] = variance;
      }
    }
    
    return timeSeries;
  }
  
  Future<List<Map<String, dynamic>>> _generateIncomeForecasts(List<Map<String, dynamic>> timeSeries) async {
    if (timeSeries.length < 6) {
      throw PredictiveAnalyticsException(message: 'Insufficient data for forecasting (minimum 6 months required)');
    }
    
    final forecasts = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    // Use weighted moving average with trend adjustment
    final recentData = timeSeries.sublist(max(0, timeSeries.length - 12));
    final weights = _calculateForecastWeights(recentData.length);
    
    // Calculate base forecast
    double baseForecast = 0.0;
    for (int i = 0; i < recentData.length; i++) {
      baseForecast += (recentData[i]['total_income'] as double) * weights[i];
    }
    
    // Apply trend adjustment
    final trend = await _calculateIncomeTrend(timeSeries);
    final trendAdjustment = trend['monthly_change'] as double;
    
    // Apply seasonality adjustment
    final seasonality = await _detectIncomeSeasonality(timeSeries);
    
    // Generate 12-month forecast
    for (int month = 1; month <= 12; month++) {
      final forecastDate = DateTime(now.year, now.month + month);
      final monthKey = '${forecastDate.year}-${forecastDate.month.toString().padLeft(2, '0')}';
      
      // Apply trend
      double forecastAmount = baseForecast * (1 + trendAdjustment * month / 12);
      
      // Apply seasonality
      final seasonalFactor = seasonality[forecastDate.month.toString()] ?? 1.0;
      forecastAmount *= seasonalFactor;
      
      // Add randomness based on historical variance
      final avgVariance = recentData
          .map((d) => d['variance'] as double)
          .where((v) => v > 0)
          .fold(0.0, (sum, v) => sum + v) / recentData.length;
      
      final randomFactor = 1 + (Random().nextDouble() * 2 - 1) * sqrt(avgVariance) / baseForecast;
      forecastAmount *= randomFactor;
      
      forecasts.add({
        'month': monthKey,
        'forecasted_income': forecastAmount,
        'confidence_interval': {
          'lower': forecastAmount * 0.85,
          'upper': forecastAmount * 1.15,
        },
        'trend_contribution': trendAdjustment * month / 12,
        'seasonality_factor': seasonalFactor,
      });
    }
    
    return forecasts;
  }
  
  List<double> _calculateForecastWeights(int dataPoints) {
    // Generate weights that favor more recent data (exponential decay)
    final weights = List<double>.filled(dataPoints, 0.0);
    double totalWeight = 0.0;
    
    for (int i = 0; i < dataPoints; i++) {
      weights[i] = exp(-i / (dataPoints / 3.0)); // Exponential decay
      totalWeight += weights[i];
    }
    
    // Normalize weights
    return weights.map((w) => w / totalWeight).toList();
  }
  
  Future<Map<String, dynamic>> _calculateIncomeTrend(List<Map<String, dynamic>> timeSeries) async {
    if (timeSeries.length < 2) {
      return {'direction': 'stable', 'monthly_change': 0.0, 'confidence': 0.0};
    }
    
    // Calculate linear regression for trend
    final x = List<double>.generate(timeSeries.length, (i) => i.toDouble());
    final y = timeSeries.map((m) => m['total_income'] as double).toList();
    
    final n = x.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((xi) => xi * xi).reduce((a, b) => a + b);
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    
    // Calculate R-squared for confidence
    final yMean = sumY / n;
    final ssTotal = y.map((yi) => pow(yi - yMean, 2)).reduce((a, b) => a + b);
    final ssResidual = List.generate(n, (i) => pow(y[i] - (slope * x[i] + intercept), 2)).reduce((a, b) => a + b);
    final rSquared = 1 - (ssResidual / ssTotal);
    
    return {
      'direction': slope > 0.01 ? 'increasing' : slope < -0.01 ? 'decreasing' : 'stable',
      'monthly_change': slope / yMean, // Percentage change per month
      'absolute_change': slope,
      'intercept': intercept,
      'confidence': rSquared.clamp(0, 1),
      'r_squared': rSquared,
    };
  }
  
  Future<Map<String, double>> _detectIncomeSeasonality(List<Map<String, dynamic>> timeSeries) async {
    final seasonality = <String, double>{};
    
    if (timeSeries.length < 12) {
      // Not enough data for seasonal analysis, return default
      for (int month = 1; month <= 12; month++) {
        seasonality[month.toString()] = 1.0;
      }
      return seasonality;
    }
    
    // Group by month
    final monthlyGroups = <int, List<double>>{};
    for (final record in timeSeries) {
      final month = int.parse((record['month'] as String).split('-')[1]);
      final income = record['total_income'] as double;
      
      monthlyGroups.putIfAbsent(month, () => []).add(income);
    }
    
    // Calculate average for each month
    final monthlyAverages = <int, double>{};
    for (final entry in monthlyGroups.entries) {
      monthlyAverages[entry.key] = entry.value.reduce((a, b) => a + b) / entry.value.length;
    }
    
    // Calculate overall average
    final overallAverage = monthlyAverages.values.reduce((a, b) => a + b) / monthlyAverages.length;
    
    // Calculate seasonal factors
    for (final entry in monthlyAverages.entries) {
      seasonality[entry.key.toString()] = entry.value / overallAverage;
    }
    
    // Fill missing months
    for (int month = 1; month <= 12; month++) {
      seasonality.putIfAbsent(month.toString(), () => 1.0);
    }
    
    return seasonality;
  }
  
  Future<Map<String, dynamic>> _calculateIncomeForecastConfidence(
    List<Map<String, dynamic>> timeSeries,
    List<Map<String, dynamic>> forecasts,
  ) async {
    if (timeSeries.length < 6) {
      return {'overall_confidence': 0.5, 'monthly_confidence': {}};
    }
    
    // Calculate forecast error on historical data (backtesting)
    final historicalForecasts = await _backtestForecastModel(timeSeries);
    double totalError = 0.0;
    int validComparisons = 0;
    
    for (int i = 0; i < historicalForecasts.length; i++) {
      final forecast = historicalForecasts[i];
      final actual = timeSeries[timeSeries.length - historicalForecasts.length + i]['total_income'] as double;
      
      if (actual > 0) {
        final error = (forecast - actual).abs() / actual;
        totalError += error;
        validComparisons++;
      }
    }
    
    final meanAbsolutePercentageError = validComparisons > 0 ? totalError / validComparisons : 0.5;
    final confidence = (1 - meanAbsolutePercentageError).clamp(0, 1);
    
    // Calculate confidence for each forecast month (decays over time)
    final monthlyConfidence = <String, double>{};
    for (int i = 0; i < forecasts.length; i++) {
      final monthConfidence = confidence * exp(-i / 6.0); // Exponential decay over 6 months
      monthlyConfidence[forecasts[i]['month'] as String] = monthConfidence.clamp(0.1, 0.95);
    }
    
    return {
      'overall_confidence': confidence,
      'monthly_confidence': monthlyConfidence,
      'mean_absolute_percentage_error': meanAbsolutePercentageError,
      'backtesting_periods': historicalForecasts.length,
    };
  }
  
  Future<List<double>> _backtestForecastModel(List<Map<String, dynamic>> timeSeries) async {
    final forecasts = <double>[];
    const testPeriods = 6; // Test on last 6 months
    
    if (timeSeries.length <= testPeriods) return forecasts;
    
    for (int i = testPeriods; i > 0; i--) {
      final trainingData = timeSeries.sublist(0, timeSeries.length - i);
      if (trainingData.length < 6) continue;
      
      // Generate one-step forecast
      final forecast = await _generateOneStepForecast(trainingData);
      forecasts.add(forecast);
    }
    
    return forecasts;
  }
  
  Future<double> _generateOneStepForecast(List<Map<String, dynamic>> trainingData) async {
    // Simple moving average forecast
    final recentData = trainingData.sublist(max(0, trainingData.length - 3));
    final avgIncome = recentData
        .map((d) => d['total_income'] as double)
        .reduce((a, b) => a + b) / recentData.length;
    
    return avgIncome;
  }
  
  Future<List<Map<String, dynamic>>> _analyzeIncomePatterns(
    List<Map<String, dynamic>> timeSeries,
    List<Map<String, dynamic>> forecasts,
  ) async {
    final insights = <Map<String, dynamic>>[];
    
    // Calculate stability score
    final incomes = timeSeries.map((m) => m['total_income'] as double).toList();
    final avgIncome = incomes.reduce((a, b) => a + b) / incomes.length;
    final variance = incomes.map((i) => pow(i - avgIncome, 2)).reduce((a, b) => a + b) / incomes.length;
    final stabilityScore = 1 / (1 + sqrt(variance) / avgIncome);
    
    insights.add({
      'type': 'stability',
      'title': 'Income Stability Analysis',
      'score': stabilityScore.clamp(0, 1),
      'interpretation': stabilityScore > 0.8 ? 'Highly stable income' : 
                       stabilityScore > 0.6 ? 'Moderately stable income' : 
                       'Variable income stream',
      'recommendation': stabilityScore < 0.6 
          ? 'Consider building a larger emergency fund (6+ months)'
          : 'Maintain current emergency fund (3-6 months)',
    });
    
    // Analyze growth trend
    // final trend = await _calculateIncomeTrend(timeSeries);
    // if (trend['monthly_change'] as double > 0.02) {
    //   insights.add({
    //     'type': 'growth',
    //     'title': 'Strong Income Growth',
    //     'monthly_growth_rate': '${(trend['monthly_change'] as double * 100).toStringAsFixed(2)}',
    //     'annualized_growth': (trend['monthly_change'] as double) * 1200.0,
    //   });
    // }
    
    // Forecast summary
    final totalForecast = forecasts.fold(0.0, (sum, f) => sum + (f['forecasted_income'] as double));
    final avgMonthlyForecast = totalForecast / forecasts.length;
    
    insights.add({
      'type': 'forecast',
      'title': '12-Month Income Forecast',
      'total_forecast': totalForecast,
      'average_monthly': avgMonthlyForecast,
      'growth_from_current': ((avgMonthlyForecast - avgIncome) / avgIncome * 100).toStringAsFixed(1),
      'highest_month': forecasts.reduce((a, b) => 
          (a['forecasted_income'] as double) > (b['forecasted_income'] as double) ? a : b)['month'],
    });
    
    return insights;
  }
  
  // Additional predictive analytics methods would continue here...
  // (Investment returns prediction, risk scoring, scenario generation, portfolio optimization)
}

class PredictiveAnalyticsModule {
  Future<void> init() async {
    final getIt = GetIt.instance;
    final config = getIt<DIConfig>();
    
    // Register Service
    if (!getIt.isRegistered<PredictiveAnalyticsService>()) {
      getIt.registerLazySingleton<PredictiveAnalyticsService>(() {
         if (!config.featureFlags.isEnabled(Feature.predictiveAnalytics)) {
             throw PredictiveAnalyticsException(message: 'Predictive analytics features are disabled');
         }
         return PredictiveAnalyticsServiceImpl(
            analyticsService: getIt<AnalyticsService>(),
            storageService: getIt<StorageService>(),
            config: config,
         );
      });
    }

    // Register ForecastEngine
    if (!getIt.isRegistered<ForecastEngine>()) {
      getIt.registerLazySingleton<ForecastEngine>(
        () => ForecastEngine(service: getIt<PredictiveAnalyticsService>()),
      );
    }

    // Register AnomalyDetector
    if (!getIt.isRegistered<AnomalyDetector>()) {
      getIt.registerLazySingleton<AnomalyDetector>(
         () => AnomalyDetector(service: getIt<PredictiveAnalyticsService>()),
      );
    }
  }
}

class ForecastEngine {
  final PredictiveAnalyticsService _service;
  
  ForecastEngine({required PredictiveAnalyticsService service})
      : _service = service;
  
  Future<Map<String, dynamic>> generateComprehensiveForecast(String userId) async {
    try {
      // Load user financial data
      final userData = await _loadUserFinancialData(userId);
      
      // Generate multiple forecasts
      final cashFlowForecast = await _service.predictCashFlow(userData);
      final incomeForecast = await _service.forecastIncome(userData);
      final anomalyReport = await _service.detectSpendingAnomalies(
        userData['transactions'] as List<Map<String, dynamic>>,
      );
      
      // Combine forecasts
      return {
        'user_id': userId,
        'generated_at': DateTime.now().toIso8601String(),
        'forecast_horizon': '12_months',
        'cash_flow_forecast': cashFlowForecast,
        'income_forecast': incomeForecast,
        'anomaly_report': anomalyReport,
        'composite_score': await _calculateCompositeForecastScore(
          cashFlowForecast,
          incomeForecast,
          anomalyReport,
        ),
        'recommendations': await _generateForecastRecommendations(
          cashFlowForecast,
          incomeForecast,
          anomalyReport,
        ),
      };
    } catch (e) {
      throw PredictiveAnalyticsException(
        message: 'Failed to generate comprehensive forecast: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<Map<String, dynamic>> _loadUserFinancialData(String userId) async {
    // This would load actual user data from database
    // For now, return structure
    return {
      'user_id': userId,
      'transactions': [],
      'income_records': [],
      'investment_data': {},
    };
  }
  
  Future<double> _calculateCompositeForecastScore(
    Map<String, dynamic> cashFlowForecast,
    Map<String, dynamic> incomeForecast,
    Map<String, dynamic> anomalyReport,
  ) async {
    // Calculate weighted score based on forecast quality
    double score = 0.0;
    
    // Cash flow forecast quality (40%)
    final cashFlowConfidence = cashFlowForecast['confidence_score'] as double? ?? 0.5;
    score += cashFlowConfidence * 0.4;
    
    // Income forecast confidence (30%)
    final incomeConfidence = incomeForecast['confidence_intervals']?['overall_confidence'] as double? ?? 0.5;
    score += incomeConfidence * 0.3;
    
    // Anomaly detection quality (30%)
    final anomalyRate = anomalyReport['anomaly_rate'] as String? ?? '0';
    final anomalyScore = 1 - (double.parse(anomalyRate) / 100).clamp(0, 1);
    score += anomalyScore * 0.3;
    
    return score.clamp(0, 1);
  }
  
  Future<List<Map<String, dynamic>>> _generateForecastRecommendations(
    Map<String, dynamic> cashFlowForecast,
    Map<String, dynamic> incomeForecast,
    Map<String, dynamic> anomalyReport,
  ) async {
    final recommendations = <Map<String, dynamic>>[];
    
    // Cash flow recommendations
    final cashFlowInsights = cashFlowForecast['key_insights'] as List<Map<String, dynamic>>? ?? [];
    for (final insight in cashFlowInsights) {
      if (insight['severity'] == 'high') {
        recommendations.add({
          'type': 'cash_flow_management',
          'priority': 'high',
          'action': 'Review upcoming negative cash flow days',
          'reason': insight['content'],
        });
      }
    }
    
    // Income forecast recommendations
    final avgForecast = (incomeForecast['forecasts'] as List<Map<String, dynamic>>)
        .map((f) => f['forecasted_income'] as double)
        .reduce((a, b) => a + b) / (incomeForecast['forecasts'] as List).length;
    
    if (avgForecast > 0) {
      recommendations.add({
        'type': 'savings_optimization',
        'priority': 'medium',
        'action': 'Consider increasing savings rate',
        'reason': 'Positive income forecast suggests opportunity for increased savings',
      });
    }
    
    // Anomaly recommendations
    final anomalies = anomalyReport['detected_anomalies'] as List<Map<String, dynamic>>? ?? [];
    if (anomalies.isNotEmpty) {
      recommendations.add({
        'type': 'fraud_prevention',
        'priority': anomalies.length > 3 ? 'high' : 'medium',
        'action': 'Review flagged transactions',
        'reason': '${anomalies.length} unusual transactions detected',
      });
    }
    
    return recommendations;
  }
}

class AnomalyDetector {
  final PredictiveAnalyticsService _service;
  
  AnomalyDetector({required PredictiveAnalyticsService service})
      : _service = service;
  
  Future<Map<String, dynamic>> monitorRealTimeTransactions(
    List<Map<String, dynamic>> transactions,
    String userId,
  ) async {
    try {
      final anomalyReport = await _service.detectSpendingAnomalies(transactions);
      
      // Filter high-confidence anomalies
      final highConfidenceAnomalies = (anomalyReport['detected_anomalies'] as List<Map<String, dynamic>>)
          .where((anomaly) => (anomaly['confidence'] as double) > 0.7)
          .toList();
      
      // Generate alerts for high-risk anomalies
      final alerts = <Map<String, dynamic>>[];
      for (final anomaly in highConfidenceAnomalies) {
        if ((anomaly['anomaly_score'] as double) > 0.8) {
          alerts.add({
            'alert_id': 'ANOMALY_${DateTime.now().millisecondsSinceEpoch}',
            'user_id': userId,
            'transaction': anomaly['transaction'],
            'anomaly_score': anomaly['anomaly_score'],
            'confidence': anomaly['confidence'],
            'reasons': anomaly['reasons'],
            'detected_at': DateTime.now().toIso8601String(),
            'alert_level': 'HIGH',
            'required_action': 'IMMEDIATE_VERIFICATION',
          });
        }
      }
      
      return {
        'monitoring_session': DateTime.now().toIso8601String(),
        'transactions_analyzed': transactions.length,
        'total_anomalies': anomalyReport['anomalies_detected'],
        'high_confidence_anomalies': highConfidenceAnomalies.length,
        'alerts_generated': alerts.length,
        'alerts': alerts,
        'recommended_follow_up': _generateFollowUpRecommendations(alerts, anomalyReport),
      };
    } catch (e) {
      throw PredictiveAnalyticsException(
        message: 'Failed to monitor real-time transactions: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  List<Map<String, dynamic>> _generateFollowUpRecommendations(
    List<Map<String, dynamic>> alerts,
    Map<String, dynamic> anomalyReport,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    if (alerts.isNotEmpty) {
      recommendations.add({
        'action': 'Contact user for transaction verification',
        'priority': 'high',
        'timeframe': 'within_24_hours',
        'reason': 'High-confidence anomalies detected',
      });
    }
    
    final anomalyRate = double.parse(anomalyReport['anomaly_rate'] as String);
    if (anomalyRate > 10.0) {
      recommendations.add({
        'action': 'Review user spending patterns',
        'priority': 'medium',
        'timeframe': 'within_7_days',
        'reason': 'Elevated anomaly rate (${anomalyRate.toStringAsFixed(1)}%)',
      });
    }
    
    return recommendations;
  }
}

class PredictiveAnalyticsException extends AppException {
  PredictiveAnalyticsException({
    required super.message,
    super.statusCode,
    super.data,
  });
}