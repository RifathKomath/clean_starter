import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_mentor/core/widgets/app_lottie.dart';
import '../constants/app_text_styles.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import 'app_image_view.dart';
import 'app_text_switcher.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoaderBtn;
  final bool isExpanded;
  final double? height;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final bool isFilled;
  final Color? borderColor;
  final double? borderWidth;
  final bool isBlack;
  final bool isShadow;
  final bool useCupertinoLoader;
  final String? loaderAssetName;

  /// Trailing arrow circle options
  final bool showArrow;
  final Color? arrowCircleColor;
  final Color? arrowCircleBorderColor;
  final Color? arrowIconColor;
  final IconData arrowIcon;
  final Widget? arrowChild;
  final Gradient? arrowCircleGradient;
  final double? arrowCircleSize;
  final double spacing;

  /// Optional prefix & suffix icons inside the pill
  final String? prefixIcon;
  final String? suffixIcon;
  final bool isPrefixIconEnabled;
  final bool isSuffixIconEnabled;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoaderBtn = false,
    this.isExpanded = true,
    this.height,
    this.radius = 100,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.isFilled = true,
    this.borderColor,
    this.borderWidth,
    this.isBlack = false,
    this.isShadow = true,
    this.useCupertinoLoader = false,
    this.loaderAssetName,
    this.showArrow = true,
    this.arrowCircleColor,
    this.arrowCircleBorderColor,
    this.arrowIconColor,
    this.arrowIcon = Icons.arrow_forward_rounded,
    this.arrowChild,
    this.arrowCircleGradient,
    this.arrowCircleSize,
    this.spacing = 12,
    this.prefixIcon,
    this.suffixIcon,
    this.isPrefixIconEnabled = false,
    this.isSuffixIconEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 52.h;
    final effectiveCircleSize = arrowCircleSize ?? effectiveHeight;
    final effectiveBgColor =
        backgroundColor ??
        (isBlack
            ? AppColors.buttonBlack
            : (isFilled ? Colors.white : Colors.transparent));
    final effectiveTextColor =
        textColor ??
        (isBlack
            ? Colors.white
            : (isFilled ? Colors.black : AppColors.primary));
    final effectiveBorderColor =
        borderColor ??
        (isBlack
            ? Colors.transparent
            : (isFilled ? Colors.transparent : AppColors.primary));
    final effectiveArrowCircleColor = arrowCircleColor ?? AppColors.primary;
    final effectiveArrowIconColor = arrowIconColor ?? Colors.white;
    final effectiveArrowCircleBorderColor =
        arrowCircleBorderColor ??
        (isBlack ? Colors.transparent : Colors.white.withValues(alpha: 0.3));

    final Widget pillWidget = Container(
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(radius),
        border: effectiveBorderColor == Colors.transparent
            ? null
            : Border.all(
                color: effectiveBorderColor,
                width: borderWidth ?? 1.5,
              ),
        boxShadow: !isShadow
            ? null
            : isBlack
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ]
            : (isFilled
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ]
                  : null),
      ),
      alignment: Alignment.center,
      child: isLoaderBtn
          ? (useCupertinoLoader
                ? CupertinoActivityIndicator(
                    color: isBlack ? Colors.white : AppColors.primary,
                    radius: 12.r,
                  )
                : SizedBox(
                    height: 45.h,
                    width: 45.h,
                    child: AppLottie(
                      assetName: loaderAssetName ?? "education_loader",
                      fit: BoxFit.contain,
                    ),
                  ))
          : _buildContent(effectiveTextColor),
    );

    final Widget arrowCircleWidget = Container(
      width: effectiveCircleSize,
      height: effectiveCircleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: arrowCircleGradient == null ? effectiveArrowCircleColor : null,
        gradient: arrowCircleGradient,
        border: effectiveArrowCircleBorderColor == Colors.transparent
            ? null
            : Border.all(color: effectiveArrowCircleBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: effectiveArrowCircleColor.withValues(alpha: 0.25),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      alignment: Alignment.center,
      child:
          arrowChild ??
          Icon(arrowIcon, color: effectiveArrowIconColor, size: 22.sp),
    );

    return GestureDetector(
      onTap: isLoaderBtn ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isExpanded) Expanded(child: pillWidget) else pillWidget,
          if (showArrow) ...[SizedBox(width: spacing.w), arrowCircleWidget],
        ],
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// PREFIX ICON
          if (isPrefixIconEnabled && prefixIcon != null) ...[
            AppImageView(prefixIcon!, height: 20.h, color: textColor),
            SizedBox(width: 8.w),
          ],

          /// LABEL
          Flexible(
            child: AppTextSwitcher(
              duration: const Duration(milliseconds: 250),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  key: ValueKey<String>(label),
                  style:
                      textStyle ??
                      AppTextStyles.textStyle_500_14.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                ),
              ),
            ),
          ),

          /// SUFFIX ICON
          if (isSuffixIconEnabled && suffixIcon != null) ...[
            SizedBox(width: 8.w),
            AppImageView(suffixIcon!, height: 20.h, color: textColor),
          ],
        ],
      ),
    );
  }
}
