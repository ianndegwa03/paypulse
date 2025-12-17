import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:paypulse/core/errors/failures.dart';

/// Value object for phone numbers with validation
class PhoneNumber extends Equatable {
  final String value;

  const PhoneNumber._(this.value);

  /// Create a validated phone number
  static Either<Failure, PhoneNumber> create(String input) {
    // Remove all non-digit characters for validation
    final digitsOnly = input.replaceAll(RegExp(r'[^\d+]'), '');

    if (input.isEmpty) {
      return const Left(
          ValidationFailure(message: 'Phone number cannot be empty'));
    }

    // Check for minimum length (at least 7 digits for local numbers)
    final pureDigits = digitsOnly.replaceAll('+', '');
    if (pureDigits.length < 7) {
      return const Left(
          ValidationFailure(message: 'Phone number is too short'));
    }

    // Check for maximum length (max 15 digits per E.164)
    if (pureDigits.length > 15) {
      return const Left(ValidationFailure(message: 'Phone number is too long'));
    }

    // Validate format (must start with + or digits)
    if (!RegExp(r'^[+\d][\d\s\-().]+$').hasMatch(input)) {
      return const Left(
          ValidationFailure(message: 'Invalid phone number format'));
    }

    return Right(PhoneNumber._(digitsOnly));
  }

  /// Create phone number without validation (use carefully)
  factory PhoneNumber.fromString(String value) {
    return PhoneNumber._(value);
  }

  /// Get normalized E.164 format
  String get e164Format {
    final normalized = value.replaceAll(RegExp(r'[^\d+]'), '');
    if (normalized.startsWith('+')) {
      return normalized;
    }
    return '+$normalized';
  }

  /// Get display format
  String get displayFormat {
    // Basic formatting - add spaces for readability
    final normalized = value.replaceAll(RegExp(r'[^\d]'), '');
    if (normalized.length >= 10) {
      // Format as: +XX XXX XXX XXXX
      return e164Format;
    }
    return value;
  }

  /// Get country code if present
  String? get countryCode {
    if (value.startsWith('+')) {
      // Extract first 1-3 digits after +
      final match = RegExp(r'^\+(\d{1,3})').firstMatch(value);
      return match?.group(1);
    }
    return null;
  }

  /// Check if this is a Kenyan phone number
  bool get isKenyan {
    return value.startsWith('+254') ||
        value.startsWith('254') ||
        value.startsWith('07');
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'PhoneNumber($value)';
}
