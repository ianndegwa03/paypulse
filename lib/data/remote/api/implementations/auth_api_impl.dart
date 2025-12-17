import 'package:dio/dio.dart';
import 'package:paypulse/data/models/response/auth_response.dart';
import 'package:paypulse/data/remote/api/interfaces/auth_api_interface.dart';

/// Implementation of AuthApiInterface using Dio
class AuthApiImpl implements AuthApiInterface {
  final Dio _dio;

  AuthApiImpl(this._dio);

  @override
  Future<AuthResponse> login(Map<String, dynamic> body) async {
    final response = await _dio.post(
      '/auth/login',
      data: body,
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> register(Map<String, dynamic> body) async {
    final response = await _dio.post(
      '/auth/register',
      data: body,
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  @override
  Future<AuthResponse> refreshToken(Map<String, dynamic> body) async {
    final response = await _dio.post(
      '/auth/refresh-token',
      data: body,
    );
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<void> forgotPassword(Map<String, dynamic> body) async {
    await _dio.post('/auth/forgot-password', data: body);
  }

  @override
  Future<void> resetPassword(Map<String, dynamic> body) async {
    await _dio.post('/auth/reset-password', data: body);
  }

  @override
  Future<void> validateToken(String token) async {
    await _dio.get('/auth/validate-token', queryParameters: {'token': token});
  }

  @override
  Future<void> verifyEmail(Map<String, dynamic> body) async {
    await _dio.post('/auth/verify-email', data: body);
  }

  @override
  Future<void> verifyPhone(Map<String, dynamic> body) async {
    await _dio.post('/auth/verify-phone', data: body);
  }

  @override
  Future<AuthResponse> updateProfile(Map<String, dynamic> body) async {
    final response = await _dio.put('/auth/profile', data: body);
    return AuthResponse.fromJson(response.data);
  }
}
