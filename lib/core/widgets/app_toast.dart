import 'package:flutter/material.dart';
import '../../di/locator.dart';
import '../services/navigation_service.dart';
import '../theme/app_colors.dart';

enum ToastType { success, error, warning, doublePress }

class AppToast {
  static OverlayEntry? _currentEntry;

  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.error,
  }) {
    BuildContext activeContext = context;
    if (!context.mounted) {
      final globalContext =
          getIt<NavigationService>().navigationKey.currentContext;
      if (globalContext != null && globalContext.mounted) {
        activeContext = globalContext;
      } else {
        return; // cannot show toast safely
      }
    }

    final overlayState = Overlay.of(activeContext);

    // Dismiss existing toast if any
    _currentEntry?.remove();
    _currentEntry = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _ToastWidget(
          message: message,
          type: type,
          onDismiss: () {
            if (_currentEntry == entry) {
              entry.remove();
              _currentEntry = null;
            }
          },
        );
      },
    );

    _currentEntry = entry;
    overlayState.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    IconData icon;
    Color barColor;

    switch (widget.type) {
      case ToastType.success:
        iconColor = Colors.green.shade700;
        barColor = Colors.green;
        icon = Icons.check_circle_outline_rounded;
        break;
      case ToastType.warning:
        iconColor = Colors.orange.shade800;
        barColor = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case ToastType.doublePress:
        iconColor = AppColors.primary;
        barColor = AppColors.primary;
        icon = Icons.info_outline_rounded;
        break;
      case ToastType.error:
        iconColor = AppColors.redColor;
        barColor = AppColors.redColor;
        icon = Icons.error_outline_rounded;
    }

    final backgroundColor =
        Color.lerp(Colors.white, barColor, 0.08) ?? Colors.white;

    final safeAreaTop = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: safeAreaTop + 16 + _slideAnimation.value,
          left: 16,
          right: 16,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      offset: const Offset(0, 10),
                      blurRadius: 30,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                  border: Border.all(
                    color:
                        Color.lerp(Colors.white, barColor, 0.2) ??
                        Colors.transparent,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // // Left colored stripe
                        // Container(width: 12, color: barColor),
                        const SizedBox(width: 16),
                        Icon(icon, color: iconColor, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 4,
                            ),
                            child: Text(
                              widget.message,
                              style: const TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                        // Close button
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF9CA3AF),
                          ),
                          onPressed: () {
                            _controller.reverse().then(
                              (_) => widget.onDismiss(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
