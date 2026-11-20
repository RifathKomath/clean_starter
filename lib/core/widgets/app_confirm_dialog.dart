import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

/// Confirmation dialog for actions like logout or delete account.
///
/// On OK the OK button switches to its built-in loader and [onConfirm] runs.
/// The dialog stays open while [onConfirm] is in progress. If [onConfirm]
/// navigates away (which removes this route), the dialog is not popped again.
class AppConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final Future<void> Function() onConfirm;

  const AppConfirmDialog({
    super.key,
    required this.onConfirm,
    this.title = 'Logout?',
    this.message = 'Are you sure you want to logout?',
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onConfirm,
    String title = 'Logout?',
    String message = 'Are you sure you want to logout?',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppConfirmDialog(
        onConfirm: onConfirm,
        title: title,
        message: message,
      ),
    );
  }

  @override
  State<AppConfirmDialog> createState() => _AppConfirmDialogState();
}

class _AppConfirmDialogState extends State<AppConfirmDialog> {
  bool _isLoading = false;

  Future<void> _onOkTap() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await widget.onConfirm();
    // Logout/delete navigate away, which removes this route; only pop if shown.
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.all(22.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.textStyle_500_18.copyWith(
                color: AppColors.textCharcoal,
              ),
            ),
            10.hBox,
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.textStyle_400_14.copyWith(
                fontSize: 13.sp,
                height: 18 / 13,
                color: AppColors.grey6B,
              ),
            ),
            22.hBox,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    isFilled: false,
                    showArrow: false,
                    isShadow: false,
                    height: 46.h,
                    onTap: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ),
                10.wBox,
                Expanded(
                  child: AppButton(
                    label: 'OK',
                    isBlack: true,
                    showArrow: false,
                    isShadow: false,
                    height: 46.h,
                    isLoaderBtn: _isLoading,
                    loaderAssetName: 'education_loader',
                    onTap: _onOkTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
