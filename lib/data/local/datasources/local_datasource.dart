import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/core/services/local_storage/storage_service.dart';
import 'package:paypulse/data/models/shared/user_model.dart';

abstract class LocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCachedUser();

  Future<void> setAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuthToken();

  Future<void> setRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearRefreshToken();

  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();

  Future<void> setOnboardingComplete(bool complete);
  Future<bool> isOnboardingComplete();

  Future<void> clearAllData();
}

class LocalDataSourceImpl implements LocalDataSource {
  final StorageService _storageService;

  LocalDataSourceImpl(this._storageService);

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _storageService.saveObject('user', user.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final data = await _storageService.getObject('user');
      if (data == null) return null;

      return UserModel.fromJson(data);
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user: $e');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await _storageService.delete('user');
    } catch (e) {
      throw CacheException(message: 'Failed to clear cached user: $e');
    }
  }

  @override
  Future<void> setAuthToken(String token) async {
    try {
      await _storageService.saveString('auth_token', token);
    } catch (e) {
      throw CacheException(message: 'Failed to save auth token: $e');
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      return await _storageService.getString('auth_token');
    } catch (e) {
      throw CacheException(message: 'Failed to get auth token: $e');
    }
  }

  @override
  Future<void> clearAuthToken() async {
    try {
      await _storageService.delete('auth_token');
    } catch (e) {
      throw CacheException(message: 'Failed to clear auth token: $e');
    }
  }

  @override
  Future<void> setRefreshToken(String token) async {
    try {
      await _storageService.saveString('refresh_token', token);
    } catch (e) {
      throw CacheException(message: 'Failed to save refresh token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storageService.getString('refresh_token');
    } catch (e) {
      throw CacheException(message: 'Failed to get refresh token: $e');
    }
  }

  @override
  Future<void> clearRefreshToken() async {
    try {
      await _storageService.delete('refresh_token');
    } catch (e) {
      throw CacheException(message: 'Failed to clear refresh token: $e');
    }
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storageService.saveBool('biometric_enabled', enabled);
    } catch (e) {
      throw CacheException(message: 'Failed to save biometric setting: $e');
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    try {
      return await _storageService.getBool('biometric_enabled') ?? false;
    } catch (e) {
      throw CacheException(message: 'Failed to get biometric setting: $e');
    }
  }

  @override
  Future<void> setOnboardingComplete(bool complete) async {
    try {
      await _storageService.saveBool('onboarding_complete', complete);
    } catch (e) {
      throw CacheException(message: 'Failed to save onboarding status: $e');
    }
  }

  @override
  Future<bool> isOnboardingComplete() async {
    try {
      return await _storageService.getBool('onboarding_complete') ?? false;
    } catch (e) {
      throw CacheException(message: 'Failed to get onboarding status: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await _storageService.clearAll();
    } catch (e) {
      throw CacheException(message: 'Failed to clear all data: $e');
    }
  }
}
