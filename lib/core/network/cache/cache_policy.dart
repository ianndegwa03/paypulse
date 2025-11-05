// lib/core/network/cache/cache_policy.dart
enum CachePolicy {
  cacheFirst,    // Try cache, then network
  networkFirst,  // Try network, then cache
  cacheOnly,     // Only use cache
  networkOnly,   // Only use network
  refreshCache,  // Network, then update cache
}

class CacheStrategy {
  final CachePolicy policy;
  final Duration maxAge;
  final bool staleWhileRevalidate;
  
  const CacheStrategy({
    required this.policy,
    this.maxAge = const Duration(hours: 1),
    this.staleWhileRevalidate = true,
  });
}