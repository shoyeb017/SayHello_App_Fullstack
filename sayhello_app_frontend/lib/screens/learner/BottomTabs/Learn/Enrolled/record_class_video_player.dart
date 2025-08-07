import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../../../l10n/app_localizations.dart';

// Modern Video Player for Record Class - Uses video_player package
class RecordClassVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String thumbnail;
  final String duration;

  const RecordClassVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.thumbnail,
    required this.duration,
  });

  @override
  State<RecordClassVideoPlayer> createState() => _RecordClassVideoPlayerState();
}

class _RecordClassVideoPlayerState extends State<RecordClassVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isControlsVisible = true;
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Ensure proper initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo();
    });
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Cleanup previous controller if exists
      if (_controller != null) {
        await _controller!.dispose();
      }

      // Proper network URL initialization for mobile platforms
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      // Add error listener
      _controller!.addListener(_videoListener);

      // Initialize with proper error handling and timeout
      await _controller!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(AppLocalizations.of(context)!.videoLoadingTimeout);
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });

        // Auto-hide controls after initialization
        _hideControlsAfterDelay();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = false;
        });

        // Show detailed error message
        String errorMessage = e.toString();
        if (errorMessage.contains('timeout')) {
          errorMessage = AppLocalizations.of(context)!.connectionTimeout;
        } else if (errorMessage.contains('404')) {
          errorMessage = AppLocalizations.of(context)!.videoNotFound;
        } else if (errorMessage.contains('network')) {
          errorMessage = AppLocalizations.of(context)!.networkError;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.retryButton,
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

      // Handle video errors
      if (_controller!.value.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.videoErrorMessage(
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
                        '${AppLocalizations.of(context)!.videoTitle}: ${widget.title}',
                      ),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.videoDuration(widget.duration),
                      ),
                      Text(
                        AppLocalizations.of(context)!.videoStatus(
                          _isInitialized
                              ? AppLocalizations.of(context)!.videoLoaded
                              : AppLocalizations.of(context)!.loadingVideo,
                        ),
                      ),
                      if (_isInitialized && _controller != null)
                        Text(
                          AppLocalizations.of(context)!.videoResolution(
                            '${_controller!.value.size.width.toInt()}x${_controller!.value.size.height.toInt()}',
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
                            label: Text(
                              AppLocalizations.of(context)!.retryButton,
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
                                  color: Color(0xFF7A54FF).withOpacity(0.4),
                                  blurRadius: 15,
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
                                bufferedColor: Colors.white.withOpacity(0.3),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _controller != null
                                    ? _formatDuration(
                                        _controller!.value.duration,
                                      )
                                    : '00:00',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Additional Controls
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Volume/Mute
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (_controller != null) {
                                  setState(() {
                                    _controller!.setVolume(
                                      _controller!.value.volume == 0
                                          ? 1.0
                                          : 0.0,
                                    );
                                  });
                                }
                              },
                              icon: Icon(
                                _controller != null &&
                                        _controller!.value.volume == 0
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),

                          // Fullscreen Toggle
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                // Fullscreen functionality can be added here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.fullscreenMode,
                                    ),
                                    backgroundColor: Color(0xFF7A54FF),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),

                          // Settings
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.playbackSettings,
                                        ),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.playbackSpeed('1.0'),
                                        ),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.playbackQuality(
                                            AppLocalizations.of(
                                              context,
                                            )!.playbackQualityAuto,
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.playbackVolume(
                                            _controller != null
                                                ? (_controller!.value.volume *
                                                          100)
                                                      .toInt()
                                                : 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Color(0xFF7A54FF),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
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

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:video_player/video_player.dart';
// import '../../../../../l10n/app_localizations.dart';

// // Modern Video Player for Record Class - Uses video_player package
// class RecordClassVideoPlayer extends StatefulWidget {
//   final String videoUrl;
//   final String title;
//   final String thumbnail;
//   final String duration;

//   const RecordClassVideoPlayer({
//     super.key,
//     required this.videoUrl,
//     required this.title,
//     required this.thumbnail,
//     required this.duration,
//   });

//   @override
//   State<RecordClassVideoPlayer> createState() => _RecordClassVideoPlayerState();
// }

// class _RecordClassVideoPlayerState extends State<RecordClassVideoPlayer> {
//   VideoPlayerController? _controller;
//   bool _isControlsVisible = true;
//   bool _isInitialized = false;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     // Ensure proper initialization
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeVideo();
//     });
//   }

//   Future<void> _initializeVideo() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       // Cleanup previous controller if exists
//       if (_controller != null) {
//         await _controller!.dispose();
//       }

//       // Proper network URL initialization for mobile platforms
//       _controller = VideoPlayerController.networkUrl(
//         Uri.parse(widget.videoUrl),
//         videoPlayerOptions: VideoPlayerOptions(
//           mixWithOthers: false,
//           allowBackgroundPlayback: false,
//         ),
//       );

//       // Add error listener
//       _controller!.addListener(_videoListener);

//       // Initialize with proper error handling and timeout
//       await _controller!.initialize().timeout(
//         const Duration(seconds: 15),
//         onTimeout: () {
//           throw Exception(AppLocalizations.of(context)!.videoLoadingTimeout);
//         },
//       );

//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//           _isLoading = false;
//         });

//         // Auto-hide controls after initialization
//         _hideControlsAfterDelay();
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _isInitialized = false;
//         });

//         // Show detailed error message
//         String errorMessage = e.toString();
//         if (errorMessage.contains('timeout')) {
//           errorMessage = AppLocalizations.of(context)!.connectionTimeout;
//         } else if (errorMessage.contains('404')) {
//           errorMessage = AppLocalizations.of(context)!.videoNotFound;
//         } else if (errorMessage.contains('network')) {
//           errorMessage = AppLocalizations.of(context)!.networkError;
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ $errorMessage'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 5),
//             action: SnackBarAction(
//               label: AppLocalizations.of(context)!.retryButton,
//               textColor: Colors.white,
//               onPressed: _initializeVideo,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   void _videoListener() {
//     if (mounted && _controller != null) {
//       setState(() {});

//       // Handle video errors
//       if (_controller!.value.hasError) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               '❌ ${_controller!.value.errorDescription ?? AppLocalizations.of(context)!.unknownError}',
//             ),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.removeListener(_videoListener);
//     _controller?.dispose();
//     super.dispose();
//   }

//   void _togglePlayPause() {
//     if (_controller == null || !_isInitialized) return;

//     setState(() {
//       if (_controller!.value.isPlaying) {
//         _controller!.pause();
//       } else {
//         _controller!.play();
//         _hideControlsAfterDelay();
//       }
//     });
//   }

//   void _skipForward() {
//     if (_controller == null || !_isInitialized) return;

//     final currentPosition = _controller!.value.position;
//     final newPosition = currentPosition + const Duration(seconds: 10);
//     final duration = _controller!.value.duration;

//     if (newPosition < duration) {
//       _controller!.seekTo(newPosition);
//     } else {
//       _controller!.seekTo(duration);
//     }
//   }

//   void _skipBackward() {
//     if (_controller == null || !_isInitialized) return;

//     final currentPosition = _controller!.value.position;
//     final newPosition = currentPosition - const Duration(seconds: 10);

//     if (newPosition > Duration.zero) {
//       _controller!.seekTo(newPosition);
//     } else {
//       _controller!.seekTo(Duration.zero);
//     }
//   }

//   void _toggleControls() {
//     setState(() {
//       _isControlsVisible = !_isControlsVisible;
//     });
//     if (_isControlsVisible &&
//         _controller != null &&
//         _controller!.value.isPlaying) {
//       _hideControlsAfterDelay();
//     }
//   }

//   void _hideControlsAfterDelay() {
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted && _controller != null && _controller!.value.isPlaying) {
//         setState(() {
//           _isControlsVisible = false;
//         });
//       }
//     });
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes);
//     final seconds = twoDigits(duration.inSeconds % 60);
//     return '$minutes:$seconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           widget.title,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(AppLocalizations.of(context)!.videoInformation),
//                       Text(
//                         '${AppLocalizations.of(context)!.videoTitle}: ${widget.title}',
//                       ),
//                       Text(
//                         '${AppLocalizations.of(context)!.duration}: ${widget.duration}',
//                       ),
//                       Text(
//                         '${AppLocalizations.of(context)!.status}: ${_isInitialized ? AppLocalizations.of(context)!.videoLoaded : AppLocalizations.of(context)!.loadingVideo}',
//                       ),
//                       if (_isInitialized && _controller != null)
//                         Text(
//                           'Resolution: ${_controller!.value.size.width.toInt()}x${_controller!.value.size.height.toInt()}',
//                         ),
//                     ],
//                   ),
//                   backgroundColor: Color(0xFF7A54FF),
//                   duration: Duration(seconds: 4),
//                 ),
//               );
//             },
//             icon: const Icon(Icons.info_outline),
//             tooltip: AppLocalizations.of(context)!.videoInfo,
//           ),
//         ],
//       ),
//       body: GestureDetector(
//         onTap: _toggleControls,
//         child: Stack(
//           children: [
//             // Video Player Area
//             Center(
//               child: _isLoading
//                   ? Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Color(0xFF7A54FF),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           AppLocalizations.of(context)!.loadingVideo,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     )
//                   : _isInitialized && _controller != null
//                   ? AspectRatio(
//                       aspectRatio: _controller!.value.aspectRatio,
//                       child: VideoPlayer(_controller!),
//                     )
//                   : Container(
//                       width: double.infinity,
//                       height: 300,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[900],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.error_outline,
//                             color: Colors.white,
//                             size: 48,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             AppLocalizations.of(context)!.failedToLoadVideo,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           ElevatedButton.icon(
//                             onPressed: _initializeVideo,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color(0xFF7A54FF),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 20,
//                                 vertical: 10,
//                               ),
//                             ),
//                             icon: const Icon(
//                               Icons.refresh,
//                               color: Colors.white,
//                             ),
//                             label: Text(
//                               AppLocalizations.of(context)!.retryButton,
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//             ),

//             // Controls Overlay
//             if (_isControlsVisible && _isInitialized)
//               Container(
//                 color: Colors.black.withOpacity(0.4),
//                 child: Column(
//                   children: [
//                     const Spacer(),

//                     // Main Control Buttons
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Skip Backward
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.6),
//                             shape: BoxShape.circle,
//                           ),
//                           child: IconButton(
//                             onPressed: _skipBackward,
//                             icon: const Icon(
//                               Icons.replay_10,
//                               color: Colors.white,
//                               size: 32,
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 40),

