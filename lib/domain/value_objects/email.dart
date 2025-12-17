import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:paypulse/core/errors/failures.dart';

class Email extends Equatable {
  final String value;

  const Email._(this.value);

  static Either<Failure, Email> create(String input) {
    const emailRegex =
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$';

    if (input.isEmpty) {
      return const Left(ValidationFailure(message: 'Email cannot be empty'));
    }

    if (!RegExp(emailRegex).hasMatch(input)) {
      return const Left(ValidationFailure(message: 'Invalid email format'));
    }

    if (input.length > 254) {
      return const Left(ValidationFailure(message: 'Email is too long'));
    }

    return Right(Email._(input));
  }

  String get localPart => value.split('@').first;

  String get domain => value.split('@').last;

  bool get isCommonProvider {
    const commonProviders = [
      'gmail.com',
      'yahoo.com',
      'outlook.com',
      'hotmail.com',
      'icloud.com',
    ];
    return commonProviders.contains(domain.toLowerCase());
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Email($value)';
}
