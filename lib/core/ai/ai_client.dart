import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paypulse/app/config/app_config.dart';
import 'package:paypulse/app/config/feature_flags.dart';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/core/ai/models/cost_tracker.dart';

abstract class AIClient {
  Future<String> generateResponse(String prompt,
      {Map<String, dynamic>? context});
  Future<Map<String, dynamic>> analyzeFinancialData(Map<String, dynamic> data);
  Future<List<String>> getRecommendations(Map<String, dynamic> userData);
  Future<double> predictSpending(Map<String, dynamic> historicalData);
  Future<String> categorizeTransaction(Map<String, dynamic> transaction);
  Future<Map<String, dynamic>> getFinancialInsights(Map<String, dynamic> data);
  Future<void> updateContext(Map<String, dynamic> context);
  Future<Map<String, dynamic>> analyzeInvestmentPortfolio(
      Map<String, dynamic> portfolio);
  Future<String> generateBudgetPlan(Map<String, dynamic> financialData);
  Future<Map<String, dynamic>> detectAnomalies(
      List<Map<String, dynamic>> transactions);
}

class AIClientImpl implements AIClient {
  final http.Client _httpClient;
  final CostTracker _costTracker;
  final Map<String, dynamic> _context;

  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4-turbo-preview';

  AIClientImpl({
    required http.Client httpClient,
    required CostTracker costTracker,
  })  : _httpClient = httpClient,
        _costTracker = costTracker,
        _context = {};

