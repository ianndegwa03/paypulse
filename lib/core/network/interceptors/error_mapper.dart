// lib/core/network/interceptors/error_mapper.dart
class ErrorMapper {
  static Failure mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure('Connection timeout');
      case DioExceptionType.badCertificate:
        return SecurityFailure('Invalid certificate');
      case DioExceptionType.badResponse:
        return _mapResponseError(error.response!);
      case DioExceptionType.cancel:
        return CancellationFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return NetworkFailure('No internet connection');
      case DioExceptionType.unknown:
        return UnknownFailure('Unknown error occurred');
    }
  }
}