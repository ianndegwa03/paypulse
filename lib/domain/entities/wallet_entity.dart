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
    this.cardNumber = '4242',
    this.expiryDate = '12/28',
    this.isFrozen = false,
  });

  final String cardNumber;
  final String expiryDate;
  final bool isFrozen;

  @override
  List<Object?> get props =>
      [id, balance, currency, cardNumber, expiryDate, isFrozen];
}
