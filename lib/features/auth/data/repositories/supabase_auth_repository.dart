import 'dart:io';

import 'package:rootin_mobile/core/errors/failures.dart';
import 'package:rootin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:rootin_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

/// Maps Supabase [AuthException] and related errors to domain [Failure]s.
Failure mapAuthException(Object error) {
  if (error is Failure) return error;

  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    final code = error.code?.toLowerCase() ?? '';
    final status = error.statusCode ?? '';

    if (code == 'invalid_credentials' ||
        msg.contains('invalid login credentials') ||
        msg.contains('invalid claim') ||
        status == '400' && msg.contains('invalid')) {
      return const InvalidCredentialsFailure();
    }
    if (code == 'user_already_exists' ||
        msg.contains('user already registered') ||
        msg.contains('already registered') ||
        msg.contains('already in use')) {
      return const EmailAlreadyInUseFailure();
    }
    if (code == 'weak_password' ||
        msg.contains('password should be at least') ||
        msg.contains('weak password')) {
      return const WeakPasswordFailure();
    }
    if (code == 'validation_failed' ||
        code == 'invalid_email' ||
        msg.contains('valid email')) {
      return const InvalidEmailFailure();
    }
    if (code == 'user_not_found' || msg.contains('user not found')) {
      return const UserNotFoundFailure();
    }
    if (code.contains('rate_limit') ||
        status == '429' ||
        msg.contains('rate limit') ||
        msg.contains('too many requests')) {
      return const RateLimitFailure();
    }

    return AuthFailure(error.message);
  }

  if (error is SocketException ||
      error.toString().contains('SocketException') ||
      error.toString().contains('Failed host lookup') ||
      error.toString().contains('Network is unreachable')) {
    return const NetworkFailure(
      'Gagal terhubung ke server. Periksa koneksi internet Anda.',
    );
  }

  return AuthFailure(error.toString());
}

/// Supabase implementation of [AuthRepository]
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({GoTrueClient? authClient})
    : _auth = authClient ?? Supabase.instance.client.auth;

  final GoTrueClient _auth;

  AuthUser _mapUser(User user) {
    return AuthUser(
      id: user.id,
      email: user.email,
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user != null ? _mapUser(user) : null;
    });
  }

  @override
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    return user != null ? _mapUser(user) : null;
  }

  @override
  Future<AuthUser> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Gagal masuk. Pengguna tidak ditemukan.');
      }
      return _mapUser(user);
    } catch (e) {
      throw mapAuthException(e);
    }
  }

  @override
  Future<AuthUser?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      return user != null ? _mapUser(user) : null;
    } catch (e) {
      throw mapAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.rootin://reset-callback/',
      );
    } catch (e) {
      throw mapAuthException(e);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw mapAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw mapAuthException(e);
    }
  }
}
