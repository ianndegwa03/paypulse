import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/core/services/local_storage/secure_storage.dart';

class KeyManager {
  static final KeyManager _instance = KeyManager._internal();
  
  factory KeyManager() => _instance;
  
  KeyManager._internal();
  
  static KeyManager get instance => _instance;
  
  late SecureStorage _secureStorage;
  
  Future<void> initialize({SecureStorage? secureStorage}) async {
    _secureStorage = secureStorage ?? SecureStorageImpl();
    
    // Initialize encryption keys if they don't exist
    await _initializeEncryptionKeys();
  }
  
  Future<void> _initializeEncryptionKeys() async {
    try {
      // Check if master key exists
      final masterKeyExists = await _secureStorage.containsKey('master_key');
      
      if (!masterKeyExists) {
        // Generate new master key
        final masterKey = _generateRandomKey(32); // 256-bit key
        await _secureStorage.write('master_key', masterKey);
      }
      
      // Check if IV exists
      final ivExists = await _secureStorage.containsKey('encryption_iv');
      
      if (!ivExists) {
        // Generate new IV
        final iv = _generateRandomKey(16); // 128-bit IV
        await _secureStorage.write('encryption_iv', iv);
      }
    } catch (e) {
      throw SecurityException(
        message: 'Failed to initialize encryption keys: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Future<String> getMasterKey() async {
    try {
      final key = await _secureStorage.read('master_key');
      if (key == null) {
        throw SecurityException(message: 'Master key not found');
      }
      return key;
    } catch (e) {
      throw SecurityException(
        message: 'Failed to get master key: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Future<String> getEncryptionIV() async {
    try {
      final iv = await _secureStorage.read('encryption_iv');
      if (iv == null) {
        throw SecurityException(message: 'Encryption IV not found');
      }
      return iv;
    } catch (e) {
      throw SecurityException(
        message: 'Failed to get encryption IV: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Future<void> rotateMasterKey() async {
    try {
      // Generate new master key
      final newMasterKey = _generateRandomKey(32);
      
      // Re-encrypt all data with new key (implementation depends on data structure)
      // This is a simplified version - in production, you'd need to re-encrypt all stored data
      
      // Store new master key
      await _secureStorage.write('master_key', newMasterKey);
      
      // Generate new IV as well
      final newIV = _generateRandomKey(16);
      await _secureStorage.write('encryption_iv', newIV);
      
      // Log key rotation
      _logSecurityEvent('Master key rotated');
    } catch (e) {
      throw SecurityException(
        message: 'Failed to rotate master key: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Future<String> generateDataKey(String context) async {
    try {
      // Generate context-specific data key
      final masterKey = await getMasterKey();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Create a unique key for this data context
      final dataKey = _hashString('$masterKey:$context:$timestamp');
      
      return dataKey;
    } catch (e) {
      throw SecurityException(
        message: 'Failed to generate data key: $e',
        data: {'context': context, 'error': e.toString()},
      );
    }
  }
  
  Future<void> storeDerivedKey(String keyId, String key) async {
    try {
      await _secureStorage.write('derived_key_$keyId', key);
    } catch (e) {
      throw SecurityException(
        message: 'Failed to store derived key: $e',
        data: {'keyId': keyId, 'error': e.toString()},
      );
    }
  }
  
  Future<String?> getDerivedKey(String keyId) async {
    try {
      return await _secureStorage.read('derived_key_$keyId');
    } catch (e) {
      throw SecurityException(
        message: 'Failed to get derived key: $e',
        data: {'keyId': keyId, 'error': e.toString()},
      );
    }
  }
  
  Future<void> deleteDerivedKey(String keyId) async {
    try {
      await _secureStorage.delete('derived_key_$keyId');
    } catch (e) {
      throw SecurityException(
        message: 'Failed to delete derived key: $e',
        data: {'keyId': keyId, 'error': e.toString()},
      );
    }
  }
  
  // Key derivation function
  Future<String> deriveKey(String baseKey, String salt, {int iterations = 10000}) async {
    try {
      // Simple key derivation (in production, use proper KDF like PBKDF2)
      String derivedKey = baseKey + salt;
      
      for (int i = 0; i < iterations; i++) {
        derivedKey = _hashString(derivedKey);
      }
      
      return derivedKey.substring(0, 32); // Return 256-bit key
    } catch (e) {
      throw SecurityException(
        message: 'Failed to derive key: $e',
        data: {'salt': salt, 'iterations': iterations, 'error': e.toString()},
      );
    }
  }
  
  // Key validation
  Future<bool> validateKey(String key, int expectedLength) async {
    if (key.length != expectedLength) {
      return false;
    }
    
    // Additional validation logic can be added here
    return true;
  }
  
  String _generateRandomKey(int length) {
    final random = List<int>.generate(length, (i) => i);
    final randomBytes = random.map((e) => e % 256).toList();
    return String.fromCharCodes(randomBytes);
  }
  
  String _hashString(String input) {
    // Simple hash for demonstration
    // In production, use proper cryptographic hash
    final bytes = input.codeUnits;
    final hash = bytes.fold<int>(0, (prev, element) => prev + element);
    return hash.toString().padLeft(32, '0');
  }
  
  void _logSecurityEvent(String event) {
    // Log security events (implement with your logging system)
    print('Security Event: $event');
  }
  
  // Cleanup
  Future<void> cleanup() async {
    try {
      // Delete all derived keys
      // Note: In production, you'd need to list all keys first
      
      // Keep master key and IV for future use
    } catch (e) {
      throw SecurityException(
        message: 'Failed to cleanup key manager: $e',
        data: {'error': e.toString()},
      );
    }
  }
}