// lib/core/monitoring/performance/performance_monitor.dart
class PerformanceMonitor {
  static void trackFeatureLoad(String feature, Duration loadTime) {
    AnalyticsService.recordEvent(FeatureLoadEvent(
      feature: feature,
      loadTime: loadTime,
      deviceInfo: DeviceInfo.current,
    ));
    
    if (loadTime > const Duration(seconds: 2)) {
      CrashReporter.recordPerformanceIssue(
        'Slow feature load: $feature',
        loadTime: loadTime,
      );
    }
  }
  
  static void trackMemoryUsage() {
    final memory = MemoryMonitor.currentUsage;
    if (memory > MemoryMonitor.warningThreshold) {
      // Trigger memory cleanup
      MemoryMonitor.cleanupCaches();
    }
  }
}
