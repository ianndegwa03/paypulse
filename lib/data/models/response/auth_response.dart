import 'package:equatable/equatable.dart';

/// Response model for authentication operations
class AuthResponse extends Equatable {
  final String? userId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? phoneNumber;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final DateTime? expiresAt;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;
  final String? profileImageUrl;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? occupation;
  final String? nationality;
  final String? privacyLevel;
  final bool? stealthModeEnabled;
  final bool? isProfessionalProfileVisible;
  final String? professionalBio;
  final String? message;
  final bool success;

  const AuthResponse({
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
    this.username,
    this.phoneNumber,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.expiresAt,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.profileImageUrl,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.occupation,
    this.nationality,
    this.privacyLevel,
    this.stealthModeEnabled,
    this.isProfessionalProfileVisible,
    this.professionalBio,
    this.message,
    this.success = true,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['user_id'] as String? ?? json['userId'] as String?,
      email: json['email'] as String?,
      firstName: json['first_name'] as String? ?? json['firstName'] as String?,
      lastName: json['last_name'] as String? ?? json['lastName'] as String?,
      username: json['username'] as String?,
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
      bio: json['bio'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : (json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'] as String)
              : null),
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      occupation: json['occupation'] as String?,
      nationality: json['nationality'] as String?,
      privacyLevel:
          json['privacy_level'] as String? ?? json['privacyLevel'] as String?,
      stealthModeEnabled: json['stealth_mode_enabled'] as bool? ??
          json['stealthModeEnabled'] as bool?,
      isProfessionalProfileVisible:
          json['is_professional_profile_visible'] as bool? ??
              json['isProfessionalProfileVisible'] as bool?,
      professionalBio: json['professional_bio'] as String? ??
          json['professionalBio'] as String?,
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
      'username': username,
      'phone_number': phoneNumber,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'expires_at': expiresAt?.toIso8601String(),
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'occupation': occupation,
      'nationality': nationality,
      'privacy_level': privacyLevel,
      'stealth_mode_enabled': stealthModeEnabled,
      'is_professional_profile_visible': isProfessionalProfileVisible,
      'professional_bio': professionalBio,
      'message': message,
      'success': success,
    };
  }

  AuthResponse copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? username,
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
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      expiresAt: expiresAt ?? this.expiresAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      occupation: occupation ?? this.occupation,
      nationality: nationality ?? this.nationality,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      stealthModeEnabled: stealthModeEnabled ?? this.stealthModeEnabled,
      isProfessionalProfileVisible:
          isProfessionalProfileVisible ?? this.isProfessionalProfileVisible,
      professionalBio: professionalBio ?? this.professionalBio,
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
        username,
        phoneNumber,
        accessToken,
        refreshToken,
        expiresIn,
        expiresAt,
        isEmailVerified,
        isPhoneVerified,
        profileImageUrl,
        bio,
        dateOfBirth,
        gender,
        address,
        occupation,
        nationality,
        privacyLevel,
        stealthModeEnabled,
        isProfessionalProfileVisible,
        professionalBio,
        message,
        success,
      ];
}
