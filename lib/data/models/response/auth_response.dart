import 'package:equatable/equatable.dart';

/// Response model for authentication operations
class AuthResponse extends Equatable {
  final String? userId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final DateTime? expiresAt;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;
  final String? profileImageUrl;
  final String? message;
  final bool success;

  const AuthResponse({
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.expiresAt,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.profileImageUrl,
    this.message,
    this.success = true,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['user_id'] as String? ?? json['userId'] as String?,
      email: json['email'] as String?,
      firstName: json['first_name'] as String? ?? json['firstName'] as String?,
      lastName: json['last_name'] as String? ?? json['lastName'] as String?,
      phoneNumber:
          json['phone_number'] as String? ?? json['phoneNumber'] as String?,
      accessToken:
          json['access_token'] as String? ?? json['accessToken'] as String?,
      refreshToken:
          json['refresh_token'] as String? ?? json['refreshToken'] as String?,
      expiresIn: json['expires_in'] as int? ?? json['expiresIn'] as int?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      isEmailVerified:
          json['is_email_verified'] as bool? ?? json['emailVerified'] as bool?,
      isPhoneVerified:
          json['is_phone_verified'] as bool? ?? json['phoneVerified'] as bool?,
      profileImageUrl: json['profile_image_url'] as String? ??
          json['profileImageUrl'] as String?,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'expires_at': expiresAt?.toIso8601String(),
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'profile_image_url': profileImageUrl,
      'message': message,
      'success': success,
    };
  }

  AuthResponse copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    DateTime? expiresAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? profileImageUrl,
    String? message,
    bool? success,
  }) {
    return AuthResponse(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      expiresAt: expiresAt ?? this.expiresAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      message: message ?? this.message,
      success: success ?? this.success,
    );
  }

  /// Get full name
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  /// Check if token is expired
  bool get isTokenExpired {
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt!);
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        firstName,
        lastName,
        phoneNumber,
        accessToken,
        refreshToken,
        expiresIn,
        expiresAt,
        isEmailVerified,
        isPhoneVerified,
        profileImageUrl,
        message,
        success,
      ];
}
