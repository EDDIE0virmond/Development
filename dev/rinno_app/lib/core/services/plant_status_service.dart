// lib/core/services/plant_status_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plant_status.dart';
import '../constants/api_constants.dart';

class PlantStatusService {
  final http.Client _client = http.Client();

  // Buscar status de uma planta
  Future<List<PlantStatus>> getPlantStatus(int plantId) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/get_plant_status.php?plant_id=$plantId');
      
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Tempo limite excedido'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PlantStatus.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar status');
      }
    } catch (e) {
      throw Exception('Erro de conexão: ${e.toString()}');
    }
  }

  // Atualizar status
  Future<bool> updatePlantStatus(String statusId, bool isCompleted, {String? observacao}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/update_plant_status.php');
      
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status_id': statusId,
          'is_completed': isCompleted ? 1 : 0,
          'observacao': observacao ?? '',
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

  // Buscar status por categoria
  Future<List<PlantStatus>> getPlantStatusByCategoria(int plantId, String categoria) async {
    try {
      final allStatus = await getPlantStatus(plantId);
      return allStatus.where((s) => s.categoria == categoria).toList();
    } catch (e) {
      throw Exception('Erro ao carregar status por categoria');
    }
  }

  // Calcular progresso por categoria
  Future<double> getProgressByCategoria(int plantId, String categoria) async {
    try {
      final statusList = await getPlantStatusByCategoria(plantId, categoria);
      if (statusList.isEmpty) return 0.0;
      final completed = statusList.where((s) => s.isCompleted).length;
      return completed / statusList.length;
    } catch (e) {
      return 0.0;
    }
  }

  // Calcular progresso total da planta
  Future<double> getTotalProgress(int plantId) async {
    try {
      final statusList = await getPlantStatus(plantId);
      if (statusList.isEmpty) return 0.0;
      final completed = statusList.where((s) => s.isCompleted).length;
      return completed / statusList.length;
    } catch (e) {
      return 0.0;
    }
  }
}