import 'package:dio/dio.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/security/storage/secure_storage_service.dart';

/// Interceptor for attaching authentication tokens to requests
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    // Try to get auth token
    try {
      if (getIt.isRegistered<SecureStorageService>()) {
        final secureStorage = getIt<SecureStorageService>();
        final token = await secureStorage.readAuthToken();

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {
      // Continue without token if there's an error
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - refresh token or logout
    if (err.response?.statusCode == 401) {
      // Attempt to refresh token
      final refreshed = await _refreshToken();

      if (refreshed) {
        // Retry the original request
        try {
          final response = await _retryRequest(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {
          // If retry fails, continue with original error
        }
      }
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    const publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/refresh-token',
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  Future<bool> _refreshToken() async {
    // Token refresh logic would go here
    // For now, return false to indicate refresh failed
    return false;
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = Dio();
    return await dio.fetch(requestOptions);
  }
}
