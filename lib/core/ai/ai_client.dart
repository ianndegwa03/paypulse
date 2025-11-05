// lib/core/ai/ai_client.dart
abstract class AiProvider {
  Future<AIResponse> chat(List<AIMessage> messages);
  Future<AIResponse> generateInsights(UserData data);
  Future<AISentiment> analyzeSentiment(String text);
}

class AIClient implements AiProvider {
  final AiProvider _provider;
  final ConversationContext _context;
  final CostTracker _costTracker;
  
  AIClient._(this._provider, this._context, this._costTracker);
  
  static Future<AIClient> create({AIModel model = AIModel.gpt4}) async {
    final provider = await _initializeProvider(model);
    final context = ConversationContext();
    final costTracker = CostTracker();
    
    return AIClient._(provider, context, costTracker);
  }
  
  @override
  Future<AIResponse> chat(List<AIMessage> messages) async {
    // Add context to messages
    final contextualMessages = await _context.enrichMessages(messages);
    
    final response = await _provider.chat(contextualMessages);
    
    // Track cost and learn from interaction
    _costTracker.recordUsage(response);
    await _context.learnFromInteraction(messages, response);
    
    return response;
  }
}