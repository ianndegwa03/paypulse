import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/core/security/storage/secure_storage_service.dart';

abstract class BiometricService {
  Future<bool> isBiometricAvailable();
  Future<bool> authenticate({required String reason});
  Future<void> saveBiometricCredentials(String identifier, String credentials);
  Future<String?> getBiometricCredentials(String identifier);
  Future<void> deleteBiometricCredentials(String identifier);
  Future<bool> hasBiometricCredentials(String identifier);
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<void> disableBiometric();
  Future<bool> authenticateForLogin();
}

class BiometricServiceImpl implements BiometricService {
  final LocalAuthentication _localAuth;
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger();

  BiometricServiceImpl({
    LocalAuthentication? localAuth,
    required SecureStorageService secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage;

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      throw BiometricException(
        message: 'Failed to check biometric availability: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw BiometricException(
          message: 'Biometric authentication not available',
          data: {'available': false},
        );
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      return didAuthenticate;
    } catch (e) {
      throw BiometricException(
        message: 'Biometric authentication failed: $e',
        data: {'reason': reason, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> saveBiometricCredentials(
      String identifier, String credentials) async {
    try {
      // Store credentials in secure storage
      await _secureStorage.writeBiometricKey(identifier);

      // Also store the actual credentials encrypted
      await _secureStorage.write('biometric_creds_$identifier', credentials);

      // Mark biometric as enabled for this identifier
      await _secureStorage.write('biometric_enabled_$identifier', 'true');
    } catch (e) {
      throw BiometricException(
        message: 'Failed to save biometric credentials: $e',
        data: {'identifier': identifier, 'error': e.toString()},
      );
    }
  }

  @override
  Future<String?> getBiometricCredentials(String identifier) async {
    try {
      // First check if biometric is enabled for this identifier
      final isEnabled =
          await _secureStorage.read('biometric_enabled_$identifier');
      if (isEnabled != 'true') {
        return null;
      }

      // Get the stored credentials
      return await _secureStorage.read('biometric_creds_$identifier');
    } catch (e) {
      throw BiometricException(
        message: 'Failed to get biometric credentials: $e',
        data: {'identifier': identifier, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> deleteBiometricCredentials(String identifier) async {
    try {
      await _secureStorage.delete('biometric_creds_$identifier');
      await _secureStorage.delete('biometric_enabled_$identifier');
      await _secureStorage.deleteBiometricKey();
    } catch (e) {
      throw BiometricException(
        message: 'Failed to delete biometric credentials: $e',
        data: {'identifier': identifier, 'error': e.toString()},
      );
    }
  }

  @override
  Future<bool> hasBiometricCredentials(String identifier) async {
    try {
      final isEnabled =
          await _secureStorage.read('biometric_enabled_$identifier');
      return isEnabled == 'true';
    } catch (e) {
      throw BiometricException(
        message: 'Failed to check biometric credentials: $e',
        data: {'identifier': identifier, 'error': e.toString()},
      );
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      throw BiometricException(
        message: 'Failed to get available biometrics: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> disableBiometric() async {
    try {
      // Clear all biometric-related data
      await _secureStorage.deleteBiometricKey();

      // You might want to clear all biometric credentials
      // This is a simplified version
    } catch (e) {
      throw BiometricException(
        message: 'Failed to disable biometric: $e',
        data: {'error': e.toString()},
      );
    }
  }

  // Additional biometric methods for PayPulse

  Future<bool> authenticateForTransaction(
      {required double amount, required String recipient}) async {
    final reason = 'Confirm transaction of \$$amount to $recipient';
    return await authenticate(reason: reason);
  }

  Future<bool> authenticateForLogin() async {
    return await authenticate(reason: 'Login to your PayPulse account');
  }

  Future<bool> authenticateForSettings() async {
    return await authenticate(reason: 'Access security settings');
  }

  Future<bool> authenticateForPayment() async {
    return await authenticate(reason: 'Authorize payment');
  }

  Future<Map<String, dynamic>> getBiometricStatus() async {
    try {
      final isAvailable = await isBiometricAvailable();
      final availableTypes = await getAvailableBiometrics();
      final hasStoredCredentials = await hasBiometricCredentials('default');

      return {
        'available': isAvailable,
        'available_types': availableTypes.map((type) => type.name).toList(),
        'has_stored_credentials': hasStoredCredentials,
        'supported': availableTypes.isNotEmpty,
      };
    } catch (e) {
      throw BiometricException(
        message: 'Failed to get biometric status: $e',
        data: {'error': e.toString()},
      );
    }
  }

  Future<void> setupBiometric(
      {required String userId, required String authToken}) async {
    try {
      // First authenticate to ensure it's the real user
      final authenticated =
          await authenticate(reason: 'Setup biometric authentication');

      if (!authenticated) {
        throw BiometricException(
          message: 'Biometric setup cancelled or failed',
          data: {'userId': userId},
        );
      }

      // Store the user's authentication token with biometric protection
      await saveBiometricCredentials(userId, authToken);

      // Log the setup
      _logger.d('Biometric authentication setup completed for user: $userId');
    } catch (e) {
      throw BiometricException(
        message: 'Failed to setup biometric: $e',
        data: {'userId': userId, 'error': e.toString()},
      );
    }
  }
}

class BiometricException extends AppException {
  BiometricException({
    required super.message,
    super.statusCode,
    super.data,
  });
}
