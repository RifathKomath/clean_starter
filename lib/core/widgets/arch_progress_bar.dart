import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

/// Segmented Arch Gauge displaying the completion percentage with
/// animated linear gradient (#D987F3 to #703A81) across filled radial ticks matching Figma:
/// - width: 12.600202606736547
/// - height: 32.20051968011981
/// - border-radius: 4.2px
/// - total ticks: 20
/// - smoothly animates the gauge progress and percentage text counter
class ArchProgressBar extends StatefulWidget {
  final double percentage;
  final int totalTicks;
  final double width;
  final double height;
  final Duration duration;
  final Curve curve;
  final bool animate;
  final VoidCallback? onCompleted;

  const ArchProgressBar({
    super.key,
    this.percentage = 0.8,
    this.totalTicks = 20,
    this.width = 270,
    this.height = 160,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
    this.animate = true,
    this.onCompleted,
  });

  @override
  State<ArchProgressBar> createState() => _ArchProgressBarState();
}

class _ArchProgressBarState extends State<ArchProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call();
      }
    });

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onCompleted?.call();
        }
      });
    }
  }

  @override
  void didUpdateWidget(ArchProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      if (widget.animate) {
        _controller.forward(from: 0.0);
      } else {
        _controller.value = 1.0;
        widget.onCompleted?.call();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final currentProgress = widget.animate
            ? _animation.value * widget.percentage
            : widget.percentage;
        final currentPercentInt = (currentProgress * 100).toInt();

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.width, widget.height),
                painter: _ArchProgressBarPainter(
                  percentage: currentProgress,
                  totalTicks: widget.totalTicks,
                ),
              ),
              Positioned(
                bottom: 12.h,
                child: Opacity(
                  opacity: widget.animate
                      ? _animation.value.clamp(0.0, 1.0)
                      : 1.0,
                  child: Transform.scale(
                    scale: widget.animate
                        ? (0.85 + (0.15 * _animation.value))
                        : 1.0,
                    child: Text(
                      "$currentPercentInt%",
                      style: AppTextStyles.textStyle_700_30.copyWith(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArchProgressBarPainter extends CustomPainter {
  final double percentage;
  final int totalTicks;

  const _ArchProgressBarPainter({
    required this.percentage,
    required this.totalTicks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height - 15;
    final radius = size.width * 0.38;
    const tickLength = 32.2;
    const tickWidth = 12.6;
    const tickRadius = 4.2;

    const startAngle = math.pi + 0.087;
    const sweepAngle = math.pi + 0.174;

    final activeProgress = totalTicks * percentage;

    final localTickRect = Rect.fromCenter(
      center: Offset.zero,
      width: tickLength,
      height: tickWidth,
    );

    final fullShader = const LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [AppColors.archGradientStart, AppColors.primary],
    ).createShader(localTickRect);

    final fullFilledPaint = Paint()
      ..shader = fullShader
      ..style = PaintingStyle.fill;

    final inactivePaint = Paint()
      ..color = const Color(0xFFF1F1F1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < totalTicks; i++) {
      final t = i / (totalTicks - 1);
      final angle = startAngle - (t * sweepAngle);

      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(-angle);
      canvas.translate(radius, 0);

      if (i + 1 <= activeProgress) {
        // Fully filled tick with local gradient
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            localTickRect,
            const Radius.circular(tickRadius),
          ),
          fullFilledPaint,
        );
      } else if (i >= activeProgress) {
        // Unfilled inactive tick
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            localTickRect,
            const Radius.circular(tickRadius),
          ),
          inactivePaint,
        );
      } else {
        // Actively transitioning tick: draws soft inactive base, then illuminated gradient pulse
        final f = (activeProgress - i).clamp(0.0, 1.0);
        final pulse = 1.0 + 0.08 * math.sin(f * math.pi);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            localTickRect,
            const Radius.circular(tickRadius),
          ),
          inactivePaint,
        );

        canvas.scale(pulse);

        final activeShader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppColors.archGradientStart.withValues(alpha: f),
            AppColors.primary.withValues(alpha: f),
          ],
        ).createShader(localTickRect);

        final activePaint = Paint()
          ..shader = activeShader
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            localTickRect,
            const Radius.circular(tickRadius),
          ),
          activePaint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ArchProgressBarPainter oldDelegate) =>
      oldDelegate.percentage != percentage ||
      oldDelegate.totalTicks != totalTicks;
}
