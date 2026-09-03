// lib/core/models/user_item.dart
class UserItem {
  final int id;
  final int userId;
  final String nome;
  final String descricao;
  final String tipo;
  final DateTime dataCriacao;
  final String? arquivoUrl;
  final String status;

  UserItem({
    required this.id,
    required this.userId,
    required this.nome,
    required this.descricao,
    required this.tipo,
    required this.dataCriacao,
    this.arquivoUrl,
    required this.status,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    // Converte ids para int (podem vir como String do PHP)
    final int itemId = json['id'] is String 
        ? int.parse(json['id'] as String) 
        : json['id'] as int;
    
    final int itemUserId = json['user_id'] is String 
        ? int.parse(json['user_id'] as String) 
        : json['user_id'] as int;
    
    return UserItem(
      id: itemId,
      userId: itemUserId,
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      tipo: json['tipo'] ?? 'produto',
      dataCriacao: json['data_criacao'] != null 
          ? DateTime.parse(json['data_criacao']) 
          : DateTime.now(),
      arquivoUrl: json['arquivo_url'],
      status: json['status'] ?? 'ativo',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'nome': nome,
        'descricao': descricao,
        'tipo': tipo,
        'data_criacao': dataCriacao.toIso8601String(),
        'arquivo_url': arquivoUrl,
        'status': status,
      };
}