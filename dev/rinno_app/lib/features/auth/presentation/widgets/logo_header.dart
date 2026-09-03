// lib/features/auth/presentation/widgets/logo_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showLogo;

  const LogoHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showLogo)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.eco,
              size: 45,
              color: Color(0xFF2E7D32),
            ),
          ),
        if (showLogo) const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}