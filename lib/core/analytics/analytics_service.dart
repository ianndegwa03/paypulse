import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:paypulse/app/config/app_config.dart';
import 'package:paypulse/core/errors/exceptions.dart';

abstract class AnalyticsService {
  Future<void> initialize();
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});
  Future<void> logLogin({required String method});
  Future<void> logSignUp({required String method});
  Future<void> logScreenView({required String screenName});
  Future<void> setUserProperty(String name, String value);
  Future<void> setUserId(String userId);
  Future<void> resetAnalyticsData();
  Future<void> logException(
      {required Exception exception, StackTrace? stackTrace});
  Future<void> logPerformance({required String name, required int duration});
}

class AnalyticsServiceImpl implements AnalyticsService {
  final FirebaseAnalytics _firebaseAnalytics;

  AnalyticsServiceImpl({FirebaseAnalytics? firebaseAnalytics})
      : _firebaseAnalytics = firebaseAnalytics ?? FirebaseAnalytics.instance;

  @override
  Future<void> initialize() async {
    if (!AppConfig.enableAnalytics) {
      return;
    }

    try {
      await _firebaseAnalytics.setAnalyticsCollectionEnabled(true);
      await _firebaseAnalytics
          .setSessionTimeoutDuration(const Duration(minutes: 30));
    } catch (e) {
      throw AnalyticsException(
        message: 'Failed to initialize analytics: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    if (!AppConfig.enableAnalytics) {
      return;
    }

    try {
      await _firebaseAnalytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Don't throw in production, just log
      print('Failed to log event $name: $e');
    }
  }

  @override
  Future<void> logLogin({required String method}) async {
    await logEvent('login', parameters: {'method': method});
  }

  @override
  Future<void> logSignUp({required String method}) async {
    await logEvent('sign_up', parameters: {'method': method});
  }

  @override
  Future<void> logScreenView({required String screenName}) async {
    await logEvent('screen_view', parameters: {'screen_name': screenName});
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    if (!AppConfig.enableAnalytics) {
      return;
    }

    try {
      await _firebaseAnalytics.setUserProperty(name: name, value: value);
    } catch (e) {
      print('Failed to set user property $name: $e');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    if (!AppConfig.enableAnalytics) {
      return;
    }

    try {
      await _firebaseAnalytics.setUserId(id: userId);
    } catch (e) {
      print('Failed to set user ID: $e');
    }
  }

  @override
  Future<void> resetAnalyticsData() async {
    if (!AppConfig.enableAnalytics) {
      return;
    }

    try {
      await _firebaseAnalytics.resetAnalyticsData();
    } catch (e) {
      print('Failed to reset analytics data: $e');
    }
  }

  @override
  Future<void> logException(
      {required Exception exception, StackTrace? stackTrace}) async {
    await logEvent('exception', parameters: {
      'exception_type': exception.runtimeType.toString(),
      'exception_message': exception.toString(),
      'stack_trace': stackTrace?.toString(),
    });
  }

  @override
  Future<void> logPerformance(
      {required String name, required int duration}) async {
    await logEvent('performance', parameters: {
      'metric_name': name,
      'duration_ms': duration,
    });
  }

  // Custom event methods for PayPulse

  Future<void> logTransaction({
    required String type,
    required double amount,
    String? category,
    String? currency,
  }) async {
    await logEvent('transaction', parameters: {
      'type': type,
      'amount': amount,
      'category': category,
      'currency': currency,
    });
  }

  Future<void> logWalletAction({
    required String action,
    required double amount,
    String? walletType,
  }) async {
    await logEvent('wallet_action', parameters: {
      'action': action,
      'amount': amount,
      'wallet_type': walletType,
    });
  }

  Future<void> logInvestmentAction({
    required String action,
    required String investmentType,
    double? amount,
    double? returnRate,
  }) async {
    await logEvent('investment_action', parameters: {
      'action': action,
      'investment_type': investmentType,
      'amount': amount,
      'return_rate': returnRate,
    });
  }

  Future<void> logFeatureUsage({
    required String featureName,
    required String action,
    Map<String, dynamic>? additionalParams,
  }) async {
    final Map<String, dynamic> parameters = {
      'feature_name': featureName,
      'action': action,
    };

    if (additionalParams != null) {
      parameters.addAll(additionalParams);
    }

    await logEvent('feature_usage', parameters: parameters);
  }

  Future<void> logError({
    required String errorCode,
    required String errorMessage,
    String? screenName,
    Map<String, dynamic>? context,
  }) async {
    final Map<String, dynamic> parameters = {
      'error_code': errorCode,
      'error_message': errorMessage,
      'screen_name': screenName,
    };

    if (context != null) {
      parameters.addAll(context);
    }

    await logEvent('error', parameters: parameters);
  }

  Future<void> logUserJourney({
    required String journeyName,
    required String step,
    String? action,
    Map<String, dynamic>? metadata,
  }) async {
    final Map<String, dynamic> parameters = {
      'journey_name': journeyName,
      'step': step,
      'action': action,
    };

    if (metadata != null) {
      parameters.addAll(metadata);
    }

    await logEvent('user_journey', parameters: parameters);
  }
}

class AnalyticsException extends AppException {
  AnalyticsException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}
