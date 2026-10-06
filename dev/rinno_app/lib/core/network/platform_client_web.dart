import 'package:http/browser_client.dart';
import 'package:http/http.dart';
import 'session_store.dart';

Client createClient() => BrowserClient()..withCredentials = true;
SessionStore createSessionStore() => _CookieSession();

class _CookieSession implements SessionStore {
  @override
  bool get usesCookies => true;
  @override
  Future<String?> readRefreshToken() async => null;
  @override
  Future<void> writeRefreshToken(String token) async {}
  @override
  Future<void> clear() async {}
}
