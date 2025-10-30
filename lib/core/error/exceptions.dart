/// Base class for all exceptions in the app
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => message; // Return just the message, no prefix
}

/// Server exceptions
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

/// Auth exceptions
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException(super.message, [super.code]);
}

class UserNotFoundException extends AppException {
  const UserNotFoundException(super.message, [super.code]);
}

class EmailAlreadyExistsException extends AppException {
  const EmailAlreadyExistsException(super.message, [super.code]);
}

class WeakPasswordException extends AppException {
  const WeakPasswordException(super.message, [super.code]);
}

/// Property exceptions
class PropertyNotFoundException extends AppException {
  const PropertyNotFoundException(super.message, [super.code]);
}

class NoPropertiesFoundException extends AppException {
  const NoPropertiesFoundException(super.message, [super.code]);
}

class PropertySearchException extends AppException {
  const PropertySearchException(super.message, [super.code]);
}

/// Permission exceptions
class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message, [super.code]);
}

class LocationPermissionDeniedException extends AppException {
  const LocationPermissionDeniedException(super.message, [super.code]);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

class InvalidEmailException extends AppException {
  const InvalidEmailException(super.message, [super.code]);
}

class InvalidPhoneNumberException extends AppException {
  const InvalidPhoneNumberException(super.message, [super.code]);
}

class PasswordMismatchException extends AppException {
  const PasswordMismatchException(super.message, [super.code]);
}

class RequiredFieldException extends AppException {
  const RequiredFieldException(super.message, [super.code]);
}
