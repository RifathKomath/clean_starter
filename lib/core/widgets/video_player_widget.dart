import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_mentor/core/constants/app_text_styles.dart';
import 'package:my_mentor/core/constants/assets.dart';
import 'package:my_mentor/core/extensions/context_extensions.dart';
import 'package:my_mentor/core/widgets/app_image_view.dart';
import 'package:my_mentor/core/widgets/custom_video_controller.dart';

/// Reusable course video player widget with dual state:
/// 1. **Preview Mode** (Initial): Renders course thumbnail, dark bottom gradient,
///    center circular play button, and conditionally "Preview this course" text when [isPreview] is true.
/// 2. **Active Player Mode**: When tapped, initializes [BetterPlayerController]
///    for [videoAsset] and renders playback with [CustomVideoControls] in both normal & fullscreen modes.
class VideoPlayerWidget extends StatefulWidget {
  final BetterPlayerController? controller;
  final String? videoAsset;
  final String? thumbnailAsset;
  final String? title;
  final double aspectRatio;
  final double borderRadius;
  final BoxFit fit;
  final bool autoPlay;
  final bool isPreview;
  final VoidCallback? onPlayTap;

  /// Replaces the default gradient, play button and preview text on the thumbnail.
  final Widget? previewOverlay;

  const VideoPlayerWidget({
    super.key,
    this.controller,
    this.videoAsset,
    this.thumbnailAsset,
    this.title,
    this.aspectRatio = 16 / 9,
    this.borderRadius = 16.0,
    this.fit = BoxFit.cover,
    this.autoPlay = false,
    this.isPreview = true,
    this.onPlayTap,
    this.previewOverlay,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  BetterPlayerController? _controller;
  bool _isInternalController = false;
  bool _isPlayerActive = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller;
      _isPlayerActive = true;
      _isInternalController = false;
    } else if (widget.autoPlay) {
      _initializeAndPlay();
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      if (_isInternalController) {
        try {
          _controller?.dispose();
        } catch (_) {}
      }
      _controller = widget.controller;
      _isInternalController = false;
      _isPlayerActive = true;
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      try {
        _controller?.pause();
        _controller?.dispose();
      } catch (_) {}
    }
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<BetterPlayerDataSource> _resolveDataSource(String source) async {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return BetterPlayerDataSource.network(source);
    }
    if (source.startsWith('/') && File(source).existsSync()) {
      return BetterPlayerDataSource.file(source);
    }
    // Asset source loaded via memory bytes
    final byteData = await rootBundle.load(source);
    final bytes = byteData.buffer.asUint8List();
    return BetterPlayerDataSource.memory(bytes, videoExtension: 'mp4');
  }

  Future<void> _initializeAndPlay() async {
    widget.onPlayTap?.call();

    if (_controller != null) {
      setState(() {
        _isPlayerActive = true;
      });
      await _controller!.play();
      return;
    }

    final assetPath = widget.videoAsset ?? Assets.dummy.dummyVideo;

    try {
      final dataSource = await _resolveDataSource(assetPath);

      final configuration = BetterPlayerConfiguration(
        aspectRatio: widget.aspectRatio,
        autoPlay: true,
        fit: widget.fit,
        handleLifecycle: false,
        playerVisibilityChangedBehavior: (fraction) {},
        deviceOrientationsAfterFullScreen: const [DeviceOrientation.portraitUp],
        controlsConfiguration: BetterPlayerControlsConfiguration(
          playerTheme: BetterPlayerTheme.custom,
          customControlsBuilder:
              (controller, onVisibilityChanged, configuration) {
                return CustomVideoControls(
                  controller: controller,
                  title: widget.title,
                );
              },
        ),
      );

      final controller = BetterPlayerController(
        configuration,
        betterPlayerDataSource: dataSource,
      );

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInternalController = true;
          _isPlayerActive = true;
        });
      }
    } catch (e) {
      debugPrint('VideoPlayerWidget initialization notice: $e');
      if (mounted) {
        setState(() {
          _isPlayerActive = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPlayerActive && _controller != null) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          child: BetterPlayer(controller: _controller!),
        ),
      );
    }

    // Preview Card State matching design mockup
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _initializeAndPlay,
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Thumbnail Image
                AppImageView(
                  widget.thumbnailAsset ?? Assets.dummy.course1,
                  width: double.infinity,
                  height: double.infinity,
                ),

                if (widget.previewOverlay != null)
                  widget.previewOverlay!
                else ...[
                  // 2. Bottom Gradient Overlay
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 75.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.75),
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Center Play Button
                  Center(
                    child: Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.38),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 34.r,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // 4. "Preview this course" bottom text (only rendered when isPreview == true)
                  if (widget.isPreview)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12.h,
                      child: Text(
                        "Preview this course",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.textStyle_500_14.copyWith(
                          color: Colors.white,
                          fontSize: 13.sp,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
