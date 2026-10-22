import 'package:flutter/material.dart';
import '../../core/theme/widgets/glass_surface.dart';

/// Expands the selected card into an opaque, readable page, collapsing toward its back button on close.
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
  final backKey = GlobalKey();
  final mobile = size.width < 600;
  final reducedMotion = MediaQuery.disableAnimationsOf(context);
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      settings: RouteSettings(name: '/details/$title'),
      transitionDuration: Duration(milliseconds: reducedMotion ? 0 : 420),
      reverseTransitionDuration: Duration(
        milliseconds: reducedMotion ? 0 : 300,
      ),
      pageBuilder: (context, animation, secondaryAnimation) => PortalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: mobile ? 16 : 24,
                    vertical: mobile ? 8 : 16,
                  ),
                  child: SizedBox(
                    height: mobile ? 36 : 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: mobile ? 170 : 210,
                        child: const BrandMark(compact: true),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    mobile ? 16 : 24,
                    mobile ? 4 : 49,
                    mobile ? 16 : 24,
                    mobile ? 8 : 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            key: backKey,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            tooltip: 'Voltar para a tela principal',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: mobile
                                  ? Theme.of(context).textTheme.titleLarge
                                  : Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: builder(context),
                    ),
                  ),
                ),
              ],
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
            final returning = animation.status == AnimationStatus.reverse;
            final backBox = backKey.currentContext?.findRenderObject();
            final target = returning && backBox is RenderBox && backBox.hasSize
                ? backBox.localToGlobal(Offset.zero) & backBox.size
                : card;
            final rect = Rect.lerp(target, bounds, progress.value)!;
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
