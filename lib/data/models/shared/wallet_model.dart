import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:paypulse/data/models/shared/transaction_model.dart';

part 'wallet_model.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class WalletModel {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'user_id')
  final String userId;

  @HiveField(2)
  @JsonKey(name: 'name')
  final String name;

  @HiveField(3)
  @JsonKey(name: 'balance')
  final double balance;

  @HiveField(4)
  @JsonKey(name: 'currency')
  final CurrencyType currency;

  @HiveField(5)
  @JsonKey(name: 'is_default')
  final bool isDefault;

  @HiveField(6)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(7)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @HiveField(8)
  @JsonKey(name: 'transactions')
  final List<TransactionModel> transactions;

  @HiveField(9)
  @JsonKey(name: 'metadata')
  final Map<String, dynamic> metadata;

  WalletModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.currency,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.transactions = const [],
    this.metadata = const {},
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.credit)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.debit)
      .fold(0.0, (sum, t) => sum + t.amount);

  List<TransactionModel> get recentTransactions =>
      transactions.sublist(0, transactions.length > 5 ? 5 : transactions.length);

  WalletModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? balance,
    CurrencyType? currency,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TransactionModel>? transactions,
    Map<String, dynamic>? metadata,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactions: transactions ?? this.transactions,
      metadata: metadata ?? this.metadata,
    );
  }
}