//                         // Play/Pause Button
//                         GestureDetector(
//                           onTap: _togglePlayPause,
//                           child: Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Color(0xFF7A54FF).withOpacity(0.9),
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Color(0xFF7A54FF).withOpacity(0.4),
//                                   blurRadius: 15,
//                                   spreadRadius: 2,
//                                 ),
//                               ],
//                             ),
//                             child: Icon(
//                               _controller != null &&
//                                       _controller!.value.isPlaying
//                                   ? Icons.pause
//                                   : Icons.play_arrow,
//                               color: Colors.white,
//                               size: 48,
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 40),

//                         // Skip Forward
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.6),
//                             shape: BoxShape.circle,
//                           ),
//                           child: IconButton(
//                             onPressed: _skipForward,
//                             icon: const Icon(
//                               Icons.forward_10,
//                               color: Colors.white,
//                               size: 32,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 30),

//                     // Progress Bar and Controls
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Column(
//                         children: [
//                           // Progress Bar
//                           if (_controller != null)
//                             VideoProgressIndicator(
//                               _controller!,
//                               allowScrubbing: true,
//                               padding: const EdgeInsets.symmetric(vertical: 8),
//                               colors: VideoProgressColors(
//                                 playedColor: Color(0xFF7A54FF),
//                                 bufferedColor: Colors.white.withOpacity(0.3),
//                                 backgroundColor: Colors.white.withOpacity(0.1),
//                               ),
//                             ),

//                           // Time Display
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 _controller != null
//                                     ? _formatDuration(
//                                         _controller!.value.position,
//                                       )
//                                     : '00:00',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               Text(
//                                 _controller != null
//                                     ? _formatDuration(
//                                         _controller!.value.duration,
//                                       )
//                                     : '00:00',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     // Additional Controls
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           // Volume/Mute
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.6),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               onPressed: () {
//                                 if (_controller != null) {
//                                   setState(() {
//                                     _controller!.setVolume(
//                                       _controller!.value.volume == 0
//                                           ? 1.0
//                                           : 0.0,
//                                     );
//                                   });
//                                 }
//                               },
//                               icon: Icon(
//                                 _controller != null &&
//                                         _controller!.value.volume == 0
//                                     ? Icons.volume_off
//                                     : Icons.volume_up,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                             ),
//                           ),

//                           // Fullscreen Toggle
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.6),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               onPressed: () {
//                                 // Fullscreen functionality can be added here
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       AppLocalizations.of(
//                                         context,
//                                       )!.fullscreenMode,
//                                     ),
//                                     backgroundColor: Color(0xFF7A54FF),
//                                     duration: Duration(seconds: 1),
//                                   ),
//                                 );
//                               },
//                               icon: const Icon(
//                                 Icons.fullscreen,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                             ),
//                           ),

//                           // Settings
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.6),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               onPressed: () {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           AppLocalizations.of(
//                                             context,
//                                           )!.playbackSettings,
//                                         ),
//                                         Text(
//                                           '• Speed: 1.0x',
//                                         ),
//                                         Text(
//                                           '• Quality: ${AppLocalizations.of(context)!.qualityAuto}',
//                                         ),
//                                         Text(
//                                           '• Volume: ${_controller != null ? (_controller!.value.volume * 100).toInt() : 0}%',
//                                         ),
//                                       ],
//                                     ),
//                                     backgroundColor: Color(0xFF7A54FF),
//                                     duration: Duration(seconds: 3),
//                                   ),
//                                 );
//                               },
//                               icon: const Icon(
//                                 Icons.settings,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),

//             // Loading Overlay
//             if (_isLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.8),
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       if (widget.thumbnail.isNotEmpty)
//                         Container(
//                           width: 200,
//                           height: 120,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             image: DecorationImage(
//                               image: NetworkImage(widget.thumbnail),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       const SizedBox(height: 20),
//                       CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           Color(0xFF7A54FF),
//                         ),
//                         strokeWidth: 3,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         AppLocalizations.of(context)!.preparingVideo,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         widget.title,
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.7),
//                           fontSize: 14,
//                         ),
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
