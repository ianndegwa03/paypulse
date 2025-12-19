import 'dart:convert';
import 'package:paypulse/core/services/local_storage/storage_service.dart';
import 'package:paypulse/core/errors/exceptions.dart';

class MemoryManager {
  final StorageService _storageService;
  static const String _memoryKey = 'ai_conversation_memory';
  static const int _maxConversations = 50;
  
  MemoryManager({StorageService? storageService})
      : _storageService = storageService ?? StorageServiceImpl();
  
  Future<void> initialize() async {
    await _storageService.init();
  }
  
  Future<void> saveConversation({
    required String userId,
    required String conversationId,
    required List<Map<String, dynamic>> messages,
    required Map<String, dynamic> context,
  }) async {
    try {
      final memory = await _getMemory(userId);
      
      final conversation = {
        'id': conversationId,
        'timestamp': DateTime.now().toIso8601String(),
        'messages': messages,
        'context': context,
        'token_count': _calculateTokenCount(messages),
      };
      
      memory['conversations'][conversationId] = conversation;
      
      // Trim oldest conversations if exceeds limit
      if (memory['conversations'].length > _maxConversations) {
        _trimConversations(memory);
      }
      
      await _storageService.saveObject('${_memoryKey}_$userId', memory);
    } catch (e) {
      throw AIException(
        message: 'Failed to save conversation: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<List<Map<String, dynamic>>> getConversationHistory({
    required String userId,
    String? conversationId,
    int limit = 10,
  }) async {
    try {
      final memory = await _getMemory(userId);
      final conversations = memory['conversations'] as Map<String, dynamic>;
      
      if (conversationId != null) {
        final specific = conversations[conversationId];
        return specific != null ? [specific] : [];
      }
      
      final sorted = conversations.values.toList()
        ..sort((a, b) => (b['timestamp'] as String).compareTo(a['timestamp'] as String));
      
      return sorted.take(limit).cast<Map<String, dynamic>>().toList();
    } catch (e) {
      throw AIException(
        message: 'Failed to get conversation history: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<void> updateContext({
    required String userId,
    required String conversationId,
    required Map<String, dynamic> newContext,
  }) async {
    try {
      final memory = await _getMemory(userId);
      final conversations = memory['conversations'] as Map<String, dynamic>;
      
      if (conversations.containsKey(conversationId)) {
        final conversation = conversations[conversationId] as Map<String, dynamic>;
        final existingContext = conversation['context'] as Map<String, dynamic>;
        conversation['context'] = {...existingContext, ...newContext};
        
        await _storageService.saveObject('${_memoryKey}_$userId', memory);
      }
    } catch (e) {
      throw AIException(
        message: 'Failed to update context: $e',
        data: {'userId': userId, 'conversationId': conversationId, 'error': e.toString()},
      );
    }
  }
  
  Future<Map<String, dynamic>> getContext({
    required String userId,
    String? conversationId,
  }) async {
    try {
      final memory = await _getMemory(userId);
      
      if (conversationId != null) {
        final conversations = memory['conversations'] as Map<String, dynamic>;
        final conversation = conversations[conversationId];
        if (conversation != null) {
          return conversation['context'] as Map<String, dynamic>;
        }
      }
      
      return memory['global_context'] as Map<String, dynamic>;
    } catch (e) {
      throw AIException(
        message: 'Failed to get context: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<void> setGlobalContext({
    required String userId,
    required Map<String, dynamic> context,
  }) async {
    try {
      final memory = await _getMemory(userId);
      memory['global_context'] = context;
      await _storageService.saveObject('${_memoryKey}_$userId', memory);
    } catch (e) {
      throw AIException(
        message: 'Failed to set global context: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<void> deleteConversation({
    required String userId,
    required String conversationId,
  }) async {
    try {
      final memory = await _getMemory(userId);
      final conversations = memory['conversations'] as Map<String, dynamic>;
      conversations.remove(conversationId);
      
      await _storageService.saveObject('${_memoryKey}_$userId', memory);
    } catch (e) {
      throw AIException(
        message: 'Failed to delete conversation: $e',
        data: {'userId': userId, 'conversationId': conversationId, 'error': e.toString()},
      );
    }
  }
  
  Future<void> clearUserMemory(String userId) async {
    try {
      await _storageService.delete('${_memoryKey}_$userId');
    } catch (e) {
      throw AIException(
        message: 'Failed to clear user memory: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<Map<String, dynamic>> getMemoryStats(String userId) async {
    try {
      final memory = await _getMemory(userId);
      final conversations = memory['conversations'] as Map<String, dynamic>;
      
      int totalConversations = conversations.length;
      int totalTokens = 0;
      DateTime? oldestConversation;
      DateTime? newestConversation;
      
      for (final conversation in conversations.values) {
        final conv = conversation as Map<String, dynamic>;
        totalTokens += conv['token_count'] as int;
        
        final timestamp = DateTime.parse(conv['timestamp'] as String);
        if (oldestConversation == null || timestamp.isBefore(oldestConversation)) {
          oldestConversation = timestamp;
        }
        if (newestConversation == null || timestamp.isAfter(newestConversation)) {
          newestConversation = timestamp;
        }
      }
      
      return {
        'user_id': userId,
        'total_conversations': totalConversations,
        'total_tokens': totalTokens,
        'oldest_conversation': oldestConversation?.toIso8601String(),
        'newest_conversation': newestConversation?.toIso8601String(),
        'average_tokens_per_conversation': totalConversations > 0 ? totalTokens / totalConversations : 0,
        'memory_usage_mb': _estimateMemoryUsage(conversations),
      };
    } catch (e) {
      throw AIException(
        message: 'Failed to get memory stats: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
  
  Future<Map<String, dynamic>> _getMemory(String userId) async {
    final memory = await _storageService.getObject('${_memoryKey}_$userId');
    
    if (memory == null) {
      return {
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
        'global_context': {},
        'conversations': {},
      };
    }
    
    return memory;
  }
  
  int _calculateTokenCount(List<Map<String, dynamic>> messages) {
    // Simple token estimation: 4 characters ≈ 1 token
    int totalChars = 0;
    for (final message in messages) {
      totalChars += (message['content'] as String).length;
      totalChars += (message['role'] as String).length;
    }
    
    return (totalChars / 4).ceil();
  }
  
  void _trimConversations(Map<String, dynamic> memory) {
    final conversations = memory['conversations'] as Map<String, dynamic>;
    final sortedKeys = conversations.keys.toList()
      ..sort((a, b) {
        final timeA = DateTime.parse((conversations[a] as Map<String, dynamic>)['timestamp'] as String);
        final timeB = DateTime.parse((conversations[b] as Map<String, dynamic>)['timestamp'] as String);
        return timeA.compareTo(timeB);
      });
    
    // Keep only the most recent conversations
    final keysToRemove = sortedKeys.sublist(0, sortedKeys.length - _maxConversations);
    for (final key in keysToRemove) {
      conversations.remove(key);
    }
  }
  
  double _estimateMemoryUsage(Map<String, dynamic> conversations) {
    final jsonString = json.encode(conversations);
    return jsonString.length / (1024 * 1024); // Convert to MB
  }
  
  Future<String> generateConversationSummary({
    required String userId,
    required String conversationId,
  }) async {
    try {
      final conversation = await getConversationHistory(
        userId: userId,
        conversationId: conversationId,
      );
      
      if (conversation.isEmpty) {
        return 'No conversation found';
      }
      
      final messages = conversation.first['messages'] as List<dynamic>;
      final context = conversation.first['context'] as Map<String, dynamic>;
      
      final summary = {
        'conversation_id': conversationId,
        'timestamp': DateTime.now().toIso8601String(),
        'message_count': messages.length,
        'context_keys': context.keys.toList(),
        'last_message': messages.isNotEmpty ? messages.last : null,
      };
      
      return json.encode(summary);
    } catch (e) {
      throw AIException(
        message: 'Failed to generate conversation summary: $e',
        data: {'userId': userId, 'conversationId': conversationId, 'error': e.toString()},
      );
    }
  }
  
  Future<List<Map<String, dynamic>>> searchConversations({
    required String userId,
    required String query,
    int limit = 20,
  }) async {
    try {
      final memory = await _getMemory(userId);
      final conversations = memory['conversations'] as Map<String, dynamic>;
      
      final results = <Map<String, dynamic>>[];
      final queryLower = query.toLowerCase();
      
      for (final conversation in conversations.values) {
        final conv = conversation as Map<String, dynamic>;
        final messages = conv['messages'] as List<dynamic>;
        
        bool found = false;
        for (final message in messages) {
          final msg = message as Map<String, dynamic>;
          final content = msg['content'] as String;
          if (content.toLowerCase().contains(queryLower)) {
            found = true;
            break;
          }
        }
        
        if (found) {
          results.add(conv);
          if (results.length >= limit) break;
        }
      }
      
      return results;
    } catch (e) {
      throw AIException(
        message: 'Failed to search conversations: $e',
        data: {'userId': userId, 'query': query, 'error': e.toString()},
      );
    }
  }
}