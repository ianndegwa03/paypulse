// lib/core/security/encryption/key_manager.dart
class KeyManager {
  static Future<EncryptionKey> generateUserKey(String userId) async {
    // Derive key from user biometrics + device ID
    final biometricData = await BiometricService.getBiometricHash();
    final deviceId = await DeviceInfo.getUniqueId();
    
    return EncryptionKey.deriveFrom(
      masterKey: await _getMasterKey(),
      salt: '$biometricData$deviceId$userId',
    );
  }
  
  static Future<String> encryptSensitiveData(String data, String userId) async {
    final userKey = await generateUserKey(userId);
    return AesEncryption.encrypt(data, userKey);
  }
}