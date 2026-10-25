import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rootin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:rootin_mobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:rootin_mobile/features/settings/settings_screen.dart';
import 'package:rootin_mobile/l10n/generated/app_localizations.dart';

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
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
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

/// Placeholder screen for initial scaffold
class _PlaceholderScreen extends ConsumerWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.home),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l.settings,
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            key: const Key('home_logout_button'),
            icon: const Icon(Icons.logout),
            tooltip: l.logout,
            onPressed:
                () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Rootin Mobile',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              user?.email != null
                  ? l.signedInAs(user!.email!)
                  : l.offlineDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
