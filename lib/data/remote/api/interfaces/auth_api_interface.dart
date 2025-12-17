import 'package:paypulse/data/models/response/auth_response.dart';

/// Interface for authentication API operations
abstract class AuthApiInterface {
  Future<AuthResponse> login(Map<String, dynamic> body);
  Future<AuthResponse> register(Map<String, dynamic> body);
  Future<void> logout();
  Future<AuthResponse> refreshToken(Map<String, dynamic> body);
  Future<void> forgotPassword(Map<String, dynamic> body);
  Future<void> resetPassword(Map<String, dynamic> body);
  Future<void> validateToken(String token);
  Future<void> verifyEmail(Map<String, dynamic> body);
  Future<void> verifyPhone(Map<String, dynamic> body);
  Future<void> updateProfile(Map<String, dynamic> body);
}
