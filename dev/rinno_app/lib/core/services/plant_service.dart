// lib/core/services/plant_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plant.dart';
import '../constants/api_constants.dart';

class PlantService {
  final http.Client _client = http.Client();

  // Buscar todas as plantas de um usuário específico
  Future<List<Plant>> getPlantsByUser(int userId) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/get_user_plants.php?user_id=$userId');
      
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Plant.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar plantas');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }

  // Buscar TODAS as plantas (para Admin/Master)
  Future<List<Plant>> getAllPlants() async {
    try {
      final uri = Uri.parse(ApiConstants.getAllPlantsEndpoint);
      
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Plant.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar todas as plantas');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }

  // Buscar uma planta específica
  Future<Plant> getPlantById(int plantId) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/get_plant.php?plant_id=$plantId');
      
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Plant.fromJson(data);
      } else {
        throw Exception('Erro ao carregar planta');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }

  // Criar uma nova planta com todos os campos
  Future<bool> createPlant(
    int userId,
    String nome,
    String descricao,
    double potencia,
    String localizacao, [
    int quantidadePlacas = 0,
    String nomePlaca = '',
    String tipoInversor = 'micro',
    String nomeInversor = '',
    int quantidadeInversores = 0,
  ]) async {
    try {
      final uri = Uri.parse(ApiConstants.createPlantEndpoint);
      
      final body = jsonEncode({
        'user_id': userId,
        'nome': nome,
        'descricao': descricao,
        'potencia': potencia,
        'localizacao': localizacao,
        'quantidade_placas': quantidadePlacas,
        'nome_placa': nomePlaca,
        'tipo_inversor': tipoInversor,
        'nome_inversor': nomeInversor,
        'quantidade_inversores': quantidadeInversores,
      });
      
      print('=== CRIANDO PLANTA ===');
      print('Body: $body');
      print('========================');
      
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      print('=== RESPOSTA ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('========================');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Erro ao criar planta: $e');
      return false;
    }
  }

  // Atualizar planta
  Future<bool> updatePlant(
    int plantId,
    String nome,
    String descricao,
    double potencia,
    String localizacao,
    String status,
    int quantidadePlacas,
    String nomePlaca,
    String tipoInversor,
    String nomeInversor,
    int quantidadeInversores,
  ) async {
    try {
      final uri = Uri.parse(ApiConstants.updatePlantEndpoint);
      
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'plant_id': plantId,
          'nome': nome,
          'descricao': descricao,
          'potencia': potencia,
          'localizacao': localizacao,
          'status': status,
          'quantidade_placas': quantidadePlacas,
          'nome_placa': nomePlaca,
          'tipo_inversor': tipoInversor,
          'nome_inversor': nomeInversor,
          'quantidade_inversores': quantidadeInversores,
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

  // Remover planta
  Future<bool> deletePlant(int plantId) async {
    try {
      final uri = Uri.parse(ApiConstants.deletePlantEndpoint);
      
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'plant_id': plantId}),
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