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
            const Color(0xFF345568).withValues(alpha: .90),
            const Color(0xFF183247).withValues(alpha: .88),
            const Color(0xFF0B192B).withValues(alpha: .82),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .30)),
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
  Widget build(BuildContext context) => ImageEntrance(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 210 : 260),
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Image.asset(
                  'assets/rinnovare-wordmark.webp',
                  fit: BoxFit.contain,
                  color: const Color(0x99000000),
                ),
              ),
            ),
          ),
          ColorFiltered(
            // Light lettering while retaining the green brand accents and alpha.
            colorFilter: const ColorFilter.matrix([
              1,
              -1,
              0,
              0,
              255,
              0,
              0,
              0,
              0,
              255,
              0,
              -1,
              1,
              0,
              255,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: Image.asset(
              'assets/rinnovare-wordmark.webp',
              fit: BoxFit.contain,
              semanticLabel: 'Rinnovare Solar Engenharia',
            ),
          ),
        ],
      ),
    ),
  );
}

class ImageEntrance extends StatelessWidget {
  final Widget child;
  const ImageEntrance({super.key, required this.child});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 650),
    curve: Curves.easeOutCubic,
    child: child,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.scale(scale: .94 + .06 * value, child: child),
    ),
  );
}

class PortalLoading extends StatelessWidget {
  const PortalLoading({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ImageEntrance(
              child: Image.asset(
                'assets/rinnovare-symbol.png',
                width: 200,
                height: 200,
                semanticLabel: 'Rinnovare',
              ),
            ),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: MediaQuery.disableAnimationsOf(context) ? .5 : null,
                color: AppTheme.lime,
                backgroundColor: Colors.white24,
                semanticsLabel: 'Carregando aplicativo',
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Carregando sua energia…',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}
