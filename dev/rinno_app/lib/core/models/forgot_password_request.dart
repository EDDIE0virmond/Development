// lib/core/models/forgot_password_request.dart
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {
        'email': email,
      };
}