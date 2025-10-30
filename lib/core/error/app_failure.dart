// A simple domain-level Failure used with Either<Failure, T>
class Failure implements Exception {
  final String message;
  final int? statusCode; // optional HTTP status
  final Object? cause; // original error if any

  const Failure._(this.message, {this.statusCode, this.cause});

  factory Failure.server({
    String message = 'Server error',
    int? statusCode,
    Object? cause,
  }) => Failure._(message, statusCode: statusCode, cause: cause);

  factory Failure.network([String message = 'Network error']) =>
      Failure._(message);

  factory Failure.unexpected([Object? cause]) =>
      Failure._('Unexpected error', cause: cause);

  @override
  String toString() =>
      'Failure(message: $message, statusCode: $statusCode, cause: $cause)';
}
