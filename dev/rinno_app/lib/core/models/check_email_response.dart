// lib/core/models/check_email_response.dart
class CheckEmailResponse {
  final bool exists;
  final String? message;

  CheckEmailResponse({
    required this.exists,
    this.message,
  });

  factory CheckEmailResponse.fromJson(Map<String, dynamic> json) {
    return CheckEmailResponse(
      exists: json['exists'] ?? false,
      message: json['message'],
    );
  }
}