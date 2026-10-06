import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'session_store.dart';

Client createClient() => Client();
SessionStore createSessionStore() => _SecureSession();

class _SecureSession implements SessionStore {
  final _storage = Platform.isMacOS
      ? const FlutterSecureStorage(
          mOptions: MacOsOptions(usesDataProtectionKeychain: false),
        )
      : const FlutterSecureStorage();
  static const _key = 'rinnovare.client.refresh.v1';
  @override
  bool get usesCookies => false;
  @override
  Future<String?> readRefreshToken() => _storage.read(key: _key);
  @override
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _key, value: token);
  @override
  Future<void> clear() => _storage.delete(key: _key);
}
