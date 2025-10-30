abstract class ClassFailure {
  const ClassFailure();
}

class NetworkFailure extends ClassFailure {
  final String message;
  const NetworkFailure(this.message);
}

class ServerFailure extends ClassFailure {
  final int? statusCode;
  final String message;
  const ServerFailure({this.statusCode, required this.message});
}

class UnknownFailure extends ClassFailure {
  final String message;
  const UnknownFailure(this.message);
}
