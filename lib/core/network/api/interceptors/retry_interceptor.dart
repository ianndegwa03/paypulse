import 'package:dio/dio.dart';
import 'package:paypulse/core/logging/logger_service.dart';

/// Interceptor for retrying failed requests
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        LoggerService.instance.d(
          'Retrying request (${retryCount + 1}/$maxRetries): ${err.requestOptions.path}',
          tag: 'HTTP',
        );

        await Future.delayed(retryDelay * (retryCount + 1));

        final options = err.requestOptions;
        options.extra['retryCount'] = retryCount + 1;

        try {
          final dio = Dio();
          final response = await dio.fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue with original error if retry fails
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors and server errors (5xx)
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry on 5xx server errors
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && statusCode < 600) {
      return true;
    }

    return false;
  }
}
