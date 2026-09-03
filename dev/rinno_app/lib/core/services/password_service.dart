// lib/core/services/password_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forgot_password_request.dart';
import '../models/reset_password_request.dart';
import '../models/check_email_response.dart';
import '../constants/api_constants.dart';

class PasswordService {
  final http.Client _client = http.Client();

  // Verificar se e-mail existe
  Future<CheckEmailResponse> checkEmail(String email) async {
    try {
      final uri = Uri.parse('${ApiConstants.checkEmailEndpoint}?email=${Uri.encodeComponent(email)}');
      
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CheckEmailResponse.fromJson(data);
      } else {
        return CheckEmailResponse(
          exists: false,
          message: 'Erro ao verificar e-mail',
        );
      }
    } catch (e) {
      return CheckEmailResponse(
        exists: false,
        message: 'Erro de conexão: ${e.toString()}',
      );
    }
  }

  // Solicitar recuperação de senha
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final uri = Uri.parse(ApiConstants.forgotPasswordEndpoint);
      final request = ForgotPasswordRequest(email: email);
      
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Erro ao solicitar recuperação',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  // Verificar token de reset (via WordPress REST API)
  Future<Map<String, dynamic>> verifyResetToken(String token) async {
    try {
      final uri = Uri.parse('${ApiConstants.verifyResetTokenEndpoint}?token=${Uri.encodeComponent(token)}');
      
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'valid': false,
          'message': 'Erro ao verificar token',
        };
      }
    } catch (e) {
      return {
        'valid': false,
        'message': 'Erro de conexão: ${e.toString()}',
      };
    }
  }

  // Resetar senha (via WordPress REST API)
  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final uri = Uri.parse(ApiConstants.resetPasswordEndpoint);
      final request = ResetPasswordRequest(token: token, newPassword: newPassword);
      
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Erro ao resetar senha',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: ${e.toString()}',
      };
    }
  }
}