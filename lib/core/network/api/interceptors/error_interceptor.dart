import 'package:dio/dio.dart';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/core/logging/logger_service.dart';

/// Interceptor for handling HTTP errors and converting them to app exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioErrorToAppException(err);

    LoggerService.instance.e(
      'HTTP Error: ${err.message}',
      tag: 'HTTP',
      error: exception,
    );

    // Continue with the error
    handler.next(err);
  }

  AppException _mapDioErrorToAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(
          message: 'Connection timed out. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection. Please check your network.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(err.response);

      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled.',
        );

      default:
        return NetworkException(
          message: err.message ?? 'An unexpected error occurred.',
        );
    }
  }

  AppException _handleBadResponse(Response? response) {
    if (response == null) {
      return const ServerException(
        message: 'Server returned an invalid response.',
      );
    }

    switch (response.statusCode) {
      case 400:
        return const ValidationException(
          message: 'Invalid request. Please check your input.',
          statusCode: 400,
        );
      case 401:
        return const AuthException(
          message: 'Unauthorized. Please log in again.',
          statusCode: 401,
        );
      case 403:
        return const AuthException(
          message: 'Access denied.',
          statusCode: 403,
        );
      case 404:
        return const ServerException(
          message: 'Resource not found.',
          statusCode: 404,
        );
      case 500:
      case 502:
      case 503:
        return const ServerException(
          message: 'Server error. Please try again later.',
          statusCode: 500,
        );
      default:
        return ServerException(
          message: 'Request failed with status ${response.statusCode}.',
          statusCode: response.statusCode,
        );
    }
  }
}
