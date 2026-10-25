import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/core/errors/failures.dart';
import 'package:rootin_mobile/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:rootin_mobile/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:rootin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

void main() {
  group('mapAuthException', () {
    test('maps invalid_credentials to InvalidCredentialsFailure', () {
      const exception = AuthException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'invalid_credentials',
      );
      final failure = mapAuthException(exception);
      expect(failure, isA<InvalidCredentialsFailure>());
      expect(failure.message, contains('Email atau kata sandi tidak valid'));
    });

    test('maps user_already_exists to EmailAlreadyInUseFailure', () {
      const exception = AuthException(
        'User already registered',
        code: 'user_already_exists',
      );
      final failure = mapAuthException(exception);
      expect(failure, isA<EmailAlreadyInUseFailure>());
      expect(failure.message, contains('Email sudah terdaftar'));
    });

    test('maps weak_password to WeakPasswordFailure', () {
      const exception = AuthException(
        'Password should be at least 6 characters',
        code: 'weak_password',
      );
      final failure = mapAuthException(exception);
      expect(failure, isA<WeakPasswordFailure>());
      expect(failure.message, contains('minimal 6 karakter'));
    });

    test('maps invalid_email to InvalidEmailFailure', () {
      const exception = AuthException(
        'Unable to validate email address: invalid format',
        code: 'invalid_email',
      );
      final failure = mapAuthException(exception);
      expect(failure, isA<InvalidEmailFailure>());
      expect(failure.message, contains('Format alamat email tidak valid'));
    });

    test('maps user_not_found to UserNotFoundFailure', () {
      const exception = AuthException('User not found', code: 'user_not_found');
      final failure = mapAuthException(exception);
      expect(failure, isA<UserNotFoundFailure>());
      expect(
        failure.message,
        contains('Akun dengan email ini tidak ditemukan'),
      );
    });

    test('maps rate limit to RateLimitFailure', () {
      const exception = AuthException(
        'For security purposes, you can only request this after 60 seconds',
        statusCode: '429',
        code: 'over_email_send_rate_limit',
      );
      final failure = mapAuthException(exception);
      expect(failure, isA<RateLimitFailure>());
      expect(failure.message, contains('Terlalu banyak percobaan'));
    });

    test('maps network errors to NetworkFailure', () {
      const exception = SocketException('Failed host lookup');
      final failure = mapAuthException(exception);
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, contains('Gagal terhubung ke server'));
    });

    test('maps generic AuthException to AuthFailure with original message', () {
      const exception = AuthException('Unknown auth error occurred');
      final failure = mapAuthException(exception);
      expect(failure, isA<AuthFailure>());
      expect(failure.message, equals('Unknown auth error occurred'));
    });

    test('returns Failure directly if already a Failure', () {
      const failureIn = ValidationFailure('Invalid input');
      final failureOut = mapAuthException(failureIn);
      expect(failureOut, equals(failureIn));
    });
  });

  group('AuthUser', () {
    test('value equality and hashCode', () {
      final now = DateTime(2026, 10, 25);
      final user1 = AuthUser(id: 'u1', email: 'test@rootin.id', createdAt: now);
      final user2 = AuthUser(id: 'u1', email: 'test@rootin.id', createdAt: now);
      final user3 = AuthUser(
        id: 'u2',
        email: 'test2@rootin.id',
        createdAt: now,
      );

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
      expect(user1, isNot(equals(user3)));
      expect(user1.toString(), contains('test@rootin.id'));
    });
  });

  group('InMemoryAuthRepository', () {
    late InMemoryAuthRepository repo;

    setUp(() {
      repo = InMemoryAuthRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    test('sign in, sign out, and auth stream flow', () async {
      expect(repo.currentUser, isNull);

      final streamExpectation = expectLater(
        repo.authStateChanges,
        emitsInOrder([
          isA<AuthUser>().having((u) => u.email, 'email', 'user@rootin.id'),
          isNull,
        ]),
      );

      final user = await repo.signInWithPassword(
        email: 'user@rootin.id',
        password: 'password123',
      );
      expect(repo.currentUser, equals(user));

      await repo.signOut();
      expect(repo.currentUser, isNull);

      await streamExpectation;
    });

    test('sign in with invalid email triggers failure', () async {
      expect(
        () => repo.signInWithPassword(
          email: 'error@rootin.id',
          password: 'password123',
        ),
        throwsA(isA<InvalidCredentialsFailure>()),
      );
    });

    test('sign up with existing email triggers failure', () async {
      expect(
        () => repo.signUp(email: 'existing@rootin.id', password: 'password123'),
        throwsA(isA<EmailAlreadyInUseFailure>()),
      );
    });

    test('password under 6 chars triggers WeakPasswordFailure', () async {
      expect(
        () => repo.signInWithPassword(email: 'test@rootin.id', password: '123'),
        throwsA(isA<WeakPasswordFailure>()),
      );
    });
  });
}
