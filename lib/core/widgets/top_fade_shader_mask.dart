import 'package:flutter/material.dart';

/// A widget that applies a smooth gradient fade-out ShaderMask at the top
/// of its scrolling child, making the scroll transition smooth instead of
/// an abrupt hard cut.
class TopFadeShaderMask extends StatelessWidget {
  final Widget child;
  final double fadeHeight;

  const TopFadeShaderMask({
    super.key,
    required this.child,
    this.fadeHeight = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        final double stop = bounds.height > 0
            ? (fadeHeight / bounds.height).clamp(0.001, 1.0)
            : 0.001;
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Colors.transparent,
            Colors.black,
          ],
          stops: [0.0, stop],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}

