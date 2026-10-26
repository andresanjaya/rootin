import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:rootin_mobile/features/reminders/presentation/reminder_pages.dart';
import 'package:rootin_mobile/features/settings/settings_screen.dart';

/// Adapter to convert a [Stream] into a [Listenable] for GoRouter refresh.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ponytail: manual provider until build_runner stabilizes
final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final refreshListenable = GoRouterRefreshStream(authRepo.authStateChanges);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final isLoggedIn = authRepo.currentUser != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      // Unauthenticated users must land on auth routes
      if (!isLoggedIn && !isAuthRoute) {
        return '/auth/login';
      }

      // Authenticated users should not stay on login/register/forgot-password
      if (isLoggedIn &&
          (state.matchedLocation == '/auth/login' ||
              state.matchedLocation == '/auth/register' ||
              state.matchedLocation == '/auth/forgot-password')) {
        return '/';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => ReminderShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const ReminderPage(section: 'today'),
          ),
          GoRoute(
            path: '/reminders',
            builder:
                (context, state) => const ReminderPage(section: 'reminders'),
          ),
          GoRoute(
            path: '/items',
            builder: (context, state) => const ReminderPage(section: 'items'),
          ),
          GoRoute(
            path: '/calendar',
            builder:
                (context, state) => const ReminderPage(section: 'calendar'),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const ReminderPage(section: 'history'),
          ),
        ],
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
    ],
  );
});
