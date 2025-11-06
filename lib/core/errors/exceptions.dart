/// A base class for all custom exceptions.
abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// An exception that is thrown when there is an issue with the server.
class ServerException extends AppException {
  ServerException(String message) : super(message);
}

/// An exception that is thrown when there is an issue with the network connection.
class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

/// An exception that is thrown when there is an issue with the cache.
class CacheException extends AppException {
  CacheException(String message) : super(message);
}

/// An exception that is thrown when there is an issue with the input.
class BadRequestException extends AppException {
  BadRequestException(String message) : super(message);
}

/// An exception that is thrown when there is an issue with authentication.
class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message);
}

/// An exception that is thrown when there is an issue with authorization.
class ForbiddenException extends AppException {
  ForbiddenException(String message) : super(message);
}

/// An exception that is thrown when the requested resource is not found.
class NotFoundException extends AppException {
  NotFoundException(String message) : super(message);
}
