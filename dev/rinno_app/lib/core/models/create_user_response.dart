// lib/core/models/create_user_response.dart
class CreateUserResponse {
  final bool success;
  final String message;
  final int? id;

  CreateUserResponse({
    required this.success,
    required this.message,
    this.id,
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      id: json['id'],
    );
  }
}