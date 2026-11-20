import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

/// Circular progress ring: a light track with a rounded arc of [fraction] of a
/// full turn, starting at the top. [child] is shown in the centre.
class ProgressRing extends StatelessWidget {
  final double fraction;
  final Color color;
  final double size;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.fraction,
    required this.color,
    required this.size,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.r,
      height: size.r,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: fraction.clamp(0.0, 1.0),
          color: color,
          strokeWidth: 6.r,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  static const Color _trackColor = Color(0xFFEBEBEB);

  final double fraction;
  final Color color;
  final double strokeWidth;

  const _RingPainter({
    required this.fraction,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final inset = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    canvas.drawOval(
      inset,
      Paint()
        ..color = _trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (fraction <= 0) return;

    canvas.drawArc(
      inset,
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
