import 'package:equatable/equatable.dart';

/// Request model for authentication operations
class AuthRequest extends Equatable {
  final String? email;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? token;
  final String? code;

  const AuthRequest({
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.phone,
    this.token,
    this.code,
  });

  /// Create a login request
  factory AuthRequest.login({
    required String email,
    required String password,
  }) {
    return AuthRequest(
      email: email,
      password: password,
    );
  }

  /// Create a registration request
  factory AuthRequest.register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
  }) {
    return AuthRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
  }

  /// Create a forgot password request
  factory AuthRequest.forgotPassword({
    required String email,
  }) {
    return AuthRequest(email: email);
  }

  /// Create a reset password request
  factory AuthRequest.resetPassword({
    required String token,
    required String password,
  }) {
    return AuthRequest(
      token: token,
      password: password,
    );
  }

  /// Create a verify email request
  factory AuthRequest.verifyEmail({
    required String token,
  }) {
    return AuthRequest(token: token);
  }

  /// Create a verify phone request
  factory AuthRequest.verifyPhone({
    required String code,
    required String phone,
  }) {
    return AuthRequest(
      code: code,
      phone: phone,
    );
  }

  /// Create a refresh token request
  factory AuthRequest.refreshToken({
    required String refreshToken,
  }) {
    return AuthRequest(token: refreshToken);
  }

  factory AuthRequest.fromJson(Map<String, dynamic> json) {
    return AuthRequest(
      email: json['email'] as String?,
      password: json['password'] as String?,
      firstName: json['first_name'] as String? ?? json['firstName'] as String?,
      lastName: json['last_name'] as String? ?? json['lastName'] as String?,
      phone: json['phone'] as String?,
      token: json['token'] as String?,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (token != null) data['token'] = token;
    if (code != null) data['code'] = code;
    return data;
  }

  @override
  List<Object?> get props =>
      [email, password, firstName, lastName, phone, token, code];
}
