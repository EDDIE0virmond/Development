// lib/core/models/plant_status.dart
import 'package:flutter/material.dart';

class PlantStatus {
  final String id;
  final String nome;
  final String descricao;
  final String categoria;
  final bool isCompleted;
  final DateTime? dataConclusao;
  final String? observacao;

  PlantStatus({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    this.isCompleted = false,
    this.dataConclusao,
    this.observacao,
  });

  factory PlantStatus.fromJson(Map<String, dynamic> json) {
    // Converter is_completed para bool (pode vir como int ou string)
    bool completed = false;
    if (json['is_completed'] != null) {
      if (json['is_completed'] is int) {
        completed = json['is_completed'] == 1;
      } else if (json['is_completed'] is String) {
        completed = json['is_completed'] == '1' || json['is_completed'] == 'true';
      } else if (json['is_completed'] is bool) {
        completed = json['is_completed'] as bool;
      }
    }
    
    // Converter data
    DateTime? dataConclusao;
    if (json['data_conclusao'] != null && json['data_conclusao'] != '') {
      try {
        dataConclusao = DateTime.parse(json['data_conclusao']);
      } catch (e) {
        dataConclusao = null;
      }
    }
    
    return PlantStatus(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      categoria: json['categoria'] ?? 'projeto',
      isCompleted: completed,
      dataConclusao: dataConclusao,
      observacao: json['observacao'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'categoria': categoria,
        'is_completed': isCompleted ? 1 : 0,
        'data_conclusao': dataConclusao?.toIso8601String(),
        'observacao': observacao,
      };

  Color get statusColor {
    if (isCompleted) return Colors.green;
    return Colors.orange;
  }

  String get statusLabel {
    if (isCompleted) return 'Concluído';
    return 'Pendente';
  }

  IconData get statusIcon {
    if (isCompleted) return Icons.check_circle;
    return Icons.pending;
  }
}