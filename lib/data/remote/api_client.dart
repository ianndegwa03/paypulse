import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:paypulse/core/errors/exceptions.dart';

/// A wrapper class for the Dio client that handles API requests.
class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio}) : _dio = dio ?? GetIt.instance<Dio>();

  /// Makes a GET request to the specified path.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Makes a POST request to the specified path.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Makes a PUT request to the specified path.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Makes a DELETE request to the specified path.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handles Dio errors and converts them to custom exceptions.
  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      switch (e.response!.statusCode) {
        case 400:
          throw NetworkException(
              message: e.response!.data['message'] ?? 'Bad request');
        case 401:
          throw AuthException(
              message: e.response!.data['message'] ?? 'Unauthorized');
        case 403:
          throw PermissionException(
              message: e.response!.data['message'] ?? 'Forbidden');
        case 404:
          throw NetworkException(
              message: e.response!.data['message'] ?? 'Not found');
        case 500:
          throw ServerException(
              message: e.response!.data['message'] ?? 'Server error');
        default:
          throw const ServerException(message: 'An unexpected error occurred.');
      }
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      return const ServerException(message: 'An unexpected error occurred.');
    }
  }
}
