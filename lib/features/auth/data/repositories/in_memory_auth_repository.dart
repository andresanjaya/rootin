import 'dart:async';

import 'package:rootin_mobile/core/errors/failures.dart';
import 'package:rootin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:rootin_mobile/features/auth/domain/repositories/auth_repository.dart';

/// In-memory implementation of [AuthRepository] for testing and offline/uninitialized fallback.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({AuthUser? initialUser}) : _currentUser = initialUser {
    _controller = StreamController<AuthUser?>.broadcast();
  }

  AuthUser? _currentUser;
  late final StreamController<AuthUser?> _controller;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (password.length < 6) {
      throw const WeakPasswordFailure();
    }
    if (email.contains('error')) {
      throw const InvalidCredentialsFailure();
    }
    final user = AuthUser(
      id: 'mock-user-id',
      email: email,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<AuthUser?> signUp({
    required String email,
    required String password,
  }) async {
    if (password.length < 6) {
      throw const WeakPasswordFailure();
    }
    if (email.contains('existing')) {
      throw const EmailAlreadyInUseFailure();
    }
    final user = AuthUser(
      id: 'mock-user-id',
      email: email,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (email.contains('notfound')) {
      throw const UserNotFoundFailure();
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    if (newPassword.length < 6) {
      throw const WeakPasswordFailure();
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
