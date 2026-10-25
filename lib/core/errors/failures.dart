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

/// Invalid login credentials
class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([
    super.message =
        'Email atau kata sandi tidak valid. Silakan periksa kembali.',
  ]);
}

/// Email already registered
class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure([
    super.message =
        'Email sudah terdaftar. Silakan gunakan email lain atau masuk.',
  ]);
}

/// Weak password
class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure([
    super.message = 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.',
  ]);
}

/// Invalid email format
class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure([
    super.message = 'Format alamat email tidak valid.',
  ]);
}

/// User not found
class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([
    super.message = 'Akun dengan email ini tidak ditemukan.',
  ]);
}

/// Rate limit exceeded
class RateLimitFailure extends AuthFailure {
  const RateLimitFailure([
    super.message = 'Terlalu banyak percobaan. Silakan coba lagi nanti.',
  ]);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
