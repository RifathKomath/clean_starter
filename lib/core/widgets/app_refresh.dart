import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/assets.dart';
import '../theme/app_colors.dart';
import 'app_image_view.dart';

class AppRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;
  final bool loading;

  const AppRefresh({
    super.key,
    required this.child,
    this.onRefresh,
    this.loading = false,
  });

  @override
  State<AppRefresh> createState() => _AppRefreshState();
}

class _AppRefreshState extends State<AppRefresh>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onRefresh = widget.onRefresh;
    if (onRefresh == null) return _buildContent(context, widget.child);
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      builder: _buildContent,
      child: widget.child,
    );
  }

  Widget _buildContent(
    BuildContext context,
    Widget child, [
    IndicatorController? controller,
  ]) {
    final spinning = widget.loading || controller?.state.isLoading == true;
    if (spinning && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!spinning && _rotationController.isAnimating) {
      _rotationController.stop();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([controller, _rotationController]),
      child: child,
      builder: (context, content) {
        final pull = controller?.value ?? 0.0;
        return Stack(
          children: [
            Transform.translate(offset: Offset(0, 80.h * pull), child: content),
            if (spinning || controller?.isIdle == false)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 15.h,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Opacity(
                      opacity: widget.loading ? 1 : pull.clamp(0.0, 1.0),
                      child: Semantics(
                        label: 'Loading',
                        child: Card(
                          key: const ValueKey('konnect24-chain-loader'),
                          color: AppColors.white,
                          elevation: 2,
                          shape: const CircleBorder(),
                          child: SizedBox(
                            height: 56.h,
                            width: 56.h,
                            child: Center(
                              child: Transform.rotate(
                                angle:
                                    (spinning
                                        ? _rotationController.value
                                        : pull) *
                                    2 *
                                    math.pi,
                                child: AppImageView(
                                  Assets.images.academicGradeIcon,
                                  // height: 36.h,
                                  // width: 36.w,
                                  // fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
