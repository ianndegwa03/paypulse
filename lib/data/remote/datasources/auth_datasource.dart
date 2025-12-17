import 'package:dio/dio.dart';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/data/models/response/auth_response.dart';
import 'package:paypulse/data/remote/api/interfaces/auth_api_interface.dart';

abstract class AuthDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(
    String email,
    String password,
    String firstName,
    String lastName,
  );
  Future<void> logout();
  Future<void> validateToken(String token);
  Future<void> forgotPassword(String email);
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  });
  Future<void> resetPassword(String token, String newPassword);
}

class AuthDataSourceImpl implements AuthDataSource {
  final AuthApiInterface _api;

  AuthDataSourceImpl(this._api);

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _api.login({
        'email': email,
        'password': password,
      });
      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Login failed',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Login failed: $e');
    }
  }

  @override
  Future<AuthResponse> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final response = await _api.register({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      });
      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Registration failed',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _api.logout();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Logout failed',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Logout failed: $e');
    }
  }

  @override
  Future<void> validateToken(String token) async {
    try {
      await _api.validateToken(token);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Token validation failed',
        statusCode: e.response?.statusCode ?? 401,
      );
    } catch (e) {
      throw ServerException(message: 'Token validation failed: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _api.forgotPassword({'email': email});
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Forgot password failed',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Forgot password failed: $e');
    }
  }

  @override
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      await _api.updateProfile({
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      });
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Update profile failed',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Update profile failed: $e');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _api.resetPassword({
        'token': token,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Password reset failed',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Password reset failed: $e');
    }
  }
}
