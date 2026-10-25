import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/app/theme/app_theme.dart';
import 'package:rootin_mobile/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/reset_password_screen.dart';

Widget createTestWidget(Widget child, {InMemoryAuthRepository? repo}) {
  return ProviderScope(
    overrides: [
      if (repo != null) authRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(theme: AppTheme.light(), home: child),
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('renders all form elements', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Rootin Mobile'), findsOneWidget);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_button')), findsOneWidget);
      expect(find.byKey(const Key('go_to_register_button')), findsOneWidget);
    });

    testWidgets('validates required fields on submit', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'invalidemail',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Format email tidak valid'), findsOneWidget);
    });

    testWidgets('toggles password obscure text visibility', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      final obscureIcon = find.byIcon(Icons.visibility_outlined);
      expect(obscureIcon, findsOneWidget);

      await tester.tap(obscureIcon);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('submits form successfully with valid inputs', (tester) async {
      final repo = InMemoryAuthRepository();
      await tester.pumpWidget(
        createTestWidget(const LoginScreen(), repo: repo),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'user@rootin.id',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(repo.currentUser?.email, equals('user@rootin.id'));
      repo.dispose();
    });

    testWidgets('displays error SnackBar on login failure', (tester) async {
      final repo = InMemoryAuthRepository();
      await tester.pumpWidget(
        createTestWidget(const LoginScreen(), repo: repo),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'error@rootin.id',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      repo.dispose();
    });
  });

  group('RegisterScreen', () {
    testWidgets('renders all registration elements', (tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Daftar Akun'), findsOneWidget);
      expect(find.byKey(const Key('register_email_field')), findsOneWidget);
      expect(find.byKey(const Key('register_password_field')), findsOneWidget);
      expect(
        find.byKey(const Key('register_confirm_password_field')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
    });

    testWidgets('validates matching passwords', (tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('register_email_field')),
        'user@rootin.id',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('register_confirm_password_field')),
        'differentpassword',
      );
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Kata sandi tidak cocok'), findsOneWidget);
    });

    testWidgets('registers user successfully', (tester) async {
      final repo = InMemoryAuthRepository();
      await tester.pumpWidget(
        createTestWidget(const RegisterScreen(), repo: repo),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('register_email_field')),
        'newuser@rootin.id',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('register_confirm_password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Pendaftaran berhasil'), findsOneWidget);
      repo.dispose();
    });
  });

  group('ForgotPasswordScreen', () {
    testWidgets('renders form and handles submit flow', (tester) async {
      final repo = InMemoryAuthRepository();
      await tester.pumpWidget(
        createTestWidget(const ForgotPasswordScreen(), repo: repo),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('forgot_email_field')), findsOneWidget);
      expect(find.byKey(const Key('forgot_submit_button')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('forgot_email_field')),
        'user@rootin.id',
      );
      await tester.tap(find.byKey(const Key('forgot_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Tautan Terkirim'), findsOneWidget);
      expect(find.byKey(const Key('back_to_login_button')), findsOneWidget);
      repo.dispose();
    });
  });

  group('ResetPasswordScreen', () {
    testWidgets(
      'renders reset password form and validates matching passwords',
      (tester) async {
        await tester.pumpWidget(createTestWidget(const ResetPasswordScreen()));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('reset_password_field')), findsOneWidget);
        expect(
          find.byKey(const Key('reset_confirm_password_field')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('reset_submit_button')), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('reset_password_field')),
          'newpass123',
        );
        await tester.enterText(
          find.byKey(const Key('reset_confirm_password_field')),
          'wrongpass',
        );
        await tester.tap(find.byKey(const Key('reset_submit_button')));
        await tester.pumpAndSettle();

        expect(find.text('Kata sandi tidak cocok'), findsOneWidget);
      },
    );
  });
}