  @override
  Future<String> generateResponse(String prompt,
      {Map<String, dynamic>? context}) async {
    try {
      if (!AppConfig.isFeatureEnabled(Feature.aiFinancialAssistant)) {
        throw AIException(message: 'AI features are disabled');
      }

      final apiKey = AppConfig.environment.openAIApiKey;
      if (apiKey.isEmpty) {
        throw AIException(message: 'OpenAI API key not configured');
      }

      final messages = _buildMessages(prompt, context);
      final requestBody = {
        'model': _model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 1000,
      };

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200) {
        throw AIException(
          message: 'AI API request failed: ${response.statusCode}',
          data: {'statusCode': response.statusCode, 'response': response.body},
        );
      }

      final responseData = json.decode(response.body);
      final choices = responseData['choices'] as List;
      if (choices.isEmpty) {
        throw AIException(message: 'No response from AI');
      }

      final content = choices.first['message']['content'] as String;

      final usage = responseData['usage'] as Map<String, dynamic>;
      await _costTracker.trackUsage(
        model: _model,
        promptTokens: usage['prompt_tokens'] as int,
        completionTokens: usage['completion_tokens'] as int,
      );

      return content;
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(
        message: 'Failed to generate AI response: $e',
        data: {'error': e.toString()},
      );
    }
  }

  List<Map<String, dynamic>> _buildMessages(
      String prompt, Map<String, dynamic>? context) {
    final messages = <Map<String, dynamic>>[];

    final systemMessage = '''
    You are PayPulse AI, a financial assistant specializing in personal finance, 
    budgeting, investments, and financial planning.
    
    Current Context:
    ${_buildContextString(context)}
    
    Guidelines:
    1. Provide accurate, actionable financial advice
    2. Always consider user's financial security
    3. Suggest specific numbers when possible
    4. Be empathetic and non-judgmental
    5. Focus on practical steps users can take
    ''';

    messages.add({
      'role': 'system',
      'content': systemMessage,
    });

    messages.add({
      'role': 'user',
      'content': prompt,
    });

    return messages;
  }

  String _buildContextString(Map<String, dynamic>? additionalContext) {
    final context = {..._context, ...?additionalContext};

    if (context.isEmpty) return 'No specific context provided.';

    return context.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }

  @override
  Future<Map<String, dynamic>> analyzeFinancialData(
      Map<String, dynamic> data) async {
    try {
      final prompt = '''
      Analyze this financial data and provide insights:
      ${json.encode(data)}
      
      Provide analysis in this format:
      1. Overall financial health score (0-100)
      2. Key strengths
      3. Areas for improvement
      4. Specific recommendations
      5. Risk assessment
      ''';

      final response = await generateResponse(prompt);

      return {
        'analysis': response,
        'timestamp': DateTime.now().toIso8601String(),
        'data_points_analyzed': data.length,
      };
    } catch (e) {
      throw AIException(
        message: 'Failed to analyze financial data: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<List<String>> getRecommendations(Map<String, dynamic> userData) async {
    try {
      final prompt = '''
      Based on this user profile, provide 5 personalized financial recommendations:
      ${json.encode(userData)}
      
      Format each recommendation as a concise actionable item.
      ''';

      final response = await generateResponse(prompt);

      final recommendations = response
          .split('\n')
          .where((line) =>
              line.trim().isNotEmpty && line.contains(RegExp(r'^\d+\.')))
          .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), ''))
          .toList();

      return recommendations;
    } catch (e) {
      throw AIException(
        message: 'Failed to get recommendations: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<double> predictSpending(Map<String, dynamic> historicalData) async {
    try {
      final prompt = '''
      Predict next month's spending based on historical data:
      ${json.encode(historicalData)}
      
      Respond with only a number (the predicted amount).
      ''';

      final response = await generateResponse(prompt);

      final prediction = double.tryParse(response.trim());
      if (prediction == null) {
        throw AIException(message: 'Invalid prediction response: $response');
      }

      return prediction;
    } catch (e) {
      throw AIException(
        message: 'Failed to predict spending: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<String> categorizeTransaction(Map<String, dynamic> transaction) async {
    try {
      final prompt = '''
      Categorize this transaction into one of these categories:
      - Food & Dining
      - Transportation
      - Entertainment
      - Shopping
      - Bills & Utilities
      - Healthcare
      - Education
      - Investments
      - Income
      - Other
      
      Transaction details:
      ${json.encode(transaction)}
      
      Respond with only the category name.
      ''';

      final response = await generateResponse(prompt);
      return response.trim();
    } catch (e) {
      throw AIException(
        message: 'Failed to categorize transaction: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getFinancialInsights(
      Map<String, dynamic> data) async {
    try {
      final prompt = '''
      Provide detailed financial insights for this data:
      ${json.encode(data)}
      
      Include:
      1. Spending patterns
      2. Saving opportunities
      3. Investment suggestions
      4. Risk factors
      5. Goal progress
      ''';

      final response = await generateResponse(prompt);

      final insights = _parseInsightsResponse(response);

      return {
        'insights': insights,
        'summary': _generateSummary(insights),
        'action_items': _extractActionItems(response),
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw AIException(
        message: 'Failed to get financial insights: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> updateContext(Map<String, dynamic> context) async {
    _context.addAll(context);
  }

  @override
  Future<Map<String, dynamic>> analyzeInvestmentPortfolio(
      Map<String, dynamic> portfolio) async {
    try {
      final prompt = '''
      Analyze this investment portfolio:
      ${json.encode(portfolio)}
      
      Provide:
      1. Risk assessment
      2. Diversification score
      3. Recommended adjustments
      4. Expected returns
      5. Tax implications
      ''';

      final response = await generateResponse(prompt);

      return {
        'portfolio_analysis': response,
        'analyzed_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw AIException(
        message: 'Failed to analyze investment portfolio: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<String> generateBudgetPlan(Map<String, dynamic> financialData) async {
    try {
      final prompt = '''
      Create a personalized budget plan based on:
      ${json.encode(financialData)}
      
      Include:
      1. Monthly allocation per category
      2. Savings targets
      3. Debt repayment strategy
      4. Emergency fund recommendations
      ''';

      return await generateResponse(prompt);
    } catch (e) {
      throw AIException(
        message: 'Failed to generate budget plan: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<Map<String, dynamic>> detectAnomalies(
      List<Map<String, dynamic>> transactions) async {
    try {
      final prompt = '''
      Analyze these transactions for anomalies or suspicious activity:
      ${json.encode(transactions)}
      
      Report any:
      1. Unusual spending patterns
      2. Potential fraud indicators
      3. Unexpected large transactions
      4. Geographic anomalies
      ''';

      final response = await generateResponse(prompt);

      return {
        'anomalies_detected': response.isNotEmpty,
        'analysis': response,
        'transaction_count': transactions.length,
        'analyzed_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw AIException(
        message: 'Failed to detect anomalies: $e',
        data: {'error': e.toString()},
      );
    }
  }

  Map<String, dynamic> _parseInsightsResponse(String response) {
    final insights = <String, dynamic>{};

    final sections = response.split(RegExp(r'\d+\.\s+'));
    for (final section in sections) {
      if (section.trim().isNotEmpty) {
        final lines = section.split('\n');
        if (lines.isNotEmpty) {
          final title = lines.first.trim();
          final content =
              lines.skip(1).where((line) => line.trim().isNotEmpty).join('\n');
          insights[title] = content;
        }
      }
    }

    return insights;
  }

  String _generateSummary(Map<String, dynamic> insights) {
    if (insights.isEmpty) return 'No insights available.';

    final keyPoints = insights.keys.take(3).map((key) => '• $key').join('\n');
    return 'Key Insights:\n$keyPoints';
  }

  List<String> _extractActionItems(String response) {
    final actionItems = <String>[];
    final lines = response.split('\n');

    for (final line in lines) {
      if (line.contains(RegExp(r'[•\-*]\s+')) || line.contains('action:')) {
        actionItems.add(line.trim());
      }
    }

    return actionItems.take(5).toList();
  }
}

class AIException extends AppException {
  AIException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class MockAIClient implements AIClient {
  @override
  Future<String> generateResponse(String prompt,
      {Map<String, dynamic>? context}) async {
    return 'Mock AI Response: $prompt';
  }

  @override
  Future<Map<String, dynamic>> analyzeFinancialData(
      Map<String, dynamic> data) async {
    return {
      'analysis': 'Mock analysis of ${data.length} items',
      'health_score': 85.0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<List<String>> getRecommendations(Map<String, dynamic> userData) async {
    return [
      'Mock recommendation 1',
      'Mock recommendation 2',
      'Mock recommendation 3',
    ];
  }

  @override
  Future<double> predictSpending(Map<String, dynamic> historicalData) async {
    return 1500.0;
  }

  @override
  Future<String> categorizeTransaction(Map<String, dynamic> transaction) async {
    return 'Other';
  }

  @override
  Future<Map<String, dynamic>> getFinancialInsights(
      Map<String, dynamic> data) async {
    return {
      'insights': {'summary': 'Mock insights'},
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<void> updateContext(Map<String, dynamic> context) async {}

  @override
  Future<Map<String, dynamic>> analyzeInvestmentPortfolio(
      Map<String, dynamic> portfolio) async {
    return {
      'analysis': 'Mock portfolio analysis',
      'risk_score': 0.5,
    };
  }

  @override
  Future<String> generateBudgetPlan(Map<String, dynamic> financialData) async {
    return 'Mock Budget Plan: 50/30/20 rule suggested.';
  }

  @override
  Future<Map<String, dynamic>> detectAnomalies(
      List<Map<String, dynamic>> transactions) async {
    return {
      'anomalies_detected': false,
      'analysis': 'No anomalies found (mock).',
    };
  }
}
