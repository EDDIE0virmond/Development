// lib/core/theme/widgets/animated_list_item.dart
import 'package:flutter/material.dart';

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1.0),
          curve: Interval(
            index * 0.05,
            1.0,
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1.0),
            curve: Interval(
              index * 0.05,
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}