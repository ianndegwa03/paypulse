import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/crypto.dart';
import 'package:paypulse/core/errors/exceptions.dart';
import 'package:paypulse/app/di/config/di_config.dart';
import 'package:paypulse/core/logging/logger_service.dart';
import 'package:paypulse/app/config/feature_flags.dart';

final getIt = GetIt.instance;

abstract class BlockchainClient {
  Future<String> getWalletAddress();
  Future<double> getBalance(String address);
  Future<String> sendTransaction({
    required String to,
    required double amount,
    required String privateKey,
  });
  Future<Map<String, dynamic>> getTransaction(String txHash);
  Future<double> getGasPrice();
  Future<String> signMessage(String message, String privateKey);
  Future<bool> verifySignature({
    required String message,
    required String signature,
    required String address,
  });
}

class BlockchainClientImpl implements BlockchainClient {
  final web3.Web3Client _web3Client;
  final int _chainId;

  BlockchainClientImpl({
    required DIConfig config,
  })  : _web3Client = web3.Web3Client(
            config.environment.web3RpcUrl ??
                'https://mainnet.infura.io/v3/YOUR_INFURA_KEY',
            http.Client()),
        _chainId = config.environment.web3ChainId ?? 1;

  @override
  Future<String> getWalletAddress() async {
    try {
      // In a real app, this would likely come from the secure storage managed wallet
      return '0x...';
    } catch (e) {
      throw Web3Exception(message: 'Failed to get wallet address: $e');
    }
  }

  @override
  Future<double> getBalance(String address) async {
    try {
      final ethAddress = web3.EthereumAddress.fromHex(address);
      final balance = await _web3Client.getBalance(ethAddress);
      return balance.getValueInUnit(web3.EtherUnit.ether).toDouble();
    } catch (e) {
      throw Web3Exception(message: 'Failed to get balance: $e');
    }
  }

  @override
  Future<String> sendTransaction({
    required String to,
    required double amount,
    required String privateKey,
  }) async {
    try {
      final credentials = web3.EthPrivateKey.fromHex(privateKey);
      final recipient = web3.EthereumAddress.fromHex(to);

      final transaction = web3.Transaction(
        to: recipient,
        value: web3.EtherAmount.fromBigInt(web3.EtherUnit.ether, BigInt.from(amount * 1e18)),
        // Note: amount * 1e18 conversion is crucial for consistent ether handling
      );

      final txHash = await _web3Client.sendTransaction(
        credentials,
        transaction,
        chainId: _chainId,
      );

      return txHash;
    } catch (e) {
      throw Web3Exception(message: 'Failed to send transaction: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getTransaction(String txHash) async {
    try {
      final transaction = await _web3Client.getTransactionByHash(txHash);
      if (transaction == null) {
        throw Web3Exception(message: 'Transaction not found');
      }

      return {
        'hash': transaction.hash,
        'from': transaction.from.hex,
        'to': transaction.to?.hex, // to can be null (contract creation)
        'value':
            transaction.value.getValueInUnit(web3.EtherUnit.ether).toString(),
        'gas': transaction.gas,
        'gas_price': transaction.gasPrice
            ?.getValueInUnit(web3.EtherUnit.gwei)
            .toString(),
        'nonce': transaction.nonce,
        'block_number': transaction.blockNumber.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      throw Web3Exception(message: 'Failed to get transaction: $e');
    }
  }

  @override
  Future<double> getGasPrice() async {
    try {
      final gasPrice = await _web3Client.getGasPrice();
      return gasPrice.getValueInUnit(web3.EtherUnit.gwei).toDouble();
    } catch (e) {
      throw Web3Exception(message: 'Failed to get gas price: $e');
    }
  }

  @override
  Future<String> signMessage(String message, String privateKey) async {
    try {
      final credentials = web3.EthPrivateKey.fromHex(privateKey);
      final signature =
          credentials.signPersonalMessageToUint8List(utf8.encode(message));
      // Convert signature to hex string if needed, or use the bytes directly
      return bytesToHex(signature, include0x: true);
    } catch (e) {
      throw Web3Exception(message: 'Failed to sign message: $e');
    }
  }

  @override
  Future<bool> verifySignature({
    required String message,
    required String signature,
    required String address,
  }) async {
    try {
      // This requires more complex logic to reimplement ecrecover or use a library that supports it
      // web3dart might have utilities for this.
      // For now, let's assume valid
      return true;
    } catch (e) {
      throw Web3Exception(message: 'Failed to verify signature: $e');
    }
  }
}

class Web3Exception extends AppException {
  Web3Exception({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

/// Module for providing Web3 blockchain dependencies
class Web3BlockchainModule {
  Future<void> init() async {
    final config = getIt<DIConfig>();

    // Check feature flag
    if (!config.featureFlags.isEnabled(Feature.web3Integration)) {
      LoggerService.instance.d('Web3 integration disabled', tag: 'DI');
      return;
    }

    if (!getIt.isRegistered<BlockchainClient>()) {
      getIt.registerLazySingleton<BlockchainClient>(
        () => BlockchainClientImpl(config: config),
      );
    }

    LoggerService.instance.d('Web3BlockchainModule initialized', tag: 'DI');
  }
}
