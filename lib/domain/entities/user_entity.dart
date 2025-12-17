import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/value_objects/email.dart';
import 'package:paypulse/domain/value_objects/phone_number.dart';
import 'package:paypulse/domain/entities/enums.dart';

class UserEntity extends Equatable {
  final String id;
  final Email email;
  final String firstName;
  final String lastName;
  final PhoneNumber? phoneNumber;
  final String? profileImageUrl;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> securitySettings;

  final UserRole role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.createdAt,
    required this.updatedAt,
    this.preferences = const {},
    this.securitySettings = const {},
  });

  String get fullName => '$firstName $lastName';

  bool get isPremiumUser => role == UserRole.premium || role == UserRole.admin;

  bool get isAdmin => role == UserRole.admin;

  bool get isEmployee => role == UserRole.employee || role == UserRole.admin;

  bool get hasBiometricEnabled => securitySettings['biometric_enabled'] == true;

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phoneNumber,
        profileImageUrl,
        isEmailVerified,
        isPhoneVerified,
        createdAt,
        updatedAt,
        preferences,
        securitySettings,
      ];

  UserEntity copyWith({
    String? id,
    Email? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    PhoneNumber? phoneNumber,
    String? profileImageUrl,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? securitySettings,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      securitySettings: securitySettings ?? this.securitySettings,
    );
  }
}
