import 'package:get_it/get_it.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/core/network/connectivity/network_info.dart';
import 'package:paypulse/core/network/api/dio_client.dart';
import 'package:paypulse/core/services/local_storage/storage_service.dart';
import 'package:paypulse/core/services/local_storage/secure_storage.dart';
import 'package:paypulse/core/security/storage/secure_storage_service.dart';
import 'package:paypulse/core/security/encryption/key_manager.dart';
import 'package:paypulse/core/security/encryption/crypto_utils.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/app/di/config/di_config.dart';

/// Core module for registering core services
class CoreModule {
  Future<void> init() async {
    // Storage Service
    if (!getIt.isRegistered<StorageService>()) {
      final storageService = StorageServiceImpl();
      await storageService.init();
      getIt.registerSingleton<StorageService>(storageService);
    }

    // Secure Storage
    if (!getIt.isRegistered<SecureStorage>()) {
      final secureStorage = SecureStorageImpl();
      getIt.registerSingleton<SecureStorage>(secureStorage);
    }

    // Crypto Utils
    if (!getIt.isRegistered<CryptoUtils>()) {
      getIt.registerSingleton<CryptoUtils>(CryptoUtils());
    }

    // Secure Storage Service
    if (!getIt.isRegistered<SecureStorageService>()) {
      final secureStorageService = SecureStorageServiceImpl(
        secureStorage: getIt<SecureStorage>(),
        cryptoUtils: getIt<CryptoUtils>(),
      );
      await secureStorageService.init();
      getIt.registerSingleton<SecureStorageService>(secureStorageService);
    }

    // Key Manager
    if (!getIt.isRegistered<KeyManager>()) {
      final keyManager = KeyManager.instance;
      await keyManager.initialize();
      getIt.registerSingleton<KeyManager>(keyManager);
    }

    // Dio Client
    if (!getIt.isRegistered<DioClient>()) {
      getIt.registerSingleton<DioClient>(DioClient());
    }

    // Network Info
    if (!getIt.isRegistered<NetworkInfo>()) {
      getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl());
    }

    // Logger Service
    if (!getIt.isRegistered<LoggerService>()) {
      getIt.registerSingleton<LoggerService>(LoggerService.instance);
    }

    // DI Config
    if (!getIt.isRegistered<DIConfig>()) {
      final config = GetIt.instance.get<DIConfig>();
      getIt.registerSingleton<DIConfig>(config);
    }

    LoggerService.instance.d('CoreModule initialized', tag: 'DI');
  }
}
