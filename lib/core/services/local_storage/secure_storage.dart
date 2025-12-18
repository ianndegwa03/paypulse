import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:paypulse/core/errors/exceptions.dart';

abstract class SecureStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
  Future<Map<String, String>> readAll();
}

class SecureStorageImpl implements SecureStorage {
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.unlocked,
  );
  
  static const LinuxOptions _linuxOptions = LinuxOptions();
  
  static const WindowsOptions _windowsOptions = WindowsOptions();
  
  late final FlutterSecureStorage _storage;

  SecureStorageImpl() {
    _storage = const FlutterSecureStorage(
      aOptions: _androidOptions,
      iOptions: _iosOptions,
      lOptions: _linuxOptions,
      wOptions: _windowsOptions,
    );
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to write secure data: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to read secure data: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete secure data: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete all secure data: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to check key existence: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to read all secure data: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  // Special methods for sensitive data
  
  Future<void> writeAuthToken(String token) async {
    await write('auth_token', token);
  }
  
  Future<String?> readAuthToken() async {
    return await read('auth_token');
  }
  
  Future<void> deleteAuthToken() async {
    await delete('auth_token');
  }
  
  Future<void> writeRefreshToken(String token) async {
    await write('refresh_token', token);
  }
  
  Future<String?> readRefreshToken() async {
    return await read('refresh_token');
  }
  
  Future<void> deleteRefreshToken() async {
    await delete('refresh_token');
  }
  
  Future<void> writeBiometricKey(String key) async {
    await write('biometric_key', key);
  }
  
  Future<String?> readBiometricKey() async {
    return await read('biometric_key');
  }
  
  Future<void> deleteBiometricKey() async {
    await delete('biometric_key');
  }
  
  Future<void> writeEncryptionKey(String key) async {
    await write('encryption_key', key);
  }
  
  Future<String?> readEncryptionKey() async {
    return await read('encryption_key');
  }
  
  Future<void> writeUserPin(String pin) async {
    await write('user_pin', pin);
  }
  
  Future<String?> readUserPin() async {
    return await read('user_pin');
  }
  
  Future<void> deleteUserPin() async {
    await delete('user_pin');
  }
}