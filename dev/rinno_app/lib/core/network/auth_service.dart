// lib/core/network/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../constants/api_constants.dart';

class AuthService {
  final http.Client _client = http.Client();

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final uri = Uri.parse(ApiConstants.loginEndpoint);
      
      final body = jsonEncode(request.toJson());
      
      print('=== ENVIANDO REQUISIÇÃO ===');
      print('URL: $uri');
      print('Body: $body');
      print('===========================');
      
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      print('=== RESPOSTA RECEBIDA ===');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('=========================');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        return LoginResponse(
          success: false,
          message: 'Erro no servidor: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('=== ERRO NA REQUISIÇÃO ===');
      print('Erro: $e');
      print('==========================');
      return LoginResponse(
        success: false,
        message: 'Erro de conexão: ${e.toString()}',
      );
    }
  }
}