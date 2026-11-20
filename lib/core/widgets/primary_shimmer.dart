import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shared primary-tinted sweep for skeleton screens.
///
/// [builder] gets the animation value [t] (0 to 1). Pass it to every
/// [PrimaryShimmerBlock] so all blocks sweep together.
class PrimaryShimmer extends StatefulWidget {
  final Widget Function(BuildContext context, double t) builder;

  const PrimaryShimmer({super.key, required this.builder});

  @override
  State<PrimaryShimmer> createState() => _PrimaryShimmerState();
}

class _PrimaryShimmerState extends State<PrimaryShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => widget.builder(context, _controller.value),
    );
  }
}

/// One block in a skeleton. [t] comes from [PrimaryShimmer].
class PrimaryShimmerBlock extends StatelessWidget {
  final double t;
  final double? width;
  final double height;
  final double radius;

  const PrimaryShimmerBlock({
    super.key,
    required this.t,
    required this.height,
    this.width,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final base = AppColors.primary.withValues(alpha: 0.06);
    final highlight = AppColors.primary.withValues(alpha: 0.26);

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + 2.0 * t, 0),
          end: Alignment(1.0 + 2.0 * t, 0),
          colors: [base, highlight, base],
          stops: const [0.3, 0.5, 0.7],
        ),
      ),
    );
  }
}
