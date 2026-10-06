import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rinno_app/core/network/app_api.dart';
import 'package:rinno_app/core/network/session_store.dart';

class MemoryStore implements SessionStore {
  String? token;
  @override
  bool get usesCookies => false;
  @override
  Future<String?> readRefreshToken() async => token;
  @override
  Future<void> writeRefreshToken(String value) async {
    token = value;
  }

  @override
  Future<void> clear() async {
    token = null;
  }
}

Map<String, dynamic> session(String token) => {
  'user': {
    'id': '10000000-0000-4000-8000-000000000001',
    'nome': 'Ana',
    'email': 'ana@example.test',
  },
  'accessToken': token,
  'refreshToken': 'refresh',
  'expiresAt': 9999999999,
};
http.Response jsonResponse(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

void main() {
  test(
    'concurrent unauthorized requests share refresh and preserve UUIDs',
    () async {
      var refreshes = 0;
      final store = MemoryStore();
      final api = AppApi(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/login')) {
            return jsonResponse(session('old'));
          }
          if (request.url.path.endsWith('/refresh')) {
            refreshes++;
            await Future<void>.delayed(const Duration(milliseconds: 10));
            return jsonResponse(session('new'));
          }
          if (request.headers['authorization'] == 'Bearer old') {
            return jsonResponse({'error': 'Expired'}, 401);
          }
          return jsonResponse({
            'items': [
              {
                'id': '20000000-0000-4000-8000-000000000001',
                'codigo': 'SOL-01',
                'status': 'instalacao',
                'potenciaKwp': 6.5,
              },
            ],
            'hasMore': false,
          });
        }),
        store: store,
      );
      await api.login('ana@example.test', 'password');
      final result = await Future.wait([
        api.installations(),
        api.installations(),
      ]);
      expect(refreshes, 1);
      expect(
        result.first.items.single.id,
        '20000000-0000-4000-8000-000000000001',
      );
      expect(result.first.items.single.potenciaKwp, 6.5);
      api.dispose();
    },
  );
  test(
    'logout discards late login and never restores a stale refresh token',
    () async {
      final response = Completer<http.Response>();
      final store = MemoryStore();
      final api = AppApi(
        client: MockClient(
          (r) async => r.url.path.endsWith('/login')
              ? response.future
              : http.Response('', 204),
        ),
        store: store,
      );
      final login = api.login('ana@example.test', 'password');
      final assertion = expectLater(login, throwsA(isA<ApiException>()));
      await api.logout();
      response.complete(jsonResponse(session('late')));
      await assertion;
      expect(api.user, isNull);
      expect(store.token, isNull);
      api.dispose();
    },
  );
  test(
    'network and invalid JSON do not become empty successful installations',
    () async {
      final api = AppApi(
        client: MockClient(
          (r) async => r.url.path.endsWith('/login')
              ? jsonResponse(session('token'))
              : http.Response('<html>bad gateway</html>', 200),
        ),
        store: MemoryStore(),
      );
      await api.login('ana@example.test', 'password');
      await expectLater(api.installations(), throwsA(isA<ApiException>()));
      api.dispose();
    },
  );
  test('revoked binding clears identity and persisted session', () async {
    final store = MemoryStore();
    final api = AppApi(
      client: MockClient(
        (r) async => r.url.path.endsWith('/login')
            ? jsonResponse(session('token'))
            : jsonResponse({'error': 'Acesso revogado'}, 403),
      ),
      store: store,
    );
    await api.login('ana@example.test', 'password');
    await expectLater(api.installations(), throwsA(isA<ApiException>()));
    expect(api.user, isNull);
    expect(store.token, isNull);
    api.dispose();
  });
}
