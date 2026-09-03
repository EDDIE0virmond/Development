// lib/core/services/user_management_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_with_items.dart';
import '../models/user_item.dart';
import '../constants/api_constants.dart';

class UserManagementService {
  final http.Client _client = http.Client();

  Future<List<UserWithItems>> getClientes() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/get_client.php');
      
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Converte cada item para o modelo, tratando os tipos
        return data.map((json) => UserWithItems.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar clientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }

  // Buscar itens de um cliente específico
  Future<List<UserItem>> getItemsByUser(int userId) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/get_user_items.php?user_id=$userId');
      
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserItem.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar itens: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }

  // Adicionar item ao usuário
  Future<bool> addItemToUser(int userId, String nome, String descricao, String tipo) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/add_user_item.php');
      
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'nome': nome,
          'descricao': descricao,
          'tipo': tipo,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Remover item
  Future<bool> removeItem(int itemId) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/remove_item.php');
      
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'item_id': itemId}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Atualizar item
  Future<bool> updateItem(int itemId, String nome, String descricao, String status) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/update_item.php');
      
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'item_id': itemId,
          'nome': nome,
          'descricao': descricao,
          'status': status,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}