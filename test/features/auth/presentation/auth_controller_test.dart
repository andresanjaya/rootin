import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  group('AuthController', () {
    late InMemoryAuthRepository repo;
    late ProviderContainer container;

    setUp(() {
      repo = InMemoryAuthRepository();
      container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );
    });

    tearDown(() {
      container.dispose();
      repo.dispose();
    });

    test('initial state is AsyncData(null)', () {
      final state = container.read(authControllerProvider);
      expect(state, const AsyncData<void>(null));
    });

    test('signInWithPassword succeeds with valid input', () async {
      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.signInWithPassword(
        email: 'user@rootin.id',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(
        container.read(authControllerProvider),
        const AsyncData<void>(null),
      );
      expect(
        container.read(currentUserProvider)?.email,
        equals('user@rootin.id'),
      );
    });

    test('signInWithPassword fails with invalid email', () async {
      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.signInWithPassword(
        email: 'error@rootin.id',
        password: 'password123',
      );

      expect(result, isFalse);
      expect(container.read(authControllerProvider), isA<AsyncError<void>>());
    });

    test('signUp succeeds and registers user', () async {
      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.signUp(
        email: 'newuser@rootin.id',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(
        container.read(authControllerProvider),
        const AsyncData<void>(null),
      );
    });

    test('signUp fails if user already exists', () async {
      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.signUp(
        email: 'existing@rootin.id',
        password: 'password123',
      );

      expect(result, isFalse);
      expect(container.read(authControllerProvider), isA<AsyncError<void>>());
    });

    test('sendPasswordResetEmail success and failure', () async {
      final controller = container.read(authControllerProvider.notifier);

      final success = await controller.sendPasswordResetEmail('user@rootin.id');
      expect(success, isTrue);

      final failure = await controller.sendPasswordResetEmail(
        'notfound@rootin.id',
      );
      expect(failure, isFalse);
    });

    test('updatePassword success and failure', () async {
      final controller = container.read(authControllerProvider.notifier);

      final success = await controller.updatePassword('newpassword123');
      expect(success, isTrue);

      final failure = await controller.updatePassword('123');
      expect(failure, isFalse);
    });

    test('signOut clears current user and updates state', () async {
      final controller = container.read(authControllerProvider.notifier);
      await controller.signInWithPassword(
        email: 'user@rootin.id',
        password: 'password123',
      );
      expect(container.read(currentUserProvider), isNotNull);

      await controller.signOut();
      expect(
        container.read(authControllerProvider),
        const AsyncData<void>(null),
      );
      expect(container.read(currentUserProvider), isNull);
    });
  });
}
