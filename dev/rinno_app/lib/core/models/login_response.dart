// lib/core/models/login_response.dart
class LoginResponse {
  final bool success;
  final String? message;
  final String? role;
  final UserData? user;

  LoginResponse({
    required this.success,
    this.message,
    this.role,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    print('Parseando LoginResponse: $json');
    
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      role: json['role']?.toString(),
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
    );
  }
}

class UserData {
  final int id;
  final String nome;
  final String email;

  UserData({
    required this.id,
    required this.nome,
    required this.email,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    print('Parseando UserData: $json');
    
    // Converte id para int (pode vir como String do PHP)
    final int userId = json['id'] is String 
        ? int.parse(json['id'] as String) 
        : json['id'] as int;
    
    return UserData(
      id: userId,
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
      };
}