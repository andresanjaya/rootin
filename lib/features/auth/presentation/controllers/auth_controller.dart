import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rootin_mobile/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:rootin_mobile/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:rootin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:rootin_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Provider for the [AuthRepository] implementation.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  try {
    return SupabaseAuthRepository();
  } catch (_) {
    // Fallback to in-memory auth repository when Supabase is not initialized
    return InMemoryAuthRepository();
  }
});

/// Stream provider for user authentication state changes.
final authStateChangesProvider = StreamProvider<AuthUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Provider for the current [AuthUser], if logged in.
final currentUserProvider = Provider<AuthUser?>((ref) {
  final asyncState = ref.watch(authStateChangesProvider);
  return asyncState.valueOrNull ??
      ref.watch(authRepositoryProvider).currentUser;
});

/// Controller for auth actions (login, register, forgot/reset password, logout)
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._authRepository) : super(const AsyncData(null));

  final AuthRepository _authRepository;

  /// Sign in with email and password
  Future<bool> signInWithPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _authRepository.signInWithPassword(
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _authRepository.signUp(email: email, password: password);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Send password reset link
  Future<bool> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    try {
      await _authRepository.sendPasswordResetEmail(email);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Update password for the current session
  Future<bool> updatePassword(String newPassword) async {
    state = const AsyncLoading();
    try {
      await _authRepository.updatePassword(newPassword);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Sign out current session
  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _authRepository.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Provider for [AuthController]
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return AuthController(repo);
    });
