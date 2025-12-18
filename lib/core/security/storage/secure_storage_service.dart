import 'dart:convert';

import 'package:paypulse/core/security/encryption/crypto_utils.dart';
import 'package:paypulse/core/services/local_storage/secure_storage.dart';
import 'package:paypulse/core/errors/exceptions.dart';

abstract class SecureStorageService {
  Future<void> init();
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
  Future<Map<String, String>> readAll();

  // Special methods for sensitive data
  Future<void> writeAuthToken(String token);
  Future<String?> readAuthToken();
  Future<void> deleteAuthToken();

  Future<void> writeRefreshToken(String token);
  Future<String?> readRefreshToken();
  Future<void> deleteRefreshToken();

  Future<void> writeBiometricKey(String key);
  Future<String?> readBiometricKey();
  Future<void> deleteBiometricKey();

  Future<void> writeEncryptionKey(String key);
  Future<String?> readEncryptionKey();

  Future<void> writeUserPin(String pin);
  Future<String?> readUserPin();
  Future<void> deleteUserPin();
}

class SecureStorageServiceImpl implements SecureStorageService {
  final SecureStorage _secureStorage;
  final CryptoUtils _cryptoUtils;

  SecureStorageServiceImpl({
    required SecureStorage secureStorage,
    required CryptoUtils cryptoUtils,
  })  : _secureStorage = secureStorage,
        _cryptoUtils = cryptoUtils;

  @override
  Future<void> init() async {
    // Check if encryption key exists, if not generate one
    final existingKey = await readEncryptionKey();
    if (existingKey == null) {
      final newKey = CryptoUtils.generateRandomKey();
      await writeEncryptionKey(newKey);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      // Encrypt the value before storing
      final encryptedValue = _cryptoUtils.encrypt(value);
      await _secureStorage.write(key, encryptedValue);
    } catch (e) {
      throw SecurityException(
        message: 'Failed to write secure data: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      final encryptedValue = await _secureStorage.read(key);
      if (encryptedValue == null) return null;

      // Decrypt the value
      return _cryptoUtils.decrypt(encryptedValue);
    } catch (e) {
      throw SecurityException(
        message: 'Failed to read secure data: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _secureStorage.delete(key);
    } catch (e) {
      throw SecurityException(
        message: 'Failed to delete secure data: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw SecurityException(
        message: 'Failed to delete all secure data: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _secureStorage.containsKey(key);
    } catch (e) {
      throw SecurityException(
        message: 'Failed to check key existence: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      final allData = await _secureStorage.readAll();
      final decryptedData = <String, String>{};

      for (final entry in allData.entries) {
        try {
          decryptedData[entry.key] = _cryptoUtils.decrypt(entry.value);
        } catch (e) {
          // Skip entries that can't be decrypted
          continue;
        }
      }

      return decryptedData;
    } catch (e) {
      throw SecurityException(
        message: 'Failed to read all secure data: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> writeAuthToken(String token) async {
    await write('auth_token', token);
  }

  @override
  Future<String?> readAuthToken() async {
    return await read('auth_token');
  }

  @override
  Future<void> deleteAuthToken() async {
    await delete('auth_token');
  }

  @override
  Future<void> writeRefreshToken(String token) async {
    await write('refresh_token', token);
  }

  @override
  Future<String?> readRefreshToken() async {
    return await read('refresh_token');
  }

  @override
  Future<void> deleteRefreshToken() async {
    await delete('refresh_token');
  }

  @override
  Future<void> writeBiometricKey(String key) async {
    await write('biometric_key', key);
  }

  @override
  Future<String?> readBiometricKey() async {
    return await read('biometric_key');
  }

  @override
  Future<void> deleteBiometricKey() async {
    await delete('biometric_key');
  }

  @override
  Future<void> writeEncryptionKey(String key) async {
    // Store encryption key without encryption (it's used to encrypt other data)
    await _secureStorage.write('encryption_key', key);
  }

  @override
  Future<String?> readEncryptionKey() async {
    return await _secureStorage.read('encryption_key');
  }

  @override
  Future<void> writeUserPin(String pin) async {
    // Hash the PIN before storing (never store plain PIN)
    final hashedPin = CryptoUtils.hashData(pin);
    await write('user_pin_hash', hashedPin);
  }

  @override
  Future<String?> readUserPin() async {
    // Return the hashed PIN
    return await read('user_pin_hash');
  }

  @override
  Future<void> deleteUserPin() async {
    await delete('user_pin_hash');
  }

  // Additional security methods

  Future<bool> verifyUserPin(String pin) async {
    try {
      final storedHash = await readUserPin();
      if (storedHash == null) return false;

      final inputHash = CryptoUtils.hashData(pin);
      return storedHash == inputHash;
    } catch (e) {
      throw SecurityException(
        message: 'Failed to verify PIN: $e',
        data: {'error': e.toString()},
      );
    }
  }

  Future<void> writeSensitiveData(String key, Map<String, dynamic> data) async {
    try {
      final encryptedData = _cryptoUtils.encryptMap(data);
      await write(key, json.encode(encryptedData));
    } catch (e) {
      throw SecurityException(
        message: 'Failed to write sensitive data: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  Future<Map<String, dynamic>> readSensitiveData(String key) async {
    try {
      final encryptedJson = await read(key);
      if (encryptedJson == null) {
        throw SecurityException(message: 'No data found for key: $key');
      }

      final encryptedMap = json.decode(encryptedJson) as Map<String, dynamic>;
      return _cryptoUtils.decryptMap(encryptedMap);
    } catch (e) {
      throw SecurityException(
        message: 'Failed to read sensitive data: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  // Session management
  Future<void> startSession(String userId) async {
    try {
      final sessionData = {
        'user_id': userId,
        'started_at': DateTime.now().toIso8601String(),
        'session_id': _generateSessionId(),
      };

      await write('current_session', json.encode(sessionData));
    } catch (e) {
      throw SecurityException(
        message: 'Failed to start session: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }

  Future<Map<String, dynamic>?> getCurrentSession() async {
    try {
      final sessionJson = await read('current_session');
      if (sessionJson == null) return null;

      return json.decode(sessionJson) as Map<String, dynamic>;
    } catch (e) {
      throw SecurityException(
        message: 'Failed to get current session: $e',
        data: {'error': e.toString()},
      );
    }
  }

  Future<void> endSession() async {
    try {
      await delete('current_session');
      await deleteAuthToken();
      await deleteRefreshToken();
    } catch (e) {
      throw SecurityException(
        message: 'Failed to end session: $e',
        data: {'error': e.toString()},
      );
    }
  }

  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return '${timestamp}_$random';
  }
}
