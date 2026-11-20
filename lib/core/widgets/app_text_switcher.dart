import 'package:flutter/material.dart';

/// A premium animated text switcher that provides a smooth, elegant
/// cross-fade and gentle scale-in transition when its child or key changes.
class AppTextSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double beginScale;
  final Alignment alignment;

  const AppTextSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 280),
    this.beginScale = 0.92,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: alignment,
          children: <Widget>[...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: beginScale, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
