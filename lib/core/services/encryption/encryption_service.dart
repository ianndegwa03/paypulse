import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class EncryptionService {
  final FlutterSecureStorage _secureStorage;
  static const _keyAlias = 'paypulse_chat_key';

  EncryptionService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Get or create the master key for chat encryption
  Future<Key> _getMasterKey() async {
    final storedKey = await _secureStorage.read(key: _keyAlias);
    if (storedKey != null) {
      return Key.fromBase64(storedKey);
    }

    final newKey = Key.fromSecureRandom(32);
    await _secureStorage.write(key: _keyAlias, value: newKey.base64);
    return newKey;
  }

  /// Encrypt a message using AES-256-GCM
  Future<String> encryptMessage(String message) async {
    final key = await _getMasterKey();
    final iv = IV.fromSecureRandom(12); // GCM standard IV size
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm, padding: null));

    final encrypted = encrypter.encrypt(message, iv: iv);

    // Combine IV and Ciphertext for storage (IV:Ciphertext)
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypt a message
  Future<String> decryptMessage(String encryptedContent) async {
    try {
      final parts = encryptedContent.split(':');
      if (parts.length != 2) throw Exception('Invalid encrypted format');

      final iv = IV.fromBase64(parts[0]);
      final ciphertext = parts[1];

      final key = await _getMasterKey();
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm, padding: null));

      return encrypter.decrypt(Encrypted.fromBase64(ciphertext), iv: iv);
    } catch (e) {
      return '[Message Decryption Failed]';
    }
  }

  /// Generate a shared secret (Simulated for now, would use Diffie-Hellman in real E2EE)
  Future<String> generateSharedSecret(String partnerId) async {
    // In a real E2EE setup, this would be computed from public/private keys
    return base64Encode(utf8.encode('shared_secret_$partnerId'));
  }
}
