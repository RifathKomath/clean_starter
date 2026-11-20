import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import 'app_image_view.dart';

/// Reusable profile list row item displaying an icon, title, and forward chevron or logout styling.
class ProfileItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback? onTap;
  final bool isLogout;
  final double height;
  final double width;

  const ProfileItem({
    super.key,
    required this.title,
    required this.iconPath,
    this.isLogout = false,
    this.onTap,
    this.height = 36,
    this.width = 36,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          AppImageView(iconPath, height: height, width: width),
          20.wBox,
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.textStyle_500_14.copyWith(
                color: isLogout ? AppColors.redColor2 : AppColors.textPrimary,
              ),
            ),
          ),
          if (!isLogout)
            const Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: AppColors.grey6B,
            ),
        ],
      ),
    );
  }
}
