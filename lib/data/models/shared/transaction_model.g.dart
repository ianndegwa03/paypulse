// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 3;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      description: fields[2] as String,
      date: fields[3] as DateTime,
      categoryId: fields[4] as String,
      paymentMethodId: fields[5] as String,
      type: fields[6] as TransactionType,
      currency: fields[7] as CurrencyType,
      status: fields[8] as TransactionStatus,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.paymentMethodId)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.currency)
      ..writeByte(8)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      categoryId: json['category_id'] as String,
      paymentMethodId: json['payment_method_id'] as String,
      type: $enumDecodeNullable(_$TransactionTypeEnumMap, json['type']) ??
          TransactionType.debit,
      currency: $enumDecodeNullable(_$CurrencyTypeEnumMap, json['currency']) ??
          CurrencyType.USD,
      status: $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']) ??
          TransactionStatus.completed,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'category_id': instance.categoryId,
      'payment_method_id': instance.paymentMethodId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'currency': _$CurrencyTypeEnumMap[instance.currency]!,
      'status': _$TransactionStatusEnumMap[instance.status]!,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.credit: 'credit',
  TransactionType.debit: 'debit',
  TransactionType.transfer: 'transfer',
  TransactionType.payment: 'payment',
};

const _$CurrencyTypeEnumMap = {
  CurrencyType.USD: 'USD',
  CurrencyType.EUR: 'EUR',
  CurrencyType.GBP: 'GBP',
  CurrencyType.JPY: 'JPY',
  CurrencyType.ETH: 'ETH',
  CurrencyType.BTC: 'BTC',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.completed: 'completed',
  TransactionStatus.pending: 'pending',
  TransactionStatus.failed: 'failed',
  TransactionStatus.cancelled: 'cancelled',
};
