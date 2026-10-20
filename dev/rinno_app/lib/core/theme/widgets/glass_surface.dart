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
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(maxWidth: compact ? 210 : 260),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Image.asset(
      'assets/rinnovare-wordmark.webp',
      fit: BoxFit.contain,
      semanticLabel: 'Rinnovare Solar Engenharia',
    ),
  );
}
