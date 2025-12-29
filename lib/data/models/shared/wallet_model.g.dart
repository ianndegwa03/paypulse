// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletModelAdapter extends TypeAdapter<WalletModel> {
  @override
  final int typeId = 2;

  @override
  WalletModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      balance: fields[3] as double,
      currency: fields[4] as CurrencyType,
      isDefault: fields[5] as bool,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      transactions: (fields[8] as List).cast<TransactionModel>(),
      metadata: (fields[9] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, WalletModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.isDefault)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.transactions)
      ..writeByte(9)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: $enumDecode(_$CurrencyTypeEnumMap, json['currency']),
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'balance': instance.balance,
      'currency': _$CurrencyTypeEnumMap[instance.currency]!,
      'is_default': instance.isDefault,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'transactions': instance.transactions,
      'metadata': instance.metadata,
    };

const _$CurrencyTypeEnumMap = {
  CurrencyType.USD: 'USD',
  CurrencyType.EUR: 'EUR',
  CurrencyType.GBP: 'GBP',
  CurrencyType.JPY: 'JPY',
};
