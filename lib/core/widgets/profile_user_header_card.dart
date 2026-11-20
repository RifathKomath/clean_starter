import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../constants/assets.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import 'app_container.dart';
import 'app_image_view.dart';

/// User profile header card displayed at the top of category ProfileScreens.
/// Features:
/// - Floating circular user avatar overlapping the top boundary of the card
/// - Glassmorphic container with 40-sigma backdrop blur effect
/// - User credentials (name, email, phone number) on the left
/// - "Edit Profile" rounded action pill button on the right
class ProfileUserHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String? avatarPath;
  final VoidCallback? onEditProfileTap;

  const ProfileUserHeaderCard({
    super.key,
    this.name = "Muhammed Rifath K",
    this.email = "rifathk123@gmail.com",
    this.phone = "+91 1234567892",
    this.avatarPath,
    this.onEditProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAvatar = avatarPath ?? Assets.images.onboardingAsset3;

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        /// 1. Floating Circular User Avatar (placed BEHIND / BELOW the blur container)
        Positioned(
          top: -35,
          child: Container(
            width: 86.h,
            height: 86.h,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: AppImageView(effectiveAvatar, width: 86.h, height: 86.h),
            ),
          ),
        ),

        /// 2. Frosted Glass Container with 40-Sigma Blur (layered ON TOP OF the avatar)
        Padding(
          padding: EdgeInsets.only(top: 44.h),
          child: AppContainer(
            blur: 40,
            radius: 30.r,
            isExpanded: true,
            isBorder: true,
            borderColor: Colors.white.withValues(alpha: 0.85),
            color: Colors.white.withValues(alpha: 0.82),
            vPadding: 15.h,
            child: Row(
              children: [
                /// User Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textStyle_500_14.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.textCharcoal,
                        ),
                      ),
                      5.h.hBox,
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textStyle_400_13.copyWith(
                          fontSize: 12.sp,
                          color: const Color(0xFF656565),
                        ),
                      ),
                      4.h.hBox,
                      Text(
                        phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textStyle_400_13.copyWith(
                          fontSize: 12.sp,
                          color: const Color(0xFF656565),
                        ),
                      ),
                    ],
                  ),
                ),
                12.w.wBox,

                /// Edit Profile Pill Action Button
                GestureDetector(
                  onTap: onEditProfileTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Text(
                      "Edit Profile",
                      style: AppTextStyles.textStyle_500_14.copyWith(
                        color: Colors.white,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
