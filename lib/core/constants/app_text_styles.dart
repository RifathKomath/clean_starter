import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppTextStyles {
  static const String _fontFamily = "Figtree";

  static TextStyle textStyle_500_14 = const TextStyle(
    fontSize: 14,
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static TextStyle textStyle_400_14 = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    color: Colors.black,
  );

  static TextStyle textStyle_600_14 = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: Colors.black,
  );

  static TextStyle textStyle_700_14 = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: Colors.black,
  );

  static TextStyle textStyle_700_30 = const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: Colors.black,
  );

  static TextStyle textStyle_600_24 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: AppColors.primary,
  );

  static TextStyle textStyle_400_13 = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    color: AppColors.grey69,
  );

  static TextStyle textStyle_500_23 = const TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textCharcoal,
  );

  static TextStyle textStyle_500_24 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textCharcoal,
  );

  static TextStyle textStyle_500_26 = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textCharcoal,
  );

  static TextStyle textStyle_400_19 = const TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    color: AppColors.textCharcoal,
  );

  static TextStyle textStyle_400_18 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    color: AppColors.textGrey79,
  );

  static TextStyle textStyle_500_12 = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textCharcoal,
  );

  static TextStyle textStyle_400_12 = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    color: AppColors.textCharcoal,
  );

  static TextStyle textStyle_500_13 = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textGrey3B,
  );

  static TextStyle textStyle_600_12 = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: AppColors.primary,
  );

  static TextStyle textStyle_500_15 = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.grey21,
  );

  static TextStyle textStyle_500_16 = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.grey21,
  );

  static TextStyle textStyle_600_38 = const TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: Colors.black,
  );

  static TextStyle textStyle_600_11 = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: AppColors.primary,
  );

  static TextStyle textStyle_400_11 = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    color: AppColors.textGrey73,
  );

  static TextStyle textStyle_600_18 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: AppColors.primary,
  );

  static TextStyle textStyle_500_18 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textCharcoal,
  );

  static TextStyle textStyle_400_15 = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    color: AppColors.textGrey94,
  );

  static TextStyle textStyle_600_16 = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: Colors.black,
  );

  static TextStyle textStyle_600_13 = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: Colors.black,
  );

  static TextStyle poppinsW600(
    BuildContext context,
    double size, {
    Color? color,
  }) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color:
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black),
  );

  static TextStyle poppinsW500(
    BuildContext context,
    double size, {
    Color? color,
  }) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color:
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black),
  );
}
