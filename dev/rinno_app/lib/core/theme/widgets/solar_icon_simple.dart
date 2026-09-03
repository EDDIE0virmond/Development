// lib/core/theme/widgets/solar_icon_simple.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SolarIconSimple extends StatelessWidget {
  final double size;
  final Color color;

  const SolarIconSimple({
    super.key,
    this.size = 40,
    this.color = const Color(0xFF2E7D32),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Icon(
        Icons.solar_power,
        size: size,
        color: color,
      ),
    );
  }
}