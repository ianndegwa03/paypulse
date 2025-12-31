import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paypulse/core/errors/failures.dart';
import 'package:paypulse/data/remote/datasources/wallet_datasource.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart' as domain;
import 'package:paypulse/domain/entities/wallet_entity.dart';
import 'package:paypulse/domain/entities/card_entity.dart';
import 'package:paypulse/data/models/wallet_model.dart';

import 'package:paypulse/data/models/vault_model.dart';
import 'package:paypulse/data/models/virtual_card_model.dart';
import 'package:paypulse/domain/entities/vault_entity.dart';
import 'package:paypulse/domain/entities/virtual_card_entity.dart';
import 'package:paypulse/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletDataSource _dataSource;
  final FirebaseAuth _firebaseAuth;

  WalletRepositoryImpl({
    required WalletDataSource dataSource,
    FirebaseAuth? firebaseAuth,
  })  : _dataSource = dataSource,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String get _userId => _firebaseAuth.currentUser?.uid ?? '';

  @override
  Stream<Wallet> getWalletStream() {
    if (_userId.isEmpty) return const Stream.empty();
    return _dataSource.getWalletStream(_userId);
  }

  @override
  Stream<List<domain.Transaction>> getTransactionsStream() {
    if (_userId.isEmpty) return const Stream.empty();
    return _dataSource.getTransactionsStream(_userId);
  }

  @override
  Future<Either<Failure, Wallet>> getWallet() async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final wallet = await _dataSource.getWallet(_userId);
      return Right(wallet);
    } catch (e) {
      if (e.toString().contains('Wallet not found')) {
        return const Left(CacheFailure(message: 'Wallet not found'));
      }
      return Left(ServerFailure(message: 'Failed to get wallet: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addMoney(String amount, String currency) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      await _dataSource.addMoney(_userId, amount, currency);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add money: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> transferMoney({
    required String recipientId,
    required String amount,
    required String currency,
    double fee = 0.0,
  }) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      await _dataSource.transferMoney(
        userId: _userId,
        recipientId: recipientId,
        amount: amount,
        currency: currency,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to transfer money: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Transaction>>> getTransactions(
      {int limit = 10, int offset = 0}) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final transactions = await _dataSource.getTransactions(
        _userId,
        limit: limit,
        offset: offset,
      );
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWalletAnalytics() async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final analytics = await _dataSource.getWalletAnalytics(_userId);
      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateWallet(Wallet wallet) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final model =
          wallet is WalletModel ? wallet : WalletModel.fromEntity(wallet);
      await _dataSource.updateWallet(_userId, model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update wallet: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> linkCard(CardEntity card) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final walletResult = await getWallet();
      return await walletResult.fold(
        (failure) async {
          // If wallet doesn't exist, create a new one with this card
          final newWallet = Wallet(
            id: _userId,
            balances: const {'USD': 0.0},
            primaryCurrency: 'USD',
            linkedCards: [card],
          );
          return await updateWallet(newWallet);
        },
        (wallet) async {
          final updatedCards = List<CardEntity>.from(wallet.linkedCards)
            ..add(card);
          final updatedWallet = wallet.copyWith(linkedCards: updatedCards);
          return await updateWallet(updatedWallet);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to link card: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createVault(VaultEntity vault) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }
      await _dataSource.createVault(
          _userId, VaultModel.fromEntity(vault).toMap());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> fundVault(String vaultId, double amount) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }
      await _dataSource.fundVault(_userId, vaultId, amount);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createVirtualCard(
      VirtualCardEntity card) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }
      await _dataSource.createVirtualCard(
          _userId, VirtualCardModel.fromEntity(card).toMap());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    required double rate,
  }) async {
    try {
      if (_userId.isEmpty) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final walletResult = await getWallet();
      return await walletResult.fold(
        (failure) => Left(failure),
        (wallet) async {
          final balances = Map<String, double>.from(wallet.balances);
          final costBasis = Map<String, double>.from(wallet.costBasis);

          final fromBalance = balances[fromCurrency] ?? 0.0;
          if (fromBalance < amount) {
            return const Left(ServerFailure(message: 'Insufficient balance'));
          }

          // Update balances
          balances[fromCurrency] = fromBalance - amount;
          final addedAmount = amount * rate;
          balances[toCurrency] = (balances[toCurrency] ?? 0.0) + addedAmount;

          // Update cost basis for toCurrency
          // New Basis = Total Units / Total USD Cost
          if (toCurrency != 'USD') {
            final oldUnits = balances[toCurrency]! - addedAmount;
            final oldBasis = costBasis[toCurrency] ?? rate;

            // USD value of previous units
            final oldUSDCost = oldBasis > 0 ? oldUnits / oldBasis : 0.0;

            // USD value of added units
            // We need the rate of fromCurrency to USD to find the cost
            // For now, let's assume we use the current market rate if fromCurrency != USD
            // But if fromCurrency is USD, the cost is just 'amount'
            double addedUSDCost = 0.0;
            if (fromCurrency == 'USD') {
              addedUSDCost = amount;
            } else {
              // Fallback: use current rate of fromCurrency to USD
              // In a real app, we'd pass the USD cost or the current rate to USD
              final fromBasis = costBasis[fromCurrency] ?? 1.0;
              addedUSDCost = fromBasis > 0 ? amount / fromBasis : amount;
            }

            final newTotalUSDCost = oldUSDCost + addedUSDCost;
            if (newTotalUSDCost > 0) {
              costBasis[toCurrency] = balances[toCurrency]! / newTotalUSDCost;
            }
          }

          final updatedWallet = wallet.copyWith(
            balances: balances,
            costBasis: costBasis,
          );

          return await updateWallet(updatedWallet);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Conversion failed: $e'));
    }
  }
}
