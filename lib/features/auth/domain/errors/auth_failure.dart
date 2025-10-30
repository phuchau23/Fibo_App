import 'package:equatable/equatable.dart';

/// Base class for authentication failures
abstract class AuthFailure extends Equatable {
  const AuthFailure();

  @override
  List<Object?> get props => [];
}

/// Server failure
class ServerFailure extends AuthFailure {
  final String message;
  final String? code;

  const ServerFailure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'ServerFailure: $message';
}

/// Network failure
class NetworkFailure extends AuthFailure {
  final String message;

  const NetworkFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'NetworkFailure: $message';
}

/// Invalid credentials failure
class InvalidCredentialsFailure extends AuthFailure {
  final String message;

  const InvalidCredentialsFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'InvalidCredentialsFailure: $message';
}

/// User not found failure
class UserNotFoundFailure extends AuthFailure {
  final String message;

  const UserNotFoundFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'UserNotFoundFailure: $message';
}

/// Invalid OTP failure
class InvalidOtpFailure extends AuthFailure {
  final String message;

  const InvalidOtpFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'InvalidOtpFailure: $message';
}

/// OTP expired failure
class OtpExpiredFailure extends AuthFailure {
  final String message;

  const OtpExpiredFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'OtpExpiredFailure: $message';
}

/// OTP cooldown failure
class OtpCooldownFailure extends AuthFailure {
  final String message;
  final int cooldownSeconds;

  const OtpCooldownFailure(this.message, this.cooldownSeconds);

  @override
  List<Object?> get props => [message, cooldownSeconds];

  @override
  String toString() => 'OtpCooldownFailure: $message (${cooldownSeconds}s)';
}

/// Validation failure
class ValidationFailure extends AuthFailure {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationFailure(this.message, [this.fieldErrors]);

  @override
  List<Object?> get props => [message, fieldErrors];

  @override
  String toString() => 'ValidationFailure: $message';
}

/// Token expired failure
class TokenExpiredFailure extends AuthFailure {
  final String message;

  const TokenExpiredFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'TokenExpiredFailure: $message';
}

/// Permission denied failure
class PermissionDeniedFailure extends AuthFailure {
  final String message;

  const PermissionDeniedFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'PermissionDeniedFailure: $message';
}

/// Cache failure
class CacheFailure extends AuthFailure {
  final String message;

  const CacheFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'CacheFailure: $message';
}
