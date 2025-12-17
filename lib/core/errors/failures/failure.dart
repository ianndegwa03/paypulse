import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final dynamic data;

  const Failure({
    required this.message,
    this.code,
    this.data,
  });

  @override
  List<Object?> get props => [message, code, data];
}

class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Server error occurred',
    int? code,
    dynamic data,
  }) : super(message: message, code: code, data: data);
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection',
    int? code,
    dynamic data,
  }) : super(message: message, code: code, data: data);
}

class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Cache error occurred',
    int? code,
    dynamic data,
  }) : super(message: message, code: code, data: data);
}

class AuthFailure extends Failure {
  const AuthFailure({
    String message = 'Authentication failed',
    int? code,
    dynamic data,
  }) : super(message: message, code: code, data: data);
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    String message = 'Validation failed',
    int? code,
    dynamic data,
  }) : super(message: message, code: code, data: data);
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    String message = 'Permission denied',
    int? code,
    dynamic data,
  }) : super(message: message, code: code, data: data);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'Request timeout',
    int? code,
    dynamic data,
  }) : super(message: message, code: code, data: data);
}

class GenericFailure extends Failure {
  const GenericFailure({
    String message = 'An error occurred',
    int? code,
    dynamic data,
  }) : super(message: message, code: code, data: data);
}