import 'package:flutter/material.dart';
import 'package:my_mentor/core/constants/assets.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../di/locator.dart';
import '../constants/app_text_styles.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import 'app_image_view.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isBack;
  final String title;

  final Widget? leftWidget;
  final Widget? rightWidget;

  final VoidCallback? onBackTap;

  final bool centerTitle;
  final bool isDarkBackground;

  final String? actionIcon;
  final VoidCallback? onActionTap;

  /// Whether to display a pagination linear progress indicator instead of title text
  final bool linear;
  final double linearProgress;
  final double? linearWidth;
  final double? titleSpacing;
  final double? leadingWidth;

  const CustomAppBar({
    super.key,
    this.isBack = false,
    this.title = "",
    this.leftWidget,
    this.rightWidget,
    this.onBackTap,
    this.centerTitle = true,
    this.isDarkBackground = false,
    this.actionIcon,
    this.onActionTap,
    this.linear = false,
    this.linearProgress = 0.2,
    this.linearWidth,
    this.titleSpacing,
    this.leadingWidth,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Color contentColor = isDarkBackground
        ? Colors.white
        : AppColors.textCharcoal;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: isDarkBackground
          ? const Color(0xFF0B2951)
          : Colors.transparent,

      centerTitle: centerTitle,
      titleSpacing: titleSpacing ?? (!centerTitle ? 20.w : null),

      /// 👇 ADD THIS
      toolbarHeight: isDarkBackground ? 100 : kToolbarHeight,

      leadingWidth:
          leadingWidth ??
          (leftWidget != null ? 70.w : (isDarkBackground ? 56 : 50)),

      leading:
          leftWidget ??
          (isBack
              ? Padding(
                  padding: EdgeInsets.only(top: isDarkBackground ? 30 : 0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap:
                        onBackTap ??
                        () {
                          getIt<NavigationService>().pop();
                        },
                    child: AppImageView(Assets.images.backArrow, height: 48),
                  ),
                )
              : null),

      title: Padding(
        padding: EdgeInsets.only(top: isDarkBackground ? 30 : 0),
        child: linear
            ? Container(
                width: linearWidth ?? 130.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.progressBarTrack,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  widthFactor: linearProgress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              )
            : Text(
                title,
                style: AppTextStyles.textStyle_500_14.copyWith(
                  fontSize: 16,
                  color: contentColor,
                ),
              ),
      ),

      actions: [
        if (rightWidget != null)
          Padding(
            padding: EdgeInsets.only(top: isDarkBackground ? 30 : 0),
            child: rightWidget,
          ),

        if (actionIcon != null)
          Padding(
            padding: EdgeInsets.only(right: 16, top: isDarkBackground ? 30 : 0),
            child: GestureDetector(
              onTap: onActionTap,
              child: AppImageView(actionIcon ?? "", height: 45),
            ),
          ),
      ],
    );
  }
}
