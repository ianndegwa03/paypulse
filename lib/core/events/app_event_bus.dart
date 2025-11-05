// lib/core/events/app_event_bus.dart
class AppEventBus {
  static final _instance = AppEventBus._internal();
  final _controller = StreamController<AppEvent>.broadcast();
  
  Stream<AppEvent> get stream => _controller.stream;
  
  void emit(AppEvent event) {
    _controller.add(event);
    
    // Auto-log important events
    if (event is CriticalAppEvent) {
      AnalyticsService.recordEvent(event);
    }
  }
  
  void listen<T extends AppEvent>(void Function(T) handler) {
    _controller.stream.where((event) => event is T).cast<T>().listen(handler);
  }
}


// Example usage: Transaction completes → Trigger multiple actions
// class TransactionCompletedEvent implements AppEvent {
//   final Transaction transaction;
//   const TransactionCompletedEvent(this.transaction);
// }

// // In different modules:
// AppEventBus.instance.listen<TransactionCompletedEvent>((event) {
//   // Analytics module tracks it
//   analyticsRepository.recordTransaction(event.transaction);
  
//   // Rewards module gives points
//   rewardsEngine.awardPointsForTransaction(event.transaction);
  
//   // AI module learns spending pattern
//   personalizationEngine.learnFromTransaction(event.transaction);
// });