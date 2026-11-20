import 'package:flutter/material.dart';

/// Fades the top edge of scrolling content into the background, so content
/// scrolling under the header softens instead of being cut off abruptly.
class TopFadeMask extends StatelessWidget {
  final Widget child;

  /// Fraction of the height over which the top edge fades in (0 to 1).
  /// Ignored when [fadeHeight] is set.
  final double fadeExtent;

  /// Fixed height in logical pixels over which the top edge fades in.
  /// Use this to keep the fade inside a known top gap.
  final double? fadeHeight;

  const TopFadeMask({
    super.key,
    required this.child,
    this.fadeExtent = 0.03,
    this.fadeHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          final stop = fadeHeight == null
              ? fadeExtent
              : (fadeHeight! / bounds.height).clamp(0.0, 1.0);
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Colors.transparent, Colors.white],
            stops: [0.0, stop],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: child,
      ),
    );
  }
}
