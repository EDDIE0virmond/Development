// lib/features/auth/presentation/widgets/auth_card.dart
import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  
  const AuthCard({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 480),
        child: Card(
          color: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: child,
          ),
        ),
      ),
    );
  }
}