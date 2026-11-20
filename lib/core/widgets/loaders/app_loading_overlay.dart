import 'package:flutter/material.dart';
import '../app_lottie.dart';

/// Global overlay loader displaying `assets/lotties/education_loader.json`.
/// Restricts user interaction and back navigation while active.
class AppLoadingOverlay {
  static OverlayEntry? _overlayEntry;

  /// Returns whether the loading overlay is currently active.
  static bool get isShowing => _overlayEntry != null;

  /// Shows the education loader over the whole screen on a light-black scrim.
  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    try {
      final overlay =
          Overlay.maybeOf(context, rootOverlay: true) ??
          (context.mounted
              ? Navigator.of(context, rootNavigator: true).overlay
              : null);
      if (overlay == null) return;

      _overlayEntry = OverlayEntry(
        builder: (context) => PopScope(
          canPop: false,
          child: Material(
            // Full-screen light-black scrim with the lottie centred on it.
            color: Colors.black.withValues(alpha: 0.35),
            child: const Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: AppLottie(
                  assetName: 'education_loader',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );

      overlay.insert(_overlayEntry!);
    } catch (_) {
      // Gracefully ignore in non-UI environments or test contexts
    }
  }

  /// Hides and cleans up the active loader overlay.
  static void hide() {
    try {
      _overlayEntry?.remove();
    } catch (_) {}
    _overlayEntry = null;
  }
}
