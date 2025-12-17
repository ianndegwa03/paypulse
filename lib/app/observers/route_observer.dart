import 'package:flutter/widgets.dart';
import 'package:paypulse/core/logging/logger_service.dart';

/// Route observer for tracking navigation events
class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    LoggerService.instance.d(
      'Pushed route: ${route.settings.name}',
      tag: 'Navigation',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    LoggerService.instance.d(
      'Popped route: ${route.settings.name}',
      tag: 'Navigation',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    LoggerService.instance.d(
      'Replaced route: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}',
      tag: 'Navigation',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    LoggerService.instance.d(
      'Removed route: ${route.settings.name}',
      tag: 'Navigation',
    );
  }
}
