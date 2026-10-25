import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Secure session storage delegate for Supabase Auth using [FlutterSecureStorage].
/// Implements both [LocalStorage] and [GotrueAsyncStorage] for PKCE storage.
class SecureLocalStorage extends LocalStorage implements GotrueAsyncStorage {
  const SecureLocalStorage({
    FlutterSecureStorage? storage,
    this.persistSessionKey = 'rootin_supabase_auth_session',
  }) : _storage =
           storage ??
           const FlutterSecureStorage(
             aOptions: AndroidOptions(encryptedSharedPreferences: true),
             iOptions: IOSOptions(
               accessibility: KeychainAccessibility.first_unlock,
             ),
           );

  final FlutterSecureStorage _storage;
  final String persistSessionKey;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async {
    final value = await _storage.read(key: persistSessionKey);
    return value != null && value.isNotEmpty;
  }

  @override
  Future<String?> accessToken() {
    return _storage.read(key: persistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) {
    return _storage.write(key: persistSessionKey, value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() {
    return _storage.delete(key: persistSessionKey);
  }

  @override
  Future<String?> getItem({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<void> setItem({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> removeItem({required String key}) {
    return _storage.delete(key: key);
  }
}
