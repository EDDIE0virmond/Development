// lib/core/models/user_model.dart
class UserModel {
  final int id;
  final String nome;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Converte id para int (pode vir como String do PHP)
    final int userId = json['id'] is String 
        ? int.parse(json['id'] as String) 
        : json['id'] as int;
    
    return UserModel(
      id: userId,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'comum',
    );
  }
  
  bool get isAdmin => role == 'admin';
  bool get isMaster => role == 'master';
  bool get isComum => role == 'comum';
  bool get canCreateUsers => isAdmin || isMaster;
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'role': role,
      };
}