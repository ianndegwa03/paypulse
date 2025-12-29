import 'package:equatable/equatable.dart';

class CryptoAsset extends Equatable {
  final String symbol;
  final String name;
  final double amount;
  final double currentPrice;
  final double change24h;
  final String iconUrl;

  const CryptoAsset({
    required this.symbol,
    required this.name,
    required this.amount,
    required this.currentPrice,
    required this.change24h,
    required this.iconUrl,
  });

  double get valueUsd => amount * currentPrice;

  @override
  List<Object?> get props =>
      [symbol, name, amount, currentPrice, change24h, iconUrl];

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'amount': amount,
        'currentPrice': currentPrice,
        'change24h': change24h,
        'iconUrl': iconUrl,
      };

  factory CryptoAsset.fromJson(Map<String, dynamic> json) => CryptoAsset(
        symbol: json['symbol'],
        name: json['name'],
        amount: (json['amount'] as num).toDouble(),
        currentPrice: (json['currentPrice'] as num).toDouble(),
        change24h: (json['change24h'] as num).toDouble(),
        iconUrl: json['iconUrl'],
      );
}

class YieldOpportunity extends Equatable {
  final String id;
  final String platform;
  final double apy;
  final String riskLevel;
  final String category;
  final String iconUrl;

  const YieldOpportunity({
    required this.id,
    required this.platform,
    required this.apy,
    required this.riskLevel,
    required this.category,
    required this.iconUrl,
  });

  @override
  List<Object?> get props => [id, platform, apy, riskLevel, category, iconUrl];

  Map<String, dynamic> toJson() => {
        'id': id,
        'platform': platform,
        'apy': apy,
        'riskLevel': riskLevel,
        'category': category,
        'iconUrl': iconUrl,
      };

  factory YieldOpportunity.fromJson(Map<String, dynamic> json) =>
      YieldOpportunity(
        id: json['id'],
        platform: json['platform'],
        apy: (json['apy'] as num).toDouble(),
        riskLevel: json['riskLevel'],
        category: json['category'],
        iconUrl: json['iconUrl'],
      );
}

class RecurringBill extends Equatable {
  final String id;
  final String merchant;
  final double amount;
  final String frequency;
  final DateTime nextDate;
  final String category;
  final bool isAutoPayEnabled;

  const RecurringBill({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.frequency,
    required this.nextDate,
    required this.category,
    this.isAutoPayEnabled = false,
  });

  @override
  List<Object?> get props =>
      [id, merchant, amount, frequency, nextDate, category, isAutoPayEnabled];

  Map<String, dynamic> toJson() => {
        'id': id,
        'merchant': merchant,
        'amount': amount,
        'frequency': frequency,
        'nextDate': nextDate.toIso8601String(),
        'category': category,
        'isAutoPayEnabled': isAutoPayEnabled,
      };

  factory RecurringBill.fromJson(Map<String, dynamic> json) => RecurringBill(
        id: json['id'],
        merchant: json['merchant'],
        amount: (json['amount'] as num).toDouble(),
        frequency: json['frequency'],
        nextDate: DateTime.parse(json['nextDate']),
        category: json['category'],
        isAutoPayEnabled: json['isAutoPayEnabled'] ?? false,
      );
}
