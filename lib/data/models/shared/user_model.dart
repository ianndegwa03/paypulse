import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/enums.dart';

/// User model for storing user data
class UserModel extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserRole role;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> securitySettings;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? occupation;
  final String? nationality;
  final String privacyLevel;
  final bool stealthModeEnabled;
  final bool isProfessionalProfileVisible;
  final String? professionalBio;
  final bool isBanned;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.profileImageUrl,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.preferences = const {},
    this.securitySettings = const {},
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
    this.isBanned = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName:
          json['first_name'] as String? ?? json['firstName'] as String? ?? '',
      lastName:
          json['last_name'] as String? ?? json['lastName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] as String? ?? 'standard'),
        orElse: () => UserRole.standard,
      ),
      phoneNumber:
          json['phone_number'] as String? ?? json['phoneNumber'] as String?,
      profileImageUrl: json['profile_image_url'] as String? ??
          json['profileImageUrl'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ??
          json['emailVerified'] as bool? ??
          false,
      isPhoneVerified: json['is_phone_verified'] as bool? ??
          json['phoneVerified'] as bool? ??
          false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      preferences: (json['preferences'] as Map<String, dynamic>?) ?? {},
      securitySettings: (json['security_settings'] as Map<String, dynamic>?) ??
          (json['securitySettings'] as Map<String, dynamic>?) ??
          {},
      bio: json['bio'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      occupation: json['occupation'] as String?,
      nationality: json['nationality'] as String?,
      privacyLevel: json['privacy_level'] as String? ??
          json['privacyLevel'] as String? ??
          'Public',
      stealthModeEnabled: json['stealth_mode_enabled'] as bool? ??
          json['stealthModeEnabled'] as bool? ??
          false,
      isProfessionalProfileVisible:
          json['is_professional_profile_visible'] as bool? ??
              json['isProfessionalProfileVisible'] as bool? ??
              false,
      professionalBio: json['professional_bio'] as String? ??
          json['professionalBio'] as String?,
      isBanned:
          json['is_banned'] as bool? ?? json['isBanned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'role': role.name,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'preferences': preferences,
      'security_settings': securitySettings,
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
      'is_banned': isBanned,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? username,
    UserRole? role,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? securitySettings,
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
    bool? isBanned,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      securitySettings: securitySettings ?? this.securitySettings,
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
      isBanned: isBanned ?? this.isBanned,
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        username,
        role,
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
        isBanned,
      ];
}
