import 'package:dio/dio.dart';
import 'package:paypulse/core/logging/logger_service.dart';

/// Interceptor for logging HTTP requests and responses
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    LoggerService.instance.d(
      'REQUEST[${options.method}] => PATH: ${options.path}',
      tag: 'HTTP',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LoggerService.instance.d(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      tag: 'HTTP',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerService.instance.e(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      tag: 'HTTP',
      error: err,
    );
    handler.next(err);
  }
}
