/// Base class for all failures in the application
abstract class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Database operation failure
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Network operation failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
