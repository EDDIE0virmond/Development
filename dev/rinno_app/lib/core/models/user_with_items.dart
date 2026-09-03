// lib/core/models/user_with_items.dart
import 'user_item.dart';

class UserWithItems {
  final int id;
  final String nome;
  final String email;
  final String role;
  final List<UserItem> items;

  UserWithItems({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
    required this.items,
  });

  factory UserWithItems.fromJson(Map<String, dynamic> json) {
    // Converte id para int (pode vir como String do PHP)
    final int userId = json['id'] is String 
        ? int.parse(json['id'] as String) 
        : json['id'] as int;
    
    final itemsList = json['items'] as List? ?? [];
    return UserWithItems(
      id: userId,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'cliente',
      items: itemsList.map((item) => UserItem.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'role': role,
        'items': items.map((e) => e.toJson()).toList(),
      };
}