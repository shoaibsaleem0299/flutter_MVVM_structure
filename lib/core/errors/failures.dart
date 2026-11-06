sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() => '$runtimeType($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error', this.statusCode]);
  final int? statusCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ServerFailure &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error']);
}
