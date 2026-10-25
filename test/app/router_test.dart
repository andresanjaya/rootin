import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/app/app.dart';
import 'package:rootin_mobile/app/router.dart';
import 'package:rootin_mobile/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:rootin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/register_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .localesTestValue = [const Locale('id')];
  });
  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .clearLocalesTestValue();
  });
  group('Router and Redirect Guards', () {
    testWidgets('unauthenticated user is redirected to /auth/login', (
      tester,
    ) async {
      final repo = InMemoryAuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
          child: const RootinApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      repo.dispose();
    });

    testWidgets('unauthenticated user can navigate to /auth/register', (
      tester,
    ) async {
      final repo = InMemoryAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RootinApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(routerProvider).go('/auth/register');
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
      container.dispose();
      repo.dispose();
    });

    testWidgets('authenticated user stays on home screen /', (tester) async {
      final repo = InMemoryAuthRepository(
        initialUser: AuthUser(
          id: 'user-1',
          email: 'user@rootin.id',
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
          child: const RootinApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rootin Mobile'), findsOneWidget);
      expect(find.text('Masuk sebagai: user@rootin.id'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      repo.dispose();
    });

    testWidgets(
      'authenticated user navigating to /auth/login is redirected to /',
      (tester) async {
        final repo = InMemoryAuthRepository(
          initialUser: AuthUser(
            id: 'user-1',
            email: 'user@rootin.id',
            createdAt: DateTime.now(),
          ),
        );
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const RootinApp(),
          ),
        );
        await tester.pumpAndSettle();

        container.read(routerProvider).go('/auth/login');
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsNothing);
        expect(find.text('Masuk sebagai: user@rootin.id'), findsOneWidget);
        container.dispose();
        repo.dispose();
      },
    );

    testWidgets('signing out redirects authenticated user to /auth/login', (
      tester,
    ) async {
      final repo = InMemoryAuthRepository(
        initialUser: AuthUser(
          id: 'user-1',
          email: 'user@rootin.id',
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
          child: const RootinApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Masuk sebagai: user@rootin.id'), findsOneWidget);

      await tester.tap(find.byKey(const Key('home_logout_button')));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      repo.dispose();
    });
  });
}
