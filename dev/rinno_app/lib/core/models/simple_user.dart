// lib/core/models/simple_user.dart
class SimpleUser {
  final int id;
  final String nome;
  final String email;
  final String role;

  SimpleUser({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
  });

  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    final int userId = json['id'] is String 
        ? int.parse(json['id'] as String) 
        : json['id'] as int;
    
    return SimpleUser(
      id: userId,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'cliente',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'role': role,
      };
}