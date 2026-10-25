import 'package:flutter/widgets.dart';
import 'package:rootin_mobile/core/constants/app_constants.dart';
import 'package:rootin_mobile/features/auth/data/datasources/secure_local_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Safely initializes Supabase with [SecureLocalStorage] and fallback.
Future<bool> initializeSupabaseSafely({
  String? url,
  String? anonKey,
  LocalStorage? localStorage,
  GotrueAsyncStorage? pkceStorage,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final effectiveUrl =
      url ??
      const String.fromEnvironment(
        AppConstants.supabaseUrlKey,
        defaultValue: '',
      );
  final effectiveAnonKey =
      anonKey ??
      const String.fromEnvironment(
        AppConstants.supabaseAnonKeyKey,
        defaultValue: '',
      );

  if (effectiveUrl.isEmpty || effectiveAnonKey.isEmpty) {
    debugPrint(
      'Supabase URL or Anon Key not configured; proceeding with fallback.',
    );
    return false;
  }

  try {
    const defaultStorage = SecureLocalStorage();
    await Supabase.initialize(
      url: effectiveUrl,
      publishableKey: effectiveAnonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: localStorage ?? defaultStorage,
        pkceAsyncStorage: pkceStorage ?? defaultStorage,
      ),
    );
    return true;
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
    return false;
  }
}
