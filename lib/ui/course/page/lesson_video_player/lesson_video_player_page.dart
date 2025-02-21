import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/extension/duration_extension.dart';
import 'package:gap/gap.dart';
import 'package:video_player/video_player.dart';

import '../../../../base/constants/ui/app_colors.dart';
import '../../../../resource/generated/assets.gen.dart';

@RoutePage()
class LessonVideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const LessonVideoPlayerPage({super.key, required this.videoUrl});

  @override
  State<LessonVideoPlayerPage> createState() => _LessonVideoPlayerPageState();
}

class _LessonVideoPlayerPageState extends State<LessonVideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _showOverlay = true;
  bool _isFullscreen = false;
  Timer? _hideControlsTimer;


  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });

    _controller.addListener(() {
      setState(() {});
    });

    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideControlsTimer?.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showOverlay = false;
      });
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _enterFullscreen() {
    setState(() {
      _isFullscreen = true;
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  void _exitFullscreen() {
    setState(() {
      _isFullscreen = false;
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleOverlay,
            child: Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          ),
          if (_showOverlay && !_isFullscreen)
            Positioned(
              top: kToolbarHeight + 15,
              left: Dimens.paddingHorizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Assets.icons.arrowLeft.svg(colorFilter: ColorFilter.mode(AppColors.current.otherWhite, BlendMode.srcIn)),
                    onPressed: () => AutoRouter.of(context).back(),
                  ),
                  const Gap(Dimens.paddingHorizontalLarge)
                ],
              ),
            ),
          if (_showOverlay)
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(blurRadius: 8, color: Colors.white.withOpacity(0.8))]),
                  child: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: AppColors.current.primary500,
                  ),
                ),
              ),
            ),
          if (_showOverlay)
            Positioned(
              bottom: _isFullscreen ? 15 : MediaQuery.sizeOf(context).height / 3,
              left: _isFullscreen ? 100 : 24,
              right: _isFullscreen ? 100 : 24,
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _controller.value.position.formatDuration(),
                      style: AppTextStyles.bodySmallSemiBold.withWhiteColor(),
                    ),
                    const Gap(12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          padding: EdgeInsets.zero,
                          colors: VideoProgressColors(
                            playedColor: AppColors.current.primary500,
                            bufferedColor: AppColors.current.greyscale200,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Text(
                      _controller.value.duration.formatDuration(),
                      style: AppTextStyles.bodySmallSemiBold.withWhiteColor(),
                    ),
                    const Gap(12),
                    GestureDetector(
                      onTap: () {
                        _isFullscreen ? _exitFullscreen() : _enterFullscreen();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: _isFullscreen
                          ? CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Assets.icons.fullscreen.svg(),
                            )
                          : Assets.icons.fullscreen.svg(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
