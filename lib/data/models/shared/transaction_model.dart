import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:paypulse/domain/entities/enums.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class TransactionModel {
  @HiveField(0)
  @JsonKey(name: 'id')
  final String id;

  @HiveField(1)
  @JsonKey(name: 'amount')
  final double amount;

  @HiveField(2)
  @JsonKey(name: 'description')
  final String description;

  @HiveField(3)
  @JsonKey(name: 'date')
  final DateTime date;

  @HiveField(4)
  @JsonKey(name: 'category_id')
  final String categoryId;

  @HiveField(5)
  @JsonKey(name: 'payment_method_id')
  final String paymentMethodId;

  @HiveField(6)
  @JsonKey(name: 'type')
  final TransactionType type;

  @HiveField(7)
  @JsonKey(name: 'currency')
  final CurrencyType currency;

  @HiveField(8)
  @JsonKey(name: 'status')
  final TransactionStatus status;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.paymentMethodId,
    this.type = TransactionType.debit,
    this.currency = CurrencyType.USD,
    this.status = TransactionStatus.completed,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}