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
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class CacheException extends AppException {
  const CacheException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class NetworkException extends AppException {
  const NetworkException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class AuthException extends AppException {
  const AuthException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class ValidationException extends AppException {
  const ValidationException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class PermissionException extends AppException {
  const PermissionException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class DeviceException extends AppException {
  const DeviceException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class TimeoutException extends AppException {
  const TimeoutException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class SecurityException extends AppException {
  const SecurityException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class AIException extends AppException {
  const AIException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class AnalyticsException extends AppException {
  const AnalyticsException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class BiometricException extends AppException {
  const BiometricException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class NotificationException extends AppException {
  const NotificationException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class HealthcareFinanceException extends AppException {
  const HealthcareFinanceException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class PredictiveAnalyticsException extends AppException {
  const PredictiveAnalyticsException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

class QuantumSecurityException extends AppException {
  const QuantumSecurityException({
    required String message,
    int? statusCode,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}
