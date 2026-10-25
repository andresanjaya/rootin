import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rootin_mobile/features/auth/data/datasources/secure_local_storage.dart';

class FakeFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _store[key] = value;
    } else {
      _store.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store.containsKey(key);
  }
}

void main() {
  group('SecureLocalStorage', () {
    late FakeFlutterSecureStorage fakeStorage;
    late SecureLocalStorage storage;

    setUp(() {
      fakeStorage = FakeFlutterSecureStorage();
      storage = SecureLocalStorage(
        storage: fakeStorage,
        persistSessionKey: 'test_session_key',
      );
    });

    test('initial state has no access token', () async {
      expect(await storage.hasAccessToken(), isFalse);
      expect(await storage.accessToken(), isNull);
    });

    test('persisting session stores and retrieves token', () async {
      const sessionString = '{"access_token": "abc123xyz"}';
      await storage.persistSession(sessionString);

      expect(await storage.hasAccessToken(), isTrue);
      expect(await storage.accessToken(), equals(sessionString));
    });

    test('removing persisted session clears token', () async {
      await storage.persistSession('token');
      expect(await storage.hasAccessToken(), isTrue);

      await storage.removePersistedSession();
      expect(await storage.hasAccessToken(), isFalse);
      expect(await storage.accessToken(), isNull);
    });

    test('GotrueAsyncStorage methods work for PKCE', () async {
      expect(await storage.getItem(key: 'verifier'), isNull);

      await storage.setItem(key: 'verifier', value: 'pkce_code_123');
      expect(await storage.getItem(key: 'verifier'), equals('pkce_code_123'));

      await storage.removeItem(key: 'verifier');
      expect(await storage.getItem(key: 'verifier'), isNull);
    });
  });
}
