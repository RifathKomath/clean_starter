import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_text_styles.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String labelText;
  final TextEditingController controller;
  final TextInputType textInputType;
  final String? Function(String?)? validator;

  final Widget? suffixIcon;
  final Widget? prefixIcon;

  final bool readOnly;
  final ValueChanged<String>? onChanged;

  final int? maxLength;
  final int? minLines;
  final int? max;
  final double? radius;

  /// NEW
  final bool isElevated;

  final bool useHintInsteadOfLabel;
  final bool isRequired;
  final bool isSearchField;
  final bool obscureText;
  final bool isfilled;
  final bool isWhitefilled;
  final double? trailWidth;
  final double? leadWidth;
  final Color? fillColor;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;

  final Color? borderColor;

  final bool showTrailingDivider;

  final Widget? leadingWidget;

  final bool showLeadingDivider;

  /// Space between the leading divider/widget and the text/hint.
  final double? spaceAfterLeadingDivider;

  final Widget? trailingWidget;

  final TextStyle? labelStyle;
  final Widget? hintWidget;
  final BorderRadius? customBorderRadius;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onFieldSubmitted;
  final String? errorText;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.label,
    required this.controller,
    required this.textInputType,
    this.validator,
    this.prefixIcon,
    this.trailWidth,
    this.leadWidth,
    this.fillColor,
    this.hintStyle,
    this.textStyle,
    this.radius,
    this.isElevated = false,
    this.isSearchField = false,
    this.textCapitalization = TextCapitalization.words,
    this.textInputAction = TextInputAction.done,
    this.suffixIcon,
    this.minLines,
    this.readOnly = false,
    required this.labelText,
    this.obscureText = false,
    this.isfilled = false,
    this.isWhitefilled = false,
    this.onChanged,
    this.maxLength,
    this.max,
    this.useHintInsteadOfLabel = false,
    this.isRequired = false,
    this.onTap,
    this.borderColor,
    this.trailingWidget,
    this.showTrailingDivider = true,
    this.leadingWidget,
    this.showLeadingDivider = true,
    this.spaceAfterLeadingDivider,
    this.labelStyle,
    this.hintWidget,
    this.customBorderRadius,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.errorText,
    this.autovalidateMode,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadiusVal =
        customBorderRadius ?? BorderRadius.circular(radius ?? 14);

    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<String> formFieldState) {
        final effectiveErrorText = errorText ?? formFieldState.errorText;
        final hasError =
            effectiveErrorText != null && effectiveErrorText.isNotEmpty;
        final currentBorderColor = hasError
            ? Colors.redAccent
            : (borderColor ?? AppColors.fieldBorderColor);
        final effectiveLeadingSpace =
            spaceAfterLeadingDivider ?? (showLeadingDivider ? 2.0 : 12.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) customTitle(label!, isRequired, labelStyle),
            if (label != null) 12.hBox,
            Container(
              decoration: BoxDecoration(
                borderRadius: borderRadiusVal,

                /// BOX SHADOW
                boxShadow: isElevated
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TextField(
                    focusNode: focusNode,
                    maxLength: maxLength,
                    minLines: minLines,
                    maxLines: max,
                    style:
                        textStyle ??
                        AppTextStyles.textStyle_500_14.copyWith(
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                    obscureText: obscureText,
                    readOnly: readOnly,
                    controller: controller,
                    textCapitalization: textCapitalization,
                    onTap: onTap,
                    textInputAction: isSearchField
                        ? TextInputAction.search
                        : textInputAction,
                    onChanged: (val) {
                      formFieldState.didChange(val);
                      onChanged?.call(val);
                    },
                    onSubmitted: onFieldSubmitted,
                    inputFormatters: inputFormatters,
                    keyboardType: textInputType,
                    decoration: InputDecoration(
                      counterText: '',
                      suffixIcon: suffixIcon,
                      prefixIcon: prefixIcon,
                      hintText: hintWidget != null
                          ? null
                          : (useHintInsteadOfLabel ? labelText : null),
                      labelText: hintWidget != null
                          ? null
                          : (useHintInsteadOfLabel ? null : labelText),
                      contentPadding: EdgeInsets.only(
                        left: leadingWidget != null
                            ? (leadWidth ?? 70) + effectiveLeadingSpace
                            : (prefixIcon != null ? 50 : 25),
                        right: trailingWidget != null
                            ? (trailWidth ?? 60) + 20
                            : 25,
                        top: 16,
                        bottom: 16,
                      ),
                      hintStyle:
                          hintStyle ??
                          AppTextStyles.textStyle_400_14.copyWith(
                            fontSize: 15,
                            color: AppColors.fieldTextColor,
                          ),
                      labelStyle:
                          labelStyle ??
                          AppTextStyles.textStyle_400_14.copyWith(
                            fontSize: 15,
                            color: AppColors.fieldTextColor,
                          ),
                      floatingLabelStyle:
                          labelStyle ??
                          AppTextStyles.textStyle_400_14.copyWith(
                            fontSize: 15,
                            color: AppColors.fieldTextColor,
                          ),
                      filled: true,
                      fillColor:
                          fillColor ??
                          (isWhitefilled
                              ? AppColors.white
                              : AppColors.fieldBgColor),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: borderRadiusVal,
                        borderSide: BorderSide(
                          color: currentBorderColor,
                          width: 1.35,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: borderRadiusVal,
                        borderSide: BorderSide(
                          color: currentBorderColor,
                          width: 1.35,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: borderRadiusVal,
                        borderSide: BorderSide(
                          color: currentBorderColor,
                          width: 1.35,
                        ),
                      ),
                    ),
                  ),
                  if (hintWidget != null && controller.text.isEmpty)
                    Positioned(
                      left: leadingWidget != null
                          ? (leadWidth ?? 70) + effectiveLeadingSpace
                          : (prefixIcon != null ? 50 : 25),
                      right: trailingWidget != null ? 80 : 25,
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: hintWidget,
                        ),
                      ),
                    ),

                  /// LEADING WIDGET
                  if (leadingWidget != null)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: leadWidth ?? 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(radius ?? 14),
                            bottomLeft: Radius.circular(radius ?? 14),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: leadingWidget,
                                ),
                              ),
                              if (showLeadingDivider) ...[
                                6.w.wBox,
                                const SizedBox(
                                  height: 24,
                                  child: VerticalDivider(
                                    thickness: 1,
                                    color: Color(0xFFE3E3E3),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                  /// TRAILING WIDGET
                  if (trailingWidget != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: trailWidth ?? 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(radius ?? 14),
                            bottomRight: Radius.circular(radius ?? 14),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showTrailingDivider)
                              const SizedBox(
                                height: 30,
                                child: VerticalDivider(thickness: 0.5),
                              ),
                            Expanded(child: trailingWidget!),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (hasError) ...[
              6.h.hBox,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  effectiveErrorText,
                  style: AppTextStyles.textStyle_400_14.copyWith(
                    fontSize: 12.sp,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

Widget customTitle(String label, bool isRequired, TextStyle? labelStyle) {
  return RichText(
    text: TextSpan(
      text: label,
      style:
          labelStyle ??
          AppTextStyles.textStyle_600_14.copyWith(
            fontSize: 18,
            color: AppColors.white,
          ),
      children: isRequired
          ? const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ]
          : [],
    ),
  );
}
