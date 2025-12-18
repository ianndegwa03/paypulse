abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'AppException: $message';
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class DeviceException extends AppException {
  const DeviceException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class SecurityException extends AppException {
  const SecurityException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class AIException extends AppException {
  const AIException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class AnalyticsException extends AppException {
  const AnalyticsException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class BiometricException extends AppException {
  const BiometricException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class NotificationException extends AppException {
  const NotificationException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class HealthcareFinanceException extends AppException {
  const HealthcareFinanceException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class PredictiveAnalyticsException extends AppException {
  const PredictiveAnalyticsException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class QuantumSecurityException extends AppException {
  const QuantumSecurityException({
    required super.message,
    super.statusCode,
    super.data,
  });
}
