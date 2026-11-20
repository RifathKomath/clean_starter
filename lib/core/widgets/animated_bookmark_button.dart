import 'package:flutter/material.dart';
import 'package:my_mentor/core/constants/assets.dart';
import 'package:my_mentor/core/extensions/context_extensions.dart';
import 'package:my_mentor/core/widgets/app_image_view.dart';

/// Reusable bouncy animated bookmark button:
/// - Provides spring/pop scale transition when tapped or when [isBookmarked] toggles
/// - Seamlessly transitions between [Assets.svgs.bookmark] and [Assets.svgs.activeBookmark]
class AnimatedBookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback? onTap;
  final double? size;

  const AnimatedBookmarkButton({
    super.key,
    required this.isBookmarked,
    this.onTap,
    this.size,
  });

  @override
  State<AnimatedBookmarkButton> createState() => _AnimatedBookmarkButtonState();
}

class _AnimatedBookmarkButtonState extends State<AnimatedBookmarkButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.32,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.32,
          end: 0.90,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.90,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AnimatedBookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBookmarked != widget.isBookmarked) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = widget.size ?? 38.r;

    return GestureDetector(
      key: const Key('course_bookmark_button'),
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: AppImageView(
            key: ValueKey<bool>(widget.isBookmarked),
            widget.isBookmarked
                ? Assets.svgs.activeBookmark
                : Assets.svgs.bookmark,
            width: effectiveSize,
            height: effectiveSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
