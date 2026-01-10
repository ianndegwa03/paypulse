import 'package:hive_flutter/hive_flutter.dart';
import 'package:paypulse/data/models/transaction_model.dart';
import 'dart:convert';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getLastTransactions();
  Future<void> cacheTransactions(List<TransactionModel> transactions);
}

class HiveTransactionDataSourceImpl implements TransactionLocalDataSource {
  static const String boxName = 'transactions_cache';

  Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  @override
  Future<List<TransactionModel>> getLastTransactions() async {
    try {
      final box = await _openBox();
      final List<dynamic> jsonList =
          box.get('recent_transactions', defaultValue: []);

      // Check cache age (optional, but good practice)
      final lastCacheTimeStr = box.get('last_cache_time');
      if (lastCacheTimeStr != null) {
        final lastCacheTime = DateTime.parse(lastCacheTimeStr);
        if (DateTime.now().difference(lastCacheTime).inHours > 6) {
          // Cache expired
          return [];
        }
      }

      return jsonList.map((e) {
        // Handle both Map and JSON string if changes happened
        if (e is String) {
          return TransactionModel.fromJson(json.decode(e));
        } else {
          return TransactionModel.fromJson(Map<String, dynamic>.from(e));
        }
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheTransactions(List<TransactionModel> transactions) async {
    final box = await _openBox();
    // specific to Hive, we can store maps directly but safer to store basic types
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await box.put('recent_transactions', jsonList);
    await box.put('last_cache_time', DateTime.now().toIso8601String());
  }
}
