// lib/core/models/create_user_request.dart
class CreateUserRequest {
  final String nome;
  final String email;
  final String senha;
  final String role;
  final String criadoPor;

  CreateUserRequest({
    required this.nome,
    required this.email,
    required this.senha,
    required this.role,
    required this.criadoPor,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'email': email,
        'senha': senha,
        'role': role,
        'criado_por': criadoPor,
      };
}