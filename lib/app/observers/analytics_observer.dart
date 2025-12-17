import 'package:flutter/widgets.dart';
import 'package:paypulse/core/logging/logger_service.dart';

/// Observer for tracking navigation events for analytics
class AnalyticsObserver extends NavigatorObserver {
  /// Track when a screen is viewed
  void _trackScreenView(String? screenName) {
    if (screenName != null && screenName.isNotEmpty) {
      LoggerService.instance.d(
        'Screen viewed: $screenName',
        tag: 'Analytics',
      );
      // Add Firebase Analytics or other analytics here:
      // FirebaseAnalytics.instance.setCurrentScreen(screenName: screenName);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackScreenView(route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackScreenView(newRoute.settings.name);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackScreenView(previousRoute.settings.name);
    }
  }
}
