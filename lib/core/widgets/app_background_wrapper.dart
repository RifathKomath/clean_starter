import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBackgroundWrapper extends StatelessWidget {
  final Widget child;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final double? blurHeight;

  const AppBackgroundWrapper({
    super.key,
    required this.child,
    this.borderRadius,
    this.color,
    this.blurHeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius;
    Widget content = Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: effectiveRadius,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            right: -50,
            height: blurHeight ?? (MediaQuery.of(context).size.height * 0.3),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 41.4, sigmaY: 41.4),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.7),
                      AppColors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );

    if (effectiveRadius is BorderRadius) {
      content = ClipRRect(borderRadius: effectiveRadius, child: content);
    }

    return content;
  }
}
