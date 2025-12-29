import 'package:paypulse/data/models/shared/user_model.dart';
import 'package:paypulse/data/models/response/auth_response.dart';
import 'package:paypulse/domain/entities/user_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/domain/value_objects/email.dart';
import 'package:paypulse/domain/value_objects/phone_number.dart';

/// Mapper for converting between user data types
class UserMapper {
  /// Convert AuthResponse to UserEntity
  UserEntity responseToEntity(AuthResponse response) {
    final email = Email.create(response.email ?? '');
    final phoneNumber =
        response.userId != null ? PhoneNumber.create(response.userId!) : null;

    return UserEntity(
      id: response.userId ?? '',
      email: email.fold(
        (_) => throw Exception('Invalid email in response'),
        (validEmail) => validEmail,
      ),
      firstName: response.firstName ?? '',
      lastName: response.lastName ?? '',
      username: response.username ?? response.email?.split('@').first ?? 'user',
      role: UserRole.standard, // Default for auth response
      phoneNumber: phoneNumber?.fold((_) => null, (valid) => valid),
      profileImageUrl: response.profileImageUrl,
      isEmailVerified: response.isEmailVerified ?? false,
      isPhoneVerified: response.isPhoneVerified ?? false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      preferences: const {},
      securitySettings: const {},
    );
  }

  /// Convert UserModel to UserEntity
  UserEntity modelToEntity(UserModel model) {
    final email = Email.create(model.email);
    final phoneNumber = model.phoneNumber != null
        ? PhoneNumber.create(model.phoneNumber!)
        : null;

    return UserEntity(
      id: model.id,
      email: email.fold(
        (_) => throw Exception('Invalid email in model'),
        (validEmail) => validEmail,
      ),
      firstName: model.firstName,
      lastName: model.lastName,
      username: model.username,
      role: model.role,
      phoneNumber: phoneNumber?.fold((_) => null, (valid) => valid),
      profileImageUrl: model.profileImageUrl,
      isEmailVerified: model.isEmailVerified,
      isPhoneVerified: model.isPhoneVerified,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      preferences: model.preferences,
      securitySettings: model.securitySettings,
      bio: model.bio,
      dateOfBirth: model.dateOfBirth,
      gender: model.gender,
      address: model.address,
      occupation: model.occupation,
      nationality: model.nationality,
      privacyLevel: model.privacyLevel,
      stealthModeEnabled: model.stealthModeEnabled,
      isProfessionalProfileVisible: model.isProfessionalProfileVisible,
      professionalBio: model.professionalBio,
    );
  }

  /// Convert UserEntity to UserModel
  UserModel entityToModel(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email.value,
      firstName: entity.firstName,
      lastName: entity.lastName,
      username: entity.username,
      role: entity.role,
      phoneNumber: entity.phoneNumber?.value,
      profileImageUrl: entity.profileImageUrl,
      isEmailVerified: entity.isEmailVerified,
      isPhoneVerified: entity.isPhoneVerified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      preferences: entity.preferences,
      securitySettings: entity.securitySettings,
      bio: entity.bio,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      address: entity.address,
      occupation: entity.occupation,
      nationality: entity.nationality,
      privacyLevel: entity.privacyLevel,
      stealthModeEnabled: entity.stealthModeEnabled,
      isProfessionalProfileVisible: entity.isProfessionalProfileVisible,
      professionalBio: entity.professionalBio,
    );
  }

  /// Convert AuthResponse to UserModel
  UserModel responseToModel(AuthResponse response) {
    return UserModel(
      id: response.userId ?? '',
      email: response.email ?? '',
      firstName: response.firstName ?? '',
      lastName: response.lastName ?? '',
      username: response.username ?? response.email?.split('@').first ?? 'user',
      role: UserRole.standard, // Default for auth response
      phoneNumber: null,
      profileImageUrl: response.profileImageUrl,
      isEmailVerified: response.isEmailVerified ?? false,
      isPhoneVerified: response.isPhoneVerified ?? false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      preferences: const {},
      securitySettings: const {},
    );
  }
}
