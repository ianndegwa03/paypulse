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

  final String username;
  final List<String> unlockedFeatures;

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
    required this.username,
    this.preferences = const {},
    this.securitySettings = const {},
    this.unlockedFeatures = const [],
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.occupation,
    this.nationality,
    this.privacyLevel = 'Public',
    this.stealthModeEnabled = false,
    this.isProfessionalProfileVisible = false,
    this.professionalBio,
  });

  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? occupation;
  final String? nationality;
  final String privacyLevel; // Public, ContactsOnly, Stealth
  final bool stealthModeEnabled;
  final bool isProfessionalProfileVisible;
  final String? professionalBio;

  String get fullName => '$firstName $lastName';

  bool get isPremiumUser => role == UserRole.premium || role == UserRole.admin;

  bool hasFeatureUnlocked(String featureKey) {
    if (isPremiumUser) return true; // Full premium unlocks everything
    return unlockedFeatures.contains(featureKey);
  }

  bool get isAdmin => role == UserRole.admin;

  bool get isEmployee => role == UserRole.employee || role == UserRole.admin;

  bool get hasBiometricEnabled => securitySettings['biometric_enabled'] == true;

  @override
  List<Object?> get props => [
        id,
        email,
        username,
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
      ];

  UserEntity copyWith({
    String? id,
    Email? email,
    String? firstName,
    String? username,
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
    List<String>? unlockedFeatures,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? occupation,
    String? nationality,
    String? privacyLevel,
    bool? stealthModeEnabled,
    bool? isProfessionalProfileVisible,
    String? professionalBio,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
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
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
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
    );
  }
}
