import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_mentor/core/constants/app_text_styles.dart';
import 'package:my_mentor/core/extensions/context_extensions.dart';
import 'package:my_mentor/core/theme/app_colors.dart';

class CustomVideoControls extends StatefulWidget {
  final BetterPlayerController controller;
  final String? title;

  const CustomVideoControls({super.key, required this.controller, this.title});

  @override
  State<CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<CustomVideoControls> {
  bool _isPlaying = false;
  bool _isFinished = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _showControls = true;
  Timer? _controlsTimer;

  bool _isAtEnd(Duration position, Duration duration, bool isPlaying) {
    if (duration <= Duration.zero) return false;
    if (position >= duration) return true;
    if (!isPlaying &&
        duration.inMilliseconds > 500 &&
        (duration - position) <= const Duration(milliseconds: 600)) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addEventsListener(_onVideoEvent);
    final vpc = widget.controller.videoPlayerController;
    if (vpc != null && vpc.value.initialized) {
      final dur = vpc.value.duration ?? Duration.zero;
      final pos = vpc.value.position;
      final playing = vpc.value.isPlaying;
      if (_isAtEnd(pos, dur, playing)) {
        _isFinished = true;
        _isPlaying = false;
        _totalDuration = dur;
        _currentPosition = dur;
        _showControls = true;
      } else {
        _isPlaying = playing;
        _totalDuration = dur;
        _currentPosition = pos;
        if (_isPlaying) {
          _resetControlsTimer();
        }
      }
    } else {
      try {
        if (widget.controller.isPlaying() == true) {
          _isPlaying = true;
          _resetControlsTimer();
        }
      } catch (_) {}
    }
    _attachPlayerListener();
  }

  @override
  void didUpdateWidget(covariant CustomVideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeEventsListener(_onVideoEvent);
      widget.controller.addEventsListener(_onVideoEvent);
      _attachPlayerListener();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    widget.controller.removeEventsListener(_onVideoEvent);
    try {
      widget.controller.videoPlayerController?.removeListener(_videoListener);
    } catch (_) {}
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _attachPlayerListener() {
    final vpc = widget.controller.videoPlayerController;
    if (vpc != null) {
      vpc.removeListener(_videoListener);
      vpc.addListener(_videoListener);
      _updateProgress();
    }
  }

  void _videoListener() {
    if (mounted) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final vpc = widget.controller.videoPlayerController;
    if (vpc != null && vpc.value.initialized) {
      final duration = vpc.value.duration ?? Duration.zero;
      var position = vpc.value.position;
      final isPlaying = vpc.value.isPlaying;
      final atEnd = _isAtEnd(position, duration, isPlaying);

      if (atEnd) {
        position = duration;
      } else if (duration > Duration.zero && position >= duration) {
        position = duration;
      }
      if (_isFinished && duration > Duration.zero) {
        position = duration;
      }

      setState(() {
        _totalDuration = duration;
        _currentPosition = position;
        _isPlaying = isPlaying;
        if (atEnd) {
          _isFinished = true;
          _isPlaying = false;
          _showControls = true;
        }
      });

      if (atEnd) {
        _controlsTimer?.cancel();
      }
    }
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    final isEffectivelyFinished =
        _isFinished || _isAtEnd(_currentPosition, _totalDuration, _isPlaying);
    if (_isPlaying && !isEffectivelyFinished) {
      _controlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _isPlaying && !isEffectivelyFinished) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
    final isEffectivelyFinished =
        _isFinished || _isAtEnd(_currentPosition, _totalDuration, _isPlaying);
    if (_showControls && _isPlaying && !isEffectivelyFinished) {
      _resetControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void _onVideoEvent(BetterPlayerEvent event) {
    if (!mounted) return;
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        _attachPlayerListener();
        _resetControlsTimer();
        break;
      case BetterPlayerEventType.play:
        setState(() {
          _isPlaying = true;
          _isFinished = false;
        });
        _resetControlsTimer();
        break;
      case BetterPlayerEventType.pause:
        final vpc = widget.controller.videoPlayerController;
        bool ended = false;
        if (vpc != null && vpc.value.initialized) {
          final dur = vpc.value.duration ?? Duration.zero;
          final pos = vpc.value.position;
          if (_isAtEnd(pos, dur, false)) {
            ended = true;
          }
        }
        setState(() {
          _isPlaying = false;
          if (ended) {
            _isFinished = true;
            if (_totalDuration > Duration.zero) {
              _currentPosition = _totalDuration;
            }
          }
          _showControls = true;
        });
        _controlsTimer?.cancel();
        break;
      case BetterPlayerEventType.progress:
        _updateProgress();
        break;
      case BetterPlayerEventType.finished:
        setState(() {
          _isPlaying = false;
          _isFinished = true;
          if (_totalDuration > Duration.zero) {
            _currentPosition = _totalDuration;
          }
          _showControls = true;
        });
        _controlsTimer?.cancel();
        break;
      case BetterPlayerEventType.openFullscreen:
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        final vpc = widget.controller.videoPlayerController;
        if (vpc != null && vpc.value.initialized) {
          final dur = vpc.value.duration ?? Duration.zero;
          final pos = vpc.value.position;
          final playing = vpc.value.isPlaying;
          if (_isAtEnd(pos, dur, playing)) {
            _isFinished = true;
            _isPlaying = false;
            _totalDuration = dur;
            _currentPosition = dur;
          }
        }
        setState(() => _showControls = true);
        _resetControlsTimer();
        break;
      case BetterPlayerEventType.hideFullscreen:
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.portraitUp,
        ]);
        _attachPlayerListener();
        final vpcHide = widget.controller.videoPlayerController;
        if (vpcHide != null && vpcHide.value.initialized) {
          final dur = vpcHide.value.duration ?? Duration.zero;
          final pos = vpcHide.value.position;
          final playing = vpcHide.value.isPlaying;
          if (_isAtEnd(pos, dur, playing)) {
            _isFinished = true;
            _isPlaying = false;
            _totalDuration = dur;
            _currentPosition = dur;
          }
        }
        setState(() => _showControls = true);
        _resetControlsTimer();
        try {
          if (_isPlaying && widget.controller.isPlaying() != true) {
            widget.controller.play();
          }
        } catch (_) {}
        break;
      default:
        break;
    }
  }

  void _togglePlayPause() {
    final isAtEnd =
        _isFinished || _isAtEnd(_currentPosition, _totalDuration, _isPlaying);

    if (isAtEnd) {
      _replay();
    } else {
      bool isCurrentlyPlaying = _isPlaying;
      try {
        isCurrentlyPlaying = widget.controller.isPlaying() ?? _isPlaying;
      } catch (_) {}

      if (isCurrentlyPlaying) {
        try {
          widget.controller.pause().catchError((_) {});
        } catch (_) {}
      } else {
        try {
          widget.controller.play().catchError((_) {});
        } catch (_) {}
      }
    }
  }

  Future<void> _replay() async {
    setState(() {
      _isFinished = false;
      _isPlaying = true;
      _currentPosition = Duration.zero;
      _showControls = true;
    });
    try {
      await widget.controller.seekTo(Duration.zero).catchError((_) {});
      await widget.controller.play().catchError((_) {});
    } catch (_) {}
    _resetControlsTimer();
  }

  void _seekRelative(int seconds) {
    final maxSeconds = _totalDuration.inSeconds > 0
        ? _totalDuration.inSeconds
        : 0;
    final targetInSeconds = (_currentPosition.inSeconds + seconds).clamp(
      0,
      maxSeconds,
    );
    final target = Duration(seconds: targetInSeconds);
    final reachedEnd = maxSeconds > 0 && targetInSeconds >= maxSeconds;

    setState(() {
      _currentPosition = target;
      if (reachedEnd) {
        _isFinished = true;
        _isPlaying = false;
        _showControls = true;
      } else if (seconds < 0) {
        _isFinished = false;
      }
    });

    try {
      widget.controller.seekTo(target).catchError((_) {});
    } catch (_) {}
    _resetControlsTimer();
  }

  void _toggleFullScreen() {
    final willBeFullScreen = !widget.controller.isFullScreen;
    if (willBeFullScreen) {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]);
    }
    widget.controller.toggleFullScreen();
  }

  void _seekToPosition(double dx, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final width =
        box.size.width - (context.w(16) * 2); // Subtract horizontal padding
    final position = (dx - context.w(16)).clamp(0.0, width);
    final percentage = width > 0 ? position / width : 0.0;
    final newPosition = Duration(
      seconds: (_totalDuration.inSeconds * percentage).toInt(),
    );
    final reachedEnd =
        _totalDuration > Duration.zero && newPosition >= _totalDuration;

    setState(() {
      _currentPosition = newPosition;
      if (reachedEnd) {
        _isFinished = true;
        _isPlaying = false;
      } else {
        _isFinished = false;
      }
    });

    try {
      widget.controller.seekTo(newPosition).catchError((_) {});
    } catch (_) {}
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _showSettingsMenu() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isFullScreen = widget.controller.isFullScreen || isLandscape;
    List<BetterPlayerAsmsTrack> tracks = [];
    try {
      tracks = widget.controller.betterPlayerAsmsTracks;
    } catch (_) {}

    double currentSpeed = 1.0;
    try {
      currentSpeed =
          widget.controller.videoPlayerController?.value.speed ?? 1.0;
    } catch (_) {}

    String activeQualityLabel = "Auto";
    if (tracks.isNotEmpty) {
      final currentTrack = widget.controller.betterPlayerAsmsTrack;
      if (currentTrack != null) {
        activeQualityLabel = currentTrack.height == 0
            ? "Auto"
            : "${currentTrack.height}p";
      }
    } else {
      activeQualityLabel = "Auto (Original)";
    }

    final currentSpeedLabel = currentSpeed == 1.0 ? "1x" : "${currentSpeed}x";

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: isFullScreen ? 0.45 : 0.4),
      builder: (bottomSheetContext) {
        String activeView = 'main';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = isFullScreen;
            final bg = isDark ? const Color(0xFF212121) : Colors.white;
            final textColor = isDark ? Colors.white : AppColors.textCharcoal;
            final subTextColor = isDark ? Colors.white70 : AppColors.textGrey72;

            Widget content;
            if (activeView == 'speed') {
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      left: 6,
                      right: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: textColor,
                          iconSize: 20,
                          onPressed: () =>
                              setSheetState(() => activeView = 'main'),
                        ),
                        Text(
                          "Playback speed",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: isDark ? Colors.white12 : AppColors.cardBorder,
                  ),
                  ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                    final isSelected = (currentSpeed - speed).abs() < 0.05;
                    final label = speed == 1.0 ? "Normal" : "${speed}x";

                    return InkWell(
                      onTap: () {
                        widget.controller.setSpeed(speed);
                        Navigator.pop(bottomSheetContext);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : textColor,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            } else if (activeView == 'quality') {
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      left: 6,
                      right: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: textColor,
                          iconSize: 20,
                          onPressed: () =>
                              setSheetState(() => activeView = 'main'),
                        ),
                        Text(
                          "Quality",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: isDark ? Colors.white12 : AppColors.cardBorder,
                  ),
                  if (tracks.isNotEmpty) ...[
                    ...tracks.map((track) {
                      final isSelected =
                          widget.controller.betterPlayerAsmsTrack == track;
                      String label = track.height == 0
                          ? "Auto"
                          : "${track.height}p";
                      if (track.bitrate != null &&
                          track.bitrate! > 0 &&
                          track.height == 0) {
                        label = "Bitrate: ${track.bitrate}";
                      }

                      return InkWell(
                        onTap: () {
                          widget.controller.setTrack(track);
                          Navigator.pop(bottomSheetContext);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 18,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                label,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : textColor,
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ] else ...[
                    InkWell(
                      onTap: () => Navigator.pop(bottomSheetContext),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Auto (Original)",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              );
            } else {
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      margin: const EdgeInsets.only(top: 8, bottom: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 1. Quality Row
                  InkWell(
                    onTap: () => setSheetState(() => activeView = 'quality'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 20, color: textColor),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              "Quality",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            activeQualityLabel,
                            style: TextStyle(color: subTextColor, fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: subTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Playback Speed Row
                  InkWell(
                    onTap: () => setSheetState(() => activeView = 'speed'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            size: 20,
                            color: textColor,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              "Playback speed",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            currentSpeedLabel,
                            style: TextStyle(color: subTextColor, fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: subTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }

            return SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isFullScreen ? 350 : double.infinity,
                    maxHeight: isFullScreen ? 280 : 340,
                  ),
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: isFullScreen ? 12 : 0,
                      left: isFullScreen ? 16 : 0,
                      right: isFullScreen ? 16 : 0,
                    ),
                    child: Material(
                      color: bg,
                      borderRadius: isFullScreen
                          ? BorderRadius.circular(16)
                          : const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(child: content),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInsideBetterPlayer =
        context
            .findAncestorWidgetOfExactType<BetterPlayerControllerProvider>() !=
        null;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isFullScreen = widget.controller.isFullScreen || isLandscape;
    final isEffectivelyFinished =
        _isFinished || _isAtEnd(_currentPosition, _totalDuration, _isPlaying);

    final controlsStack = Stack(
      fit: StackFit.expand,
      children: [
        // 1. If not rendered inside BetterPlayerWithControls, host BetterPlayer surface directly
        if (!isInsideBetterPlayer)
          Positioned.fill(child: BetterPlayer(controller: widget.controller)),

        // 2. Full-surface tap detector: tapping anywhere shows/hides controls in normal & fullscreen modes
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleControlsVisibility,
          ),
        ),

        // 3. Interactive controls layer
        if (_showControls) ...[
          // Bottom subtle gradient overlay
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.80),
                    ],
                    stops: const [0.0, 0.40, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Center Action Cluster: [5s Rewind] -- [Play / Pause / Replay] -- [5s Forward]
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rewind 5 seconds
                GestureDetector(
                  onTap: () => _seekRelative(-5),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: isFullScreen ? 44.0 : 38.0,
                    height: isFullScreen ? 44.0 : 38.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.35),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.replay_5_rounded,
                      size: isFullScreen ? 24.0 : 22.0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: isFullScreen ? 44.0 : 28.0),

                // Center Play / Pause / Replay Button
                GestureDetector(
                  onTap: () {
                    _togglePlayPause();
                    if (_isPlaying) {
                      _resetControlsTimer();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: isFullScreen ? 56.0 : 50.0,
                    height: isFullScreen ? 56.0 : 50.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.35),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isEffectivelyFinished
                          ? Icons.replay_rounded
                          : (_isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded),
                      size: isFullScreen ? 34.0 : 30.0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: isFullScreen ? 44.0 : 28.0),

                // Forward 5 seconds
                GestureDetector(
                  onTap: () => _seekRelative(5),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: isFullScreen ? 44.0 : 38.0,
                    height: isFullScreen ? 44.0 : 38.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.35),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.forward_5_rounded,
                      size: isFullScreen ? 24.0 : 22.0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar (Progress bar on top, with Heading, Timestamps, Settings & Fullscreen below it at the bottom end)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              bottom: isFullScreen,
              left: isFullScreen,
              right: isFullScreen,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isFullScreen ? 20.0 : 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Scrubber progress bar
                    GestureDetector(
                      onTapDown: (details) {
                        _seekToPosition(details.localPosition.dx, context);
                      },
                      onHorizontalDragUpdate: (details) {
                        _seekToPosition(details.localPosition.dx, context);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100),
                          ),
                          child: SizedBox(
                            height: 3.5,
                            child: LinearProgressIndicator(
                              value: _totalDuration.inSeconds > 0
                                  ? (_currentPosition.inSeconds /
                                            _totalDuration.inSeconds)
                                        .clamp(0.0, 1.0)
                                  : 0.0,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.35,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 2. Bottom Row: Heading (left) + Timestamps + Settings + Fullscreen (right)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: isFullScreen ? 10.0 : 5.0,
                        top: 2.0,
                      ),
                      child: Row(
                        children: [
                          // Heading (Course Title)
                          if (widget.title != null && widget.title!.isNotEmpty)
                            Expanded(
                              child: Text(
                                widget.title!,
                                style: AppTextStyles.textStyle_500_14.copyWith(
                                  fontSize: isFullScreen ? 13.0 : 11.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.70,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            const Spacer(),

                          const SizedBox(width: 10),

                          // Timer: Current / Total
                          Text(
                            _formatDuration(_currentPosition),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isFullScreen ? 12.0 : 11.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' / ${_formatDuration(_totalDuration)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: isFullScreen ? 12.0 : 11.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Settings button
                          GestureDetector(
                            onTap: _showSettingsMenu,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                                size: isFullScreen ? 20.0 : 18.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Fullscreen button
                          GestureDetector(
                            onTap: _toggleFullScreen,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                isFullScreen
                                    ? Icons.fullscreen_exit_rounded
                                    : Icons.fullscreen_rounded,
                                color: Colors.white,
                                size: isFullScreen ? 22.0 : 20.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );

    // In fullscreen or when embedded inside BetterPlayerWithControls, return directly
    if (isFullScreen || isInsideBetterPlayer) {
      return Container(color: Colors.transparent, child: controlsStack);
    }

    // In normal standalone mode, wrap in fixed 16:9 aspect ratio and rounded card clip
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(color: Colors.black, child: controlsStack),
      ),
    );
  }
}
