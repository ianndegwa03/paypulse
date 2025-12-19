import 'dart:convert';
import 'package:paypulse/core/errors/exceptions.dart';

abstract class CacheManager {
  Future<void> init();
  Future<void> put(String key, dynamic value, {Duration? ttl});
  Future<dynamic> get(String key);
  Future<bool> containsKey(String key);
  Future<void> delete(String key);
  Future<void> clear();
  Future<void> clearExpired();
  Future<Map<String, dynamic>> getStats();
}

class CacheManagerImpl implements CacheManager {
  static const Duration _defaultTTL = Duration(days: 7);
  
  late final Map<String, _CacheEntry> _memoryCache;
  bool _isInitialized = false;
  
  CacheManagerImpl() {
    _memoryCache = {};
  }
  
  @override
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Initialize in-memory cache
      _memoryCache.clear();
      
      // Load persisted cache from storage if needed
      await _loadPersistedCache();
      
      _isInitialized = true;
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize cache manager: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Future<void> _loadPersistedCache() async {
    // Load cache from persistent storage if implemented
    // This could be from Hive, SharedPreferences, or SQLite
  }
  
  Future<void> _savePersistedCache() async {
    // Save cache to persistent storage if implemented
  }
  
  @override
  Future<void> put(String key, dynamic value, {Duration? ttl}) async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      final entry = _CacheEntry(
        value: value,
        ttl: ttl ?? _defaultTTL,
        createdAt: DateTime.now(),
      );
      
      _memoryCache[key] = entry;
      
      // Optionally persist to storage
      await _savePersistedCache();
    } catch (e) {
      throw CacheException(
        message: 'Failed to put value in cache: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }
  
  @override
  Future<dynamic> get(String key) async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      final entry = _memoryCache[key];
      if (entry == null) return null;
      
      // Check if entry is expired
      if (entry.isExpired) {
        await delete(key);
        return null;
      }
      
      return entry.value;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get value from cache: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }
  
  @override
  Future<bool> containsKey(String key) async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      final entry = _memoryCache[key];
      if (entry == null) return false;
      
      if (entry.isExpired) {
        await delete(key);
        return false;
      }
      
      return true;
    } catch (e) {
      throw CacheException(
        message: 'Failed to check key in cache: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }
  
  @override
  Future<void> delete(String key) async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      _memoryCache.remove(key);
      await _savePersistedCache();
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete value from cache: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }
  
  @override
  Future<void> clear() async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      _memoryCache.clear();
      await _savePersistedCache();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear cache: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  @override
  Future<void> clearExpired() async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      final expiredKeys = _memoryCache.entries
          .where((entry) => entry.value.isExpired)
          .map((entry) => entry.key)
          .toList();
      
      for (final key in expiredKeys) {
        _memoryCache.remove(key);
      }
      
      if (expiredKeys.isNotEmpty) {
        await _savePersistedCache();
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear expired cache: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  @override
  Future<Map<String, dynamic>> getStats() async {
    if (!_isInitialized) {
      await init();
    }
    
    try {
      final totalEntries = _memoryCache.length;
      final expiredEntries = _memoryCache.values.where((entry) => entry.isExpired).length;
      final validEntries = totalEntries - expiredEntries;
      
      final memoryUsage = _calculateMemoryUsage();
      
      return {
        'total_entries': totalEntries,
        'valid_entries': validEntries,
        'expired_entries': expiredEntries,
        'memory_usage_bytes': memoryUsage,
        'cache_hit_ratio': _calculateHitRatio(),
      };
    } catch (e) {
      throw CacheException(
        message: 'Failed to get cache stats: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  int _calculateMemoryUsage() {
    try {
      // Estimate memory usage by serializing cache entries
      final jsonString = json.encode(_memoryCache);
      return jsonString.length * 2; // Rough estimate for UTF-16
    } catch (_) {
      return 0;
    }
  }
  
  double _calculateHitRatio() {
    // This would require tracking hits and misses
    // For simplicity, returning a placeholder
    return 0.0;
  }
  
  // Specialized cache methods for PayPulse
  
  Future<void> cacheUserData(String userId, Map<String, dynamic> userData) async {
    await put('user_$userId', userData, ttl: const Duration(hours: 1));
  }
  
  Future<Map<String, dynamic>?> getCachedUserData(String userId) async {
    return await get('user_$userId');
  }
  
  Future<void> cacheWalletData(String walletId, Map<String, dynamic> walletData) async {
    await put('wallet_$walletId', walletData, ttl: const Duration(minutes: 30));
  }
  
  Future<Map<String, dynamic>?> getCachedWalletData(String walletId) async {
    return await get('wallet_$walletId');
  }
  
  Future<void> cacheTransactions(String userId, List<Map<String, dynamic>> transactions) async {
    await put('transactions_$userId', transactions, ttl: const Duration(minutes: 15));
  }
  
  Future<List<Map<String, dynamic>>?> getCachedTransactions(String userId) async {
    return await get('transactions_$userId');
  }
  
  Future<void> cacheMarketData(String symbol, Map<String, dynamic> marketData) async {
    await put('market_$symbol', marketData, ttl: const Duration(minutes: 5));
  }
  
  Future<Map<String, dynamic>?> getCachedMarketData(String symbol) async {
    return await get('market_$symbol');
  }
  
  Future<void> cacheExchangeRates(Map<String, double> rates) async {
    await put('exchange_rates', rates, ttl: const Duration(minutes: 10));
  }
  
  Future<Map<String, double>?> getCachedExchangeRates() async {
    return await get('exchange_rates');
  }
  
  // Bulk operations
  
  Future<void> putMany(Map<String, dynamic> entries, {Duration? ttl}) async {
    for (final entry in entries.entries) {
      await put(entry.key, entry.value, ttl: ttl);
    }
  }
  
  Future<Map<String, dynamic>> getMany(List<String> keys) async {
    final result = <String, dynamic>{};
    
    for (final key in keys) {
      final value = await get(key);
      if (value != null) {
        result[key] = value;
      }
    }
    
    return result;
  }
}

class _CacheEntry {
  final dynamic value;
  final Duration ttl;
  final DateTime createdAt;
  
  _CacheEntry({
    required this.value,
    required this.ttl,
    required this.createdAt,
  });
  
  bool get isExpired {
    final now = DateTime.now();
    final expiryTime = createdAt.add(ttl);
    return now.isAfter(expiryTime);
  }
  
  DateTime get expiresAt => createdAt.add(ttl);
  
  Duration get timeRemaining {
    final now = DateTime.now();
    final expiryTime = createdAt.add(ttl);
    return expiryTime.difference(now);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'ttl': ttl.inMilliseconds,
      'created_at': createdAt.toIso8601String(),
    };
  }
}