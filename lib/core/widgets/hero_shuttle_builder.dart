import 'package:flutter/material.dart';

/// Tag used for the app logo Hero transition between Splash and Onboarding.
const String kHeroAppLogoTag = 'hero_app_logo';

/// Creates a smooth arc trajectory between source and destination rects.
RectTween createHeroArcTween(Rect? begin, Rect? end) {
  return MaterialRectArcTween(begin: begin, end: end);
}

/// Seamless cross-fading Hero flight shuttle that gracefully morphs the splash logo
/// into the onboarding logo badge during transit.
Widget appHeroFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Hero fromHero = fromHeroContext.widget as Hero;
  final Hero toHero = toHeroContext.widget as Hero;

  final CurvedAnimation curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOutCubic,
  );

  return AnimatedBuilder(
    animation: curvedAnimation,
    builder: (context, child) {
      final double progress = curvedAnimation.value;
      return Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // Splash Logo: smoothly fades out in the first half of flight
          Opacity(
            opacity: (1.0 - (progress * 1.4)).clamp(0.0, 1.0),
            child: FittedBox(child: fromHero.child),
          ),
          // Onboarding Logo Badge: smoothly fades in during the flight
          Opacity(
            opacity: ((progress - 0.25) * 1.33).clamp(0.0, 1.0),
            child: FittedBox(child: toHero.child),
          ),
        ],
      );
    },
  );
}
