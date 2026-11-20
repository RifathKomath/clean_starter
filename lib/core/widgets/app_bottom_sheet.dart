import 'package:flutter/material.dart';

import '../../di/locator.dart';
import '../constants/app_text_styles.dart';
import '../extensions/context_extensions.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';

class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? titleImage;
  final bool showCloseButton;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.titleImage,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        /// Main Bottom Sheet
        ClipPath(
          clipper: BottomSheetTopClipper(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 45,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom +
                  MediaQuery.of(context).viewInsets.bottom +
                  20,
            ),
            decoration: const BoxDecoration(color: AppColors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header Area
                if (title != null || showCloseButton) ...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (title != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (titleImage != null) ...[titleImage!, 4.wBox],
                            Text(
                              title!,
                              style: AppTextStyles.textStyle_600_14.copyWith(
                                // color: AppColors.textColor1,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      if (showCloseButton)
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => getIt<NavigationService>().pop(),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                // color: AppColors.lightGray,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                // color: AppColors.textColor1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  20.hBox,
                ],
                child,
              ],
            ),
          ),
        ),

        /// Floating Drag Handle
        Positioned(
          top: 2,
          child: Container(
            width: 68,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ],
    );
  }
}

class BottomSheetTopClipper extends CustomClipper<Path> {
  final double radius;
  final double slopeWidth;
  final double centerWidth;
  final double slopeHeight;

  BottomSheetTopClipper({
    this.radius = 37,
    this.slopeWidth = 45,
    this.centerWidth = 65,
    this.slopeHeight = 15,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    final w = size.width;
    final h = size.height;

    final centerX = w / 2;

    final leftSlopeStart = centerX - (centerWidth / 2) - slopeWidth;
    final leftFlatStart = centerX - (centerWidth / 2);

    final rightFlatEnd = centerX + (centerWidth / 2);
    final rightSlopeEnd = centerX + (centerWidth / 2) + slopeWidth;

    /// Bottom Left
    path.moveTo(0, h);

    /// Left Side
    path.lineTo(0, radius);

    /// Top Left Radius
    path.quadraticBezierTo(0, 0, radius, 0);

    /// Straight top line
    path.lineTo(leftSlopeStart, 0);

    /// Smooth left downward slope
    path.cubicTo(
      leftSlopeStart + (slopeWidth * 0.5),
      0,
      leftFlatStart - (slopeWidth * 0.5),
      slopeHeight,
      leftFlatStart,
      slopeHeight,
    );

    /// Center straight line
    path.lineTo(rightFlatEnd, slopeHeight);

    /// Smooth right upward slope
    path.cubicTo(
      rightFlatEnd + (slopeWidth * 0.5),
      slopeHeight,
      rightSlopeEnd - (slopeWidth * 0.5),
      0,
      rightSlopeEnd,
      0,
    );

    /// Top right line
    path.lineTo(w - radius, 0);

    /// Top Right Radius
    path.quadraticBezierTo(w, 0, w, radius);

    /// Right Side
    path.lineTo(w, h);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
