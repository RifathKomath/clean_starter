import 'dart:io';

import 'package:flutter/material.dart';
import '../../app/app_routes.dart';
import '../../di/locator.dart';
import '../constants/app_text_styles.dart';
import '../constants/assets.dart';
import '../extensions/context_extensions.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_image_view.dart';
import '../widgets/hero_shuttle_builder.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _graphicsFade;
  late final Animation<Offset> _leftCardSlide;
  late final Animation<Offset> _rightCardSlide;
  late final Animation<double> _centerCardScale;
  late final Animation<Offset> _centerCardSlide;
  late final Animation<double> _typographyFade;
  late final Animation<Offset> _typographySlide;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Graphics animations (0.15 -> 0.70)
    _graphicsFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.12, 0.65, curve: Curves.easeOut),
    );

    _leftCardSlide =
        Tween<Offset>(
          begin: const Offset(-0.25, -0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.15, 0.70, curve: Curves.easeOutCubic),
          ),
        );

    _rightCardSlide =
        Tween<Offset>(begin: const Offset(0.25, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.20, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    _centerCardScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.10, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _centerCardSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.10, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    // Headline typography animations (0.40 -> 0.85)
    _typographyFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.38, 0.82, curve: Curves.easeOut),
    );

    _typographySlide =
        Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.38, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    // Button animations (0.60 -> 1.0)
    _buttonFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.60, 0.95, curve: Curves.easeOut),
    );

    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Trigger entrance animation smoothly upon mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkPurple,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.darkPurple],
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: Platform.isIOS ? false : true,
          left: false,
          right: false,
          child: Stack(
            children: [
              /// SMALL DARK CIRCULAR SHADOW EFFECT IN TOP RIGHT
              Platform.isAndroid ? 10.hBox : 0.hBox,
              Positioned(
                top: -60.h,
                right: -90.w,
                child: Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkPurple.withValues(alpha: 0.12),
                  ),
                ),
              ),

              /// MAIN CONTENT
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              4.h.hBox,

                              /// TOP RIGHT LOGO BADGE (HERO DESTINATION)
                              Padding(
                                padding: EdgeInsets.only(right: 20.w),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Hero(
                                    tag: kHeroAppLogoTag,
                                    createRectTween: createHeroArcTween,
                                    flightShuttleBuilder:
                                        appHeroFlightShuttleBuilder,
                                    child: AppImageView(
                                      Assets.images.purpleLogo,
                                      height: 48.h,
                                      width: 48.h,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),

                              /// HERO GRAPHIC & TILTED CARDS (STAGGERED ENTRANCE)
                              AnimatedBuilder(
                                animation: _entranceController,
                                builder: (context, child) {
                                  return FadeTransition(
                                    opacity: _graphicsFade,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 330.h,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          /// Top-Left Tilted Progress Card
                                          Positioned(
                                            left: -15.w,
                                            top: -25.h,
                                            child: SlideTransition(
                                              position: _leftCardSlide,
                                              child: AppImageView(
                                                Assets.images.onboardingAsset,
                                                width: 155.w,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),

                                          /// Bottom-Right Tilted IT Course Card
                                          Positioned(
                                            right: -6.w,
                                            top: 185.h,
                                            child: SlideTransition(
                                              position: _rightCardSlide,
                                              child: AppImageView(
                                                Assets.images.onboardingAsset2,
                                                width: 175.w,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),

                                          /// Center 3D Book & Graduation Cap
                                          Positioned(
                                            top: 55.h,
                                            left: 0,
                                            right: 0,
                                            child: Align(
                                              child: SlideTransition(
                                                position: _centerCardSlide,
                                                child: Transform.scale(
                                                  scale: _centerCardScale.value,
                                                  child: AppImageView(
                                                    Assets
                                                        .images
                                                        .onboardingAsset1,
                                                    width: 375.w,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const Spacer(),

                              /// HEADLINE TYPOGRAPHY & BUTTON (STAGGERED ENTRANCE)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedBuilder(
                                      animation: _entranceController,
                                      builder: (context, child) {
                                        return FadeTransition(
                                          opacity: _typographyFade,
                                          child: SlideTransition(
                                            position: _typographySlide,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                /// Line 1: Learn
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Learn',
                                                    style: AppTextStyles
                                                        .textStyle_500_14
                                                        .copyWith(
                                                          fontSize: 48.sp,
                                                          height: 1.15,
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                  ),
                                                ),

                                                10.h.hBox,

                                                /// Line 2: [Overlapping Badges] Upskill
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      /// Dual Overlapping Badges
                                                      SizedBox(
                                                        width: 68.w,
                                                        height: 40.w,
                                                        child: Stack(
                                                          children: [
                                                            /// First badge (white circular icon)
                                                            Positioned(
                                                              left: 0,
                                                              child: AppImageView(
                                                                Assets
                                                                    .images
                                                                    .onboardingAsset3,
                                                                width: 40.w,
                                                                height: 40.w,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),

                                                            /// Second badge (dark circular cap icon)
                                                            Positioned(
                                                              left: 26.w,
                                                              child: AppImageView(
                                                                Assets
                                                                    .images
                                                                    .onboardingAsset4,
                                                                width: 40.w,
                                                                height: 40.w,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      12.w.wBox,

                                                      Text(
                                                        'Upskill',
                                                        style: AppTextStyles
                                                            .textStyle_500_14
                                                            .copyWith(
                                                              fontSize: 48.sp,
                                                              height: 1.15,
                                                              color: AppColors
                                                                  .white,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                14.h.hBox,

                                                /// Line 3: ( Grow ) in bordered pill
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 28.w,
                                                    vertical: 4.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          100.r,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Grow',
                                                    style: AppTextStyles
                                                        .textStyle_500_14
                                                        .copyWith(
                                                          fontSize: 48.sp,
                                                          height: 1.15,
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    32.h.hBox,

                                    /// GET STARTED BUTTON (STAGGERED SLIDE & FADE)
                                    AnimatedBuilder(
                                      animation: _entranceController,
                                      builder: (context, child) {
                                        return FadeTransition(
                                          opacity: _buttonFade,
                                          child: SlideTransition(
                                            position: _buttonSlide,
                                            child: AppButton(
                                              label: 'Get Started',
                                              onTap: () {
                                                // getIt<NavigationService>()
                                                //     .pushNamedAndRemoveUntil(
                                                //       AppRoutes.accountCreation,
                                                //     );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    20.h.hBox,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
