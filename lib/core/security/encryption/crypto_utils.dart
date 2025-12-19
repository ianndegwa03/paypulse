import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:paypulse/core/errors/exceptions.dart';

class CryptoUtils {

  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits
  
  final Key _key;
  final IV _iv;
  
  CryptoUtils({String? secretKey, String? iv})
      : _key = Key.fromUtf8(_generateKey(secretKey)),
        _iv = IV.fromUtf8(_generateIV(iv));
  
  static String _generateKey(String? secretKey) {
    if (secretKey != null && secretKey.length >= _keyLength) {
      return secretKey.substring(0, _keyLength);
    }
    
    // Fallback to default key (in production, this should come from secure storage)
    const defaultKey = 'PayPulseDefaultEncryptionKey256Bit!';
    return defaultKey.padRight(_keyLength, '0').substring(0, _keyLength);
  }
  
  static String _generateIV(String? iv) {
    if (iv != null && iv.length >= _ivLength) {
      return iv.substring(0, _ivLength);
    }
    
    // Fallback to default IV
    const defaultIV = 'PayPulseDefaultIV16';
    return defaultIV.padRight(_ivLength, '0').substring(0, _ivLength);
  }
  
  String encrypt(String plainText) {
    try {
      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: _iv);
      
      // Return base64 encoded string
      return encrypted.base64;
    } catch (e) {
      throw SecurityException(
        message: 'Failed to encrypt data: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  String decrypt(String encryptedText) {
    try {
      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
      final encrypted = Encrypted.fromBase64(encryptedText);
      final decrypted = encrypter.decrypt(encrypted, iv: _iv);
      
      return decrypted;
    } catch (e) {
      throw SecurityException(
        message: 'Failed to decrypt data: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Map<String, dynamic> encryptMap(Map<String, dynamic> map) {
    try {
      final jsonString = json.encode(map);
      return {'encrypted': encrypt(jsonString)};
    } catch (e) {
      throw SecurityException(
        message: 'Failed to encrypt map: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  Map<String, dynamic> decryptMap(Map<String, dynamic> encryptedMap) {
    try {
      final encryptedText = encryptedMap['encrypted'] as String;
      final jsonString = decrypt(encryptedText);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw SecurityException(
        message: 'Failed to decrypt map: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  String encryptList(List<dynamic> list) {
    try {
      final jsonString = json.encode(list);
      return encrypt(jsonString);
    } catch (e) {
      throw SecurityException(
        message: 'Failed to encrypt list: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  List<dynamic> decryptList(String encryptedText) {
    try {
      final jsonString = decrypt(encryptedText);
      return json.decode(jsonString) as List<dynamic>;
    } catch (e) {
      throw SecurityException(
        message: 'Failed to decrypt list: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  // Utility methods for specific data types
  
  String encryptSensitiveField(String fieldName, String value) {
    try {
      final data = {'field': fieldName, 'value': value, 'timestamp': DateTime.now().toIso8601String()};
      return encrypt(json.encode(data));
    } catch (e) {
      throw SecurityException(
        message: 'Failed to encrypt sensitive field: $e',
        data: {'field': fieldName, 'error': e.toString()},
      );
    }
  }
  
  String decryptSensitiveField(String encryptedText) {
    try {
      final jsonString = decrypt(encryptedText);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      return data['value'] as String;
    } catch (e) {
      throw SecurityException(
        message: 'Failed to decrypt sensitive field: $e',
        data: {'error': e.toString()},
      );
    }
  }
  
  // Generate random key (for first-time setup)
  static String generateRandomKey() {
    final random = List<int>.generate(_keyLength, (i) => i);
    final keyBytes = Uint8List.fromList(random);
    return base64.encode(keyBytes);
  }
  
  // Generate random IV
  static String generateRandomIV() {
    final random = List<int>.generate(_ivLength, (i) => i);
    final ivBytes = Uint8List.fromList(random);
    return base64.encode(ivBytes);
  }
  
  // Hash data (for non-reversible operations)
  static String hashData(String data) {
    try {
      // Using simple hash for demonstration
      // In production, use proper cryptographic hash like SHA-256
      final bytes = utf8.encode(data);
      final digest = bytes.fold<int>(0, (prev, element) => prev + element);
      return digest.toString();
    } catch (e) {
      throw SecurityException(
        message: 'Failed to hash data: $e',
        data: {'error': e.toString()},
      );
    }
  }
}