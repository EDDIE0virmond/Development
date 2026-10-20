import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_theme.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool blur;
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.blur = true,
  });
  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF132C40).withValues(alpha: .91),
            const Color(0xFF0B192B).withValues(alpha: .82),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .16)),
      ),
      child: child,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: blur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: content,
            )
          : content,
    );
  }
}

class PortalBackground extends StatelessWidget {
  final Widget child;
  const PortalBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const ColoredBox(color: AppTheme.navy),
      Positioned.fill(
        child: ExcludeSemantics(
          child: Image.asset(
            'assets/solar.png',
            fit: BoxFit.cover,
            alignment: const Alignment(.35, .2),
            cacheWidth: 1600,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
      const Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xD90B132B), Color(0x70132C40), Color(0xE60B132B)],
              stops: [0, .5, 1],
            ),
          ),
        ),
      ),
      child,
    ],
  );
}

class BrandMark extends StatelessWidget {
  final bool compact;
  const BrandMark({super.key, this.compact = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.lime,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.solar_power_outlined,
          color: AppTheme.navy,
          size: 25,
        ),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'rinnovare',
              style: TextStyle(
                fontSize: 23,
                letterSpacing: -.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!compact)
              const Text(
                'ENGENHARIA SOLAR',
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 2.5,
                  color: AppTheme.muted,
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
