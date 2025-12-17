import 'package:paypulse/core/services/local_storage/storage_service.dart';

class CostTracker {
  final StorageService _storage;
  static const String _storageKey = 'ai_cost_tracking';
  
  final Map<String, double> _modelCosts = {
    'gpt-4-turbo-preview': 0.01, // $0.01 per 1K tokens
    'gpt-4': 0.03,
    'gpt-3.5-turbo': 0.001,
    'text-davinci-003': 0.02,
  };
  
  double _totalCost = 0;
  int _totalTokens = 0;
  Map<String, int> _modelUsage = {};
  
  CostTracker({StorageService? storage}) 
      : _storage = storage ?? StorageServiceImpl() {
    _loadCostData();
  }
  
  Future<void> _loadCostData() async {
    try {
      await _storage.init();
      final data = await _storage.getObject(_storageKey);
      
      if (data != null) {
        _totalCost = (data['total_cost'] as num).toDouble();
        _totalTokens = data['total_tokens'] as int;
        _modelUsage = Map<String, int>.from(data['model_usage'] as Map);
      }
    } catch (e) {
      // Initialize with defaults if loading fails
      _totalCost = 0;
      _totalTokens = 0;
      _modelUsage = {};
    }
  }
  
  Future<void> _saveCostData() async {
    try {
      final data = {
        'total_cost': _totalCost,
        'total_tokens': _totalTokens,
        'model_usage': _modelUsage,
        'last_updated': DateTime.now().toIso8601String(),
      };
      
      await _storage.saveObject(_storageKey, data);
    } catch (e) {
      print('Failed to save cost data: $e');
    }
  }
  
  Future<void> trackUsage({
    required String model,
    required int promptTokens,
    required int completionTokens,
  }) async {
    final totalTokens = promptTokens + completionTokens;
    final costPerToken = _modelCosts[model] ?? 0.01;
    final cost = (totalTokens / 1000) * costPerToken;
    
    _totalCost += cost;
    _totalTokens += totalTokens;
    
    _modelUsage.update(
      model,
      (value) => value + totalTokens,
      ifAbsent: () => totalTokens,
    );
    
    await _saveCostData();
    
    print('AI Cost Tracking:');
    print('  Model: $model');
    print('  Prompt tokens: $promptTokens');
    print('  Completion tokens: $completionTokens');
    print('  Total tokens: $totalTokens');
    print('  Cost: \$${cost.toStringAsFixed(4)}');
    print('  Running total: \$${_totalCost.toStringAsFixed(2)}');
  }
  
  Map<String, dynamic> getCostSummary() {
    return {
      'total_cost': _totalCost,
      'total_tokens': _totalTokens,
      'average_cost_per_token': _totalTokens > 0 ? _totalCost / _totalTokens : 0,
      'model_breakdown': Map.from(_modelUsage),
      'most_used_model': _getMostUsedModel(),
      'cost_per_model': _getCostPerModel(),
    };
  }
  
  String? _getMostUsedModel() {
    if (_modelUsage.isEmpty) return null;
    
    return _modelUsage.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  Map<String, double> _getCostPerModel() {
    final costs = <String, double>{};
    
    for (final entry in _modelUsage.entries) {
      final model = entry.key;
      final tokens = entry.value;
      final costPerToken = _modelCosts[model] ?? 0.01;
      final cost = (tokens / 1000) * costPerToken;
      costs[model] = cost;
    }
    
    return costs;
  }
  
  Future<void> resetTracking() async {
    _totalCost = 0;
    _totalTokens = 0;
    _modelUsage.clear();
    await _saveCostData();
  }
  
  Future<void> setBudget(double monthlyBudget) async {
    final data = {
      'monthly_budget': monthlyBudget,
      'budget_set_at': DateTime.now().toIso8601String(),
    };
    
    await _storage.saveObject('ai_budget', data);
  }
  
  Future<double?> getMonthlyBudget() async {
    final data = await _storage.getObject('ai_budget');
    if (data == null) return null;
    
    return (data['monthly_budget'] as num).toDouble();
  }
  
  Future<Map<String, dynamic>> getBudgetStatus() async {
    final budget = await getMonthlyBudget();
    if (budget == null) {
      return {
        'budget_set': false,
        'message': 'No budget set',
      };
    }
    
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysElapsed = now.day;
    final daysRemaining = daysInMonth - daysElapsed;
    
    final dailyBudget = budget / daysInMonth;
    // final expectedSpendSoFar = dailyBudget * daysElapsed;
    final remainingBudget = budget - _totalCost;
    final dailyRemainingBudget = remainingBudget / daysRemaining;
    
    final status = _totalCost <= budget ? 'within_budget' : 'over_budget';
    
    return {
      'budget_set': true,
      'monthly_budget': budget,
      'current_spend': _totalCost,
      'remaining_budget': remainingBudget,
      'daily_budget': dailyBudget,
      'daily_remaining_budget': dailyRemainingBudget,
      'status': status,
      'over_budget_by': status == 'over_budget' ? _totalCost - budget : 0,
      'budget_utilization_percentage': (_totalCost / budget) * 100,
    };
  }
  
  void dispose() {
    // Cleanup if needed
  }
}