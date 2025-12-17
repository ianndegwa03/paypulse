import 'package:equatable/equatable.dart';
import 'package:paypulse/domain/entities/enums.dart';

class Wallet extends Equatable {
  final String id;
  final double balance;
  final CurrencyType currency;

  const Wallet({
    required this.id,
    required this.balance,
    required this.currency,
  });

  @override
  List<Object?> get props => [id, balance, currency];
}
