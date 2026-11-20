import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppContainer extends StatelessWidget {
  const AppContainer({
    super.key,
    required this.child,
    this.isExpanded,
    this.isBorder,
    this.borderColor,
    this.radius,
    this.hPadding,
    this.vPadding,
    this.padding,
    this.color,
    this.isShadow = true,
    this.boxShadow,
    this.height,
    this.blur,
  });

  final Widget child;
  final bool? isExpanded;
  final bool? isBorder;
  final Color? borderColor;
  final double? radius;
  final double? hPadding;
  final double? vPadding;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool? isShadow;
  final List<BoxShadow>? boxShadow;
  final double? height;
  final double? blur;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = BorderRadius.circular(radius ?? 24);
    final effectiveShadow =
        boxShadow ??
        (isShadow == true
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  offset: const Offset(0, 1),
                  blurRadius: 6.3,
                ),
              ]
            : null);

    final innerDecoration = BoxDecoration(
      color:
          color ??
          (blur != null
              ? Colors.white.withValues(alpha: 0.85)
              : AppColors.white),

      /// Default Radius -> 24
      borderRadius: effectiveRadius,

      /// Optional Border
      border: isBorder == true
          ? Border.all(color: borderColor ?? AppColors.lightBorderColor)
          : null,
    );

    final innerContent = Container(
      width: isExpanded == true ? double.infinity : null,
      height: height,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: hPadding ?? 16,
            vertical: vPadding ?? 24,
          ),
      decoration: blur != null
          ? innerDecoration
          : innerDecoration.copyWith(boxShadow: effectiveShadow),
      child: child,
    );

    if (blur != null) {
      return Container(
        width: isExpanded == true ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: effectiveShadow,
        ),
        child: ClipRRect(
          borderRadius: effectiveRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur!, sigmaY: blur!),
            child: innerContent,
          ),
        ),
      );
    }

    return innerContent;
  }
}
