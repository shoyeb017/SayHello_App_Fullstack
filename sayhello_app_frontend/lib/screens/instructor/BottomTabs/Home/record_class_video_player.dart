import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../../../l10n/app_localizations.dart';

// Instructor Video Player for Recorded Classes
class InstructorRecordClassVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String thumbnail;
  final String duration;

  const InstructorRecordClassVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.thumbnail,
    required this.duration,
  });

  @override
  State<InstructorRecordClassVideoPlayer> createState() =>
      _InstructorRecordClassVideoPlayerState();
}

class _InstructorRecordClassVideoPlayerState
    extends State<InstructorRecordClassVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isControlsVisible = true;
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo();
    });
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_controller != null) {
        await _controller!.dispose();
      }

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      _controller!.addListener(_videoListener);

      await _controller!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
            'Video loading timeout - Check your internet connection',
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
        _hideControlsAfterDelay();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = false;
        });

        String errorMessage = e.toString();
        if (errorMessage.contains('timeout')) {
          errorMessage = AppLocalizations.of(context)!.connectionTimeoutMessage;
        } else if (errorMessage.contains('404')) {
          errorMessage = AppLocalizations.of(context)!.videoNotFoundMessage;
        } else if (errorMessage.contains('network')) {
          errorMessage = AppLocalizations.of(context)!.networkErrorMessage;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _initializeVideo,
            ),
          ),
        );
      }
    }
  }

  void _videoListener() {
    if (mounted && _controller != null) {
      setState(() {});

      if (_controller!.value.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.videoErrorGeneric(
                _controller!.value.errorDescription ??
                    AppLocalizations.of(context)!.unknownError,
              ),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
        _hideControlsAfterDelay();
      }
    });
  }

  void _skipForward() {
    if (_controller == null || !_isInitialized) return;

    final currentPosition = _controller!.value.position;
    final newPosition = currentPosition + const Duration(seconds: 10);
    final duration = _controller!.value.duration;

    if (newPosition < duration) {
      _controller!.seekTo(newPosition);
    } else {
      _controller!.seekTo(duration);
    }
  }

  void _skipBackward() {
    if (_controller == null || !_isInitialized) return;

    final currentPosition = _controller!.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);

    if (newPosition > Duration.zero) {
      _controller!.seekTo(newPosition);
    } else {
      _controller!.seekTo(Duration.zero);
    }
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    if (_isControlsVisible &&
        _controller != null &&
        _controller!.value.isPlaying) {
      _hideControlsAfterDelay();
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds % 60);
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.videoInformation),
                      Text(
                        AppLocalizations.of(context)!.videoTitle(widget.title),
                      ),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.videoDurationInfo(widget.duration),
                      ),
                      Text(
                        AppLocalizations.of(context)!.videoStatusInfo(
                          _isInitialized
                              ? AppLocalizations.of(context)!.videoStatusLoaded
                              : AppLocalizations.of(
                                  context,
                                )!.videoStatusLoading,
                        ),
                      ),
                      if (_isInitialized && _controller != null)
                        Text(
                          AppLocalizations.of(context)!.videoResolutionInfo(
                            _controller!.value.size.width.toInt(),
                            _controller!.value.size.height.toInt(),
                          ),
                        ),
                    ],
                  ),
                  backgroundColor: Color(0xFF7A54FF),
                  duration: Duration(seconds: 4),
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
            tooltip: AppLocalizations.of(context)!.videoInfo,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video Player Area
            Center(
              child: _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF7A54FF),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.loadingVideo,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : _isInitialized && _controller != null
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.failedToLoadVideo,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _initializeVideo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF7A54FF),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Retry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Controls Overlay
            if (_isControlsVisible && _isInitialized)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: Column(
                  children: [
                    const Spacer(),

                    // Main Control Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Skip Backward
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _skipBackward,
                            icon: const Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),

                        const SizedBox(width: 40),

                        // Play/Pause Button
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFF7A54FF).withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF7A54FF).withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _controller != null &&
                                      _controller!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),

                        const SizedBox(width: 40),

                        // Skip Forward
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _skipForward,
                            icon: const Icon(
                              Icons.forward_10,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Progress Bar and Controls
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Progress Bar
                          if (_controller != null)
                            VideoProgressIndicator(
                              _controller!,
                              allowScrubbing: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              colors: VideoProgressColors(
                                playedColor: Color(0xFF7A54FF),
                                bufferedColor: Color(
                                  0xFF7A54FF,
                                ).withOpacity(0.3),
                                backgroundColor: Colors.white.withOpacity(0.1),
                              ),
                            ),

                          // Time Display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _controller != null
                                    ? _formatDuration(
                                        _controller!.value.position,
                                      )
                                    : '00:00',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _controller != null
                                    ? _formatDuration(
                                        _controller!.value.duration,
                                      )
                                    : widget.duration,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.thumbnail.isNotEmpty)
                        Container(
                          width: 200,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(widget.thumbnail),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF7A54FF),
                        ),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.preparingVideo,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
