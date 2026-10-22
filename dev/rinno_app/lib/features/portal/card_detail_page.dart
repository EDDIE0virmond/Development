import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Expands the selected card into an opaque, readable page, reversing on back.
Future<void> openCardPage(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  BuildContext? origin,
}) {
  final box = (origin ?? context).findRenderObject();
  final size = MediaQuery.sizeOf(context);
  final bounds = Offset.zero & size;
  final card = box is RenderBox && box.hasSize
      ? box.localToGlobal(Offset.zero) & box.size
      : bounds;
  final reducedMotion = MediaQuery.disableAnimationsOf(context);
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      settings: RouteSettings(name: '/details/$title'),
      transitionDuration: Duration(milliseconds: reducedMotion ? 0 : 420),
      reverseTransitionDuration: Duration(
        milliseconds: reducedMotion ? 0 : 300,
      ),
      pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
        backgroundColor: AppTheme.navy,
        appBar: AppBar(
          backgroundColor: AppTheme.navy,
          surfaceTintColor: Colors.transparent,
          leading: BackButton(onPressed: () => Navigator.pop(context)),
          title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: builder(context),
            ),
          ),
        ),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final progress = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        return AnimatedBuilder(
          animation: progress,
          child: child,
          builder: (context, child) {
            final rect = Rect.lerp(card, bounds, progress.value)!;
            return ClipPath(
              clipper: _PageReveal(rect, 26 * (1 - progress.value)),
              child: FadeTransition(opacity: progress, child: child),
            );
          },
        );
      },
    ),
  );
}

class _PageReveal extends CustomClipper<Path> {
  final Rect rect;
  final double radius;
  const _PageReveal(this.rect, this.radius);
  @override
  Path getClip(Size size) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
  @override
  bool shouldReclip(_PageReveal old) =>
      old.rect != rect || old.radius != radius;
}
