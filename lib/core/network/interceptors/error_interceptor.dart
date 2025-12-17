import 'package:dio/dio.dart';
import 'package:paypulse/core/logging/logger_service.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerService.instance.e(
      'Network Error: ${err.message}',
      error: err,
      stackTrace: err.stackTrace,
    );

    // Continue with the error to let the repository handle it or map it here
    // For now, we just pass it through, but we could wrap it in a custom exception
    handler.next(err);
  }
}
