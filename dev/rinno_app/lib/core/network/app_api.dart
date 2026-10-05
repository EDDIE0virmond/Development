import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/installation.dart';
import 'platform_client.dart' as platform;
import 'session_store.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  const ApiException(this.status, this.message);
  @override
  String toString() => message;
}

class ClientIdentity {
  final String id, nome, email;
  ClientIdentity.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      nome = json['nome'] as String,
      email = json['email'] as String;
}

class AppApi extends ChangeNotifier {
  final http.Client _client;
  final SessionStore _store;
  final String baseUrl;
  ClientIdentity? user;
  String? _access;
  int _epoch = 0;
  bool _disposed = false;
  Future<void>? _refreshing;
  Future<void> _storageWork = Future.value();
  AppApi({
    http.Client? client,
    SessionStore? store,
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.rinnovare.com.br/api/v1/app',
    ),
  }) : _client = client ?? platform.createClient(),
       _store = store ?? platform.createSessionStore();

  void _check(int epoch) {
    if (_disposed || epoch != _epoch) {
      throw const ApiException(409, 'A sessão mudou.');
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _persist(String? token, int epoch) {
    final work = _storageWork.catchError((_) {}).then((_) async {
      _check(epoch);
      if (token == null) {
        await _store.clear();
      } else {
        await _store.writeRefreshToken(token);
      }
    });
    _storageWork = work;
    return work;
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    bool retry = true,
    int? generation,
  }) async {
    final epoch = generation ?? _epoch;
    _check(epoch);
    final token = _access;
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = {
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (!_store.usesCookies && path.startsWith('/auth/'))
          'X-App-Transport': 'native',
      };
      final response =
          await (method == 'GET'
                  ? _client.get(uri, headers: headers)
                  : _client.post(
                      uri,
                      headers: headers,
                      body: jsonEncode(body ?? {}),
                    ))
              .timeout(const Duration(seconds: 30));
      _check(epoch);
      if (response.statusCode == 401 && authenticated && retry) {
        if (token == _access) await refresh();
        _check(epoch);
        return await _send(
          method,
          path,
          body: body,
          authenticated: true,
          retry: false,
          generation: epoch,
        );
      }
      if (authenticated && [401, 403].contains(response.statusCode)) {
        await _expire(epoch);
      }
      if (response.statusCode == 204) return {};
      Map<String, dynamic> value;
      try {
        value = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw const ApiException(
          503,
          'Resposta inválida do serviço. Tente novamente.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          response.statusCode,
          value['error'] as String? ?? 'Não foi possível concluir.',
        );
      }
      return value;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(503, 'A conexão demorou. Tente novamente.');
    } on http.ClientException {
      throw const ApiException(
        503,
        'Sem conexão com o serviço. Verifique sua internet.',
      );
    }
  }

  Future<void> _expire(int epoch) async {
    _check(epoch);
    _epoch++;
    _access = null;
    user = null;
    _refreshing = null;
    _notify();
    await _persist(null, _epoch);
  }

  Future<void> _adopt(Map<String, dynamic> data, int epoch) async {
    _check(epoch);
    try {
      final identity = ClientIdentity.fromJson(
        data['user'] as Map<String, dynamic>,
      );
      final access = data['accessToken'] as String;
      if (!_store.usesCookies) {
        await _persist(data['refreshToken'] as String, epoch);
      }
      _check(epoch);
      _access = access;
      user = identity;
      _notify();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        503,
        'Não foi possível proteger a sessão neste dispositivo.',
      );
    }
  }

  Future<void> login(String email, String password) async {
    final epoch = ++_epoch;
    _refreshing = null;
    _access = null;
    user = null;
    final result = await _send(
      'POST',
      '/auth/login',
      body: {'email': email.trim(), 'password': password},
      generation: epoch,
    );
    await _adopt(result, epoch);
  }

  Future<void> refresh() {
    if (_refreshing != null) return _refreshing!;
    final epoch = _epoch;
    final work = () async {
      try {
        final token = await _store.readRefreshToken();
        _check(epoch);
        if (!_store.usesCookies && token == null) {
          throw const ApiException(401, 'Entre para continuar.');
        }
        final result = await _send(
          'POST',
          '/auth/refresh',
          body: {'refreshToken': ?token},
          generation: epoch,
        );
        await _adopt(result, epoch);
      } on ApiException catch (e) {
        if (epoch == _epoch && [401, 403].contains(e.status)) {
          await _expire(epoch);
        }
        rethrow;
      }
    }();
    _refreshing = work;
    work.then(
      (_) {
        if (epoch == _epoch) _refreshing = null;
      },
      onError: (Object e, StackTrace s) {
        if (epoch == _epoch) _refreshing = null;
      },
    );
    return work;
  }

  Future<void> restore() async {
    try {
      await refresh();
    } on ApiException catch (e) {
      if (![401, 403].contains(e.status)) rethrow;
    }
  }

  Future<void> logout() async {
    final epoch = ++_epoch;
    final access = _access;
    _refreshing = null;
    _access = null;
    user = null;
    _notify();
    await _persist(null, epoch);
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/logout'),
            headers: {
              'Content-Type': 'application/json',
              if (access != null) 'Authorization': 'Bearer $access',
              if (!_store.usesCookies) 'X-App-Transport': 'native',
            },
            body: '{}',
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode >= 400) {
        throw const ApiException(
          503,
          'Você saiu deste dispositivo. Não foi possível confirmar a saída no servidor.',
        );
      }
    } catch (_) {
      throw const ApiException(
        503,
        'Você saiu deste dispositivo. Não foi possível confirmar a saída no servidor.',
      );
    }
  }

  Future<void> recover(String email) async {
    await _send('POST', '/auth/recover', body: {'email': email.trim()});
  }

  Future<void> reset(String tokenHash, String password) async {
    await _send(
      'POST',
      '/auth/reset',
      body: {'tokenHash': tokenHash, 'password': password},
    );
  }

  Future<InstallationPage> installations({int offset = 0}) async {
    try {
      return InstallationPage.fromJson(
        await _send(
          'GET',
          '/installations?limit=20&offset=$offset',
          authenticated: true,
        ),
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(503, 'Não foi possível ler suas instalações.');
    }
  }

  Future<Installation> installation(String id) async => Installation.fromJson(
    await _send(
      'GET',
      '/installations/${Uri.encodeComponent(id)}',
      authenticated: true,
    ),
  );
  Future<List<InstallationStage>> stages(String id) async =>
      ((await _send(
                'GET',
                '/installations/${Uri.encodeComponent(id)}/stages',
                authenticated: true,
              ))['items']
              as List)
          .map((v) => InstallationStage.fromJson(v))
          .toList();
  Future<List<ClientDocument>> documents(String id) async =>
      ((await _send(
                'GET',
                '/installations/${Uri.encodeComponent(id)}/documents',
                authenticated: true,
              ))['items']
              as List)
          .map((v) => ClientDocument.fromJson(v))
          .toList();
  Future<Uri> download(String id) async {
    final result = await _send(
      'GET',
      '/documents/${Uri.encodeComponent(id)}/download',
      authenticated: true,
    );
    final uri = Uri.parse(result['url'] as String);
    if (uri.scheme != 'https' || uri.userInfo.isNotEmpty) {
      throw const ApiException(503, 'Link de documento inválido.');
    }
    return uri;
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    _client.close();
    super.dispose();
  }
}
