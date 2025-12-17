import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:paypulse/core/errors/failures.dart';

class Amount extends Equatable {
  final double value;

  const Amount._(this.value);

  static Either<Failure, Amount> create(double value, {String? currency}) {
    if (value < 0) {
      return const Left(
          ValidationFailure(message: 'Amount cannot be negative'));
    }

    if (value > 999999999.99) {
      return const Left(
          ValidationFailure(message: 'Amount exceeds maximum limit'));
    }

    return Right(Amount._(value));
  }

  Amount add(Amount other) => Amount._(value + other.value);

  Amount subtract(Amount other) => Amount._(value - other.value);

  Amount multiply(double factor) => Amount._(value * factor);

  Amount divide(double divisor) {
    if (divisor == 0) {
      throw ArgumentError('Cannot divide by zero');
    }
    return Amount._(value / divisor);
  }

  String format({int decimalPlaces = 2, String? currencySymbol}) {
    final formattedValue = value.toStringAsFixed(decimalPlaces);
    return currencySymbol != null
        ? '$currencySymbol$formattedValue'
        : formattedValue;
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Amount($value)';
}
