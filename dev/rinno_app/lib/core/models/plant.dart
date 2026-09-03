// lib/core/models/plant.dart
import 'package:flutter/material.dart';

class Plant {
  final int id;
  final int userId;
  final String nome;
  final String descricao;
  final String status;
  final double potencia;
  final String localizacao;
  final String? imagemUrl;
  final DateTime dataCriacao;
  
  // Novos campos com valores padrão
  final int quantidadePlacas;
  final String nomePlaca;
  final String tipoInversor;
  final String nomeInversor;
  final int quantidadeInversores;

  Plant({
    required this.id,
    required this.userId,
    required this.nome,
    required this.descricao,
    required this.status,
    required this.potencia,
    required this.localizacao,
    this.imagemUrl,
    required this.dataCriacao,
    this.quantidadePlacas = 0,
    this.nomePlaca = '',
    this.tipoInversor = 'micro',
    this.nomeInversor = '',
    this.quantidadeInversores = 0,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    final int plantId = json['id'] is String 
        ? int.parse(json['id'] as String) 
        : json['id'] as int;
    
    final int userId = json['user_id'] is String 
        ? int.parse(json['user_id'] as String) 
        : json['user_id'] as int;
    
    double potenciaValue = 0.0;
    if (json['potencia'] != null) {
      if (json['potencia'] is String) {
        potenciaValue = double.tryParse(json['potencia'] as String) ?? 0.0;
      } else if (json['potencia'] is int) {
        potenciaValue = (json['potencia'] as int).toDouble();
      } else if (json['potencia'] is double) {
        potenciaValue = json['potencia'] as double;
      }
    }
    
    DateTime? dataCriacao;
    if (json['data_criacao'] != null) {
      try {
        dataCriacao = DateTime.parse(json['data_criacao']);
      } catch (e) {
        dataCriacao = DateTime.now();
      }
    } else {
      dataCriacao = DateTime.now();
    }
    
    // Tratamento seguro para os novos campos
    int quantidadePlacas = 0;
    if (json['quantidade_placas'] != null) {
      if (json['quantidade_placas'] is String) {
        quantidadePlacas = int.tryParse(json['quantidade_placas'] as String) ?? 0;
      } else if (json['quantidade_placas'] is int) {
        quantidadePlacas = json['quantidade_placas'] as int;
      }
    }
    
    String nomePlaca = '';
    if (json['nome_placa'] != null) {
      nomePlaca = json['nome_placa'].toString();
    }
    
    String tipoInversor = 'micro';
    if (json['tipo_inversor'] != null) {
      tipoInversor = json['tipo_inversor'].toString();
    }
    
    String nomeInversor = '';
    if (json['nome_inversor'] != null) {
      nomeInversor = json['nome_inversor'].toString();
    }
    
    int quantidadeInversores = 0;
    if (json['quantidade_inversores'] != null) {
      if (json['quantidade_inversores'] is String) {
        quantidadeInversores = int.tryParse(json['quantidade_inversores'] as String) ?? 0;
      } else if (json['quantidade_inversores'] is int) {
        quantidadeInversores = json['quantidade_inversores'] as int;
      }
    }
    
    return Plant(
      id: plantId,
      userId: userId,
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      status: json['status'] ?? 'ativo',
      potencia: potenciaValue,
      localizacao: json['localizacao'] ?? '',
      imagemUrl: json['imagem_url'],
      dataCriacao: dataCriacao,
      quantidadePlacas: quantidadePlacas,
      nomePlaca: nomePlaca,
      tipoInversor: tipoInversor,
      nomeInversor: nomeInversor,
      quantidadeInversores: quantidadeInversores,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'nome': nome,
        'descricao': descricao,
        'status': status,
        'potencia': potencia,
        'localizacao': localizacao,
        'imagem_url': imagemUrl,
        'data_criacao': dataCriacao.toIso8601String(),
        'quantidade_placas': quantidadePlacas,
        'nome_placa': nomePlaca,
        'tipo_inversor': tipoInversor,
        'nome_inversor': nomeInversor,
        'quantidade_inversores': quantidadeInversores,
      };

  Color get statusColor {
    switch (status) {
      case 'ativo':
        return Colors.green;
      case 'manutencao':
        return Colors.orange;
      case 'inativo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'ativo':
        return 'Ativo';
      case 'manutencao':
        return 'Em Manutenção';
      case 'inativo':
        return 'Inativo';
      default:
        return status;
    }
  }
}