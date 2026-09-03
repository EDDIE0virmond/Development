// lib/core/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/create_user_request.dart';
import '../models/create_user_response.dart';
import '../models/simple_user.dart';
import '../constants/api_constants.dart';

class UserService {
  final http.Client _client = http.Client();

  // Criar um novo usuário
  Future<CreateUserResponse> createUser(CreateUserRequest request) async {
    try {
      final uri = Uri.parse(ApiConstants.registerEndpoint);
      
      final body = jsonEncode(request.toJson());
      
      print('=== CRIANDO USUÁRIO ===');
      print('URL: $uri');
      print('Body: $body');
      print('========================');
      
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

      print('=== RESPOSTA CRIAÇÃO ===');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('=========================');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CreateUserResponse.fromJson(data);
      } else {
        return CreateUserResponse(
          success: false,
          message: 'Erro no servidor: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('=== ERRO NA CRIAÇÃO ===');
      print('Erro: $e');
      print('========================');
      return CreateUserResponse(
        success: false,
        message: 'Erro de conexão: ${e.toString()}',
      );
    }
  }

  // Buscar todos os usuários (para Admin/Master)
  Future<List<SimpleUser>> getAllUsers() async {
    try {
      final uri = Uri.parse(ApiConstants.getAllUsersEndpoint);
      
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SimpleUser.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar usuários: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }

  // Buscar usuários por role (ex: apenas clientes)
  Future<List<SimpleUser>> getUsersByRole(String role) async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.where((u) => u.role == role).toList();
    } catch (e) {
      throw Exception('Erro ao carregar usuários por role: ${e.toString()}');
    }
  }

  // Buscar um usuário específico por ID
  Future<SimpleUser?> getUserById(int userId) async {
    try {
      final allUsers = await getAllUsers();
      try {
        return allUsers.firstWhere((u) => u.id == userId);
      } catch (e) {
        return null;
      }
    } catch (e) {
      throw Exception('Erro ao buscar usuário: ${e.toString()}');
    }
  }

  // Buscar usuários por nome (busca parcial)
  Future<List<SimpleUser>> searchUsers(String query) async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.where((u) => 
        u.nome.toLowerCase().contains(query.toLowerCase()) ||
        u.email.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários: ${e.toString()}');
    }
  }
  Future<List<SimpleUser>> getClientes() async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.where((u) => u.role == 'cliente').toList();
    } catch (e) {
      throw Exception('Erro ao carregar clientes: ${e.toString()}');
    }
  }
}