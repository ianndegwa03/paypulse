import 'package:flutter_test/flutter_test.dart';
import 'package:paypulse/core/utils/validators/email_validator.dart';

void main() {
  group('EmailValidator', () {
    test('valid email returns null', () {
      expect(EmailValidator.validate('test@example.com'), null);
    });

    test('null email returns error', () {
      expect(EmailValidator.validate(null), 'Email is required');
    });

    test('empty email returns error', () {
      expect(EmailValidator.validate(''), 'Email is required');
    });

    test('invalid email returns error', () {
      expect(EmailValidator.validate('invalid'), 'Please enter a valid email address');
    });

    test('email too long returns error', () {
      final longEmail = 'a' * 255 + '@example.com';
      expect(EmailValidator.validate(longEmail), 'Email address is too long');
    });
  });
}