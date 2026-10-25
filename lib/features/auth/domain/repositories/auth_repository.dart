import 'package:rootin_mobile/features/auth/domain/entities/auth_user.dart';

/// Contract for authentication operations
abstract class AuthRepository {
  /// Stream of authentication state changes.
  /// Emits the current [AuthUser] when logged in, or null when logged out.
  Stream<AuthUser?> get authStateChanges;

  /// The currently authenticated user, or null if unauthenticated.
  AuthUser? get currentUser;

  /// Sign in with email and password.
  Future<AuthUser> signInWithPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password.
  /// Returns the [AuthUser] if immediately confirmed, or null if awaiting email confirmation.
  Future<AuthUser?> signUp({required String email, required String password});

  /// Send a password reset email to [email].
  Future<void> sendPasswordResetEmail(String email);

  /// Update the password for the currently authenticated session.
  Future<void> updatePassword(String newPassword);

  /// Sign out the current user and clear local session.
  Future<void> signOut();
}
