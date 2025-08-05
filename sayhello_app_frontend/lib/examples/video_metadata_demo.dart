import 'package:flutter/material.dart';
import '../services/video_metadata_service.dart';

/// Example usage of VideoMetadataService
/// This file demonstrates how to use the video metadata extraction functionality

class VideoMetadataDemo extends StatefulWidget {
  const VideoMetadataDemo({super.key});

  @override
  State<VideoMetadataDemo> createState() => _VideoMetadataDemoState();
}

class _VideoMetadataDemoState extends State<VideoMetadataDemo> {
  VideoSummary? _summary;
  bool _isLoading = false;

  // Example: How to use the service with your own video URLs
  final List<String> _yourVideoUrls = [
    // Replace these URLs with your actual video URLs
    'https://your-server.com/videos/lesson1.mp4',
    'https://your-server.com/videos/lesson2.mp4',
    'https://your-server.com/videos/lesson3.mp4',

    // For testing, you can use these sample URLs:
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  ];

  final List<String> _videoTitles = [
    'Introduction to Flutter',
    'Advanced Widget Concepts',
    'State Management',
    'Sample Video 1',
    'Sample Video 2',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Metadata Demo'),
        backgroundColor: Color(0xFF7A54FF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video Metadata Extraction',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This demo shows how to extract duration and file size from video URLs. '
                      'Replace the URLs in _yourVideoUrls with your actual video links.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Load button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadVideoMetadata,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7A54FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                _isLoading ? 'Loading...' : 'Extract Video Metadata',
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),

            // Results
            if (_summary != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Total Videos: ${_summary!.totalVideos}'),
                      Text('Valid Videos: ${_summary!.validVideos}'),
                      Text('Failed Videos: ${_summary!.failedVideos}'),
                      Text(
                        'Total Duration: ${_summary!.formattedTotalDuration}',
                      ),
                      Text('Total Size: ${_summary!.formattedTotalSize}'),
                      Text(
                        'Success Rate: ${(_summary!.successRate * 100).toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Individual video details
              Expanded(
                child: ListView.builder(
                  itemCount: _summary!.videos.length,
                  itemBuilder: (context, index) {
                    final video = _summary!.videos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          video.isValid ? Icons.check_circle : Icons.error,
                          color: video.isValid ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          video.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: video.isValid
                            ? Text(
                                'Duration: ${video.formattedDuration} • Size: ${video.formattedSize}',
                              )
                            : Text(
                                'Error: ${video.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                        trailing: video.isValid
                            ? const Icon(Icons.play_circle_outline)
                            : const Icon(Icons.refresh),
                        onTap: video.isValid
                            ? () => _showVideoDetails(video)
                            : () => _retryVideo(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _loadVideoMetadata() async {
    setState(() {
      _isLoading = true;
      _summary = null;
    });

    try {
      // Example: Extract metadata from multiple videos
      final videoMetadataList =
          await VideoMetadataService.extractMultipleVideoMetadata(
            _yourVideoUrls,
            titles: _videoTitles,
            onProgress: (completed, total) {
              // Optional: Show progress
              print('Progress: $completed/$total videos processed');
            },
          );

      // Calculate summary
      final summary = VideoMetadataService.calculateVideoSummary(
        videoMetadataList,
      );

      setState(() {
        _summary = summary;
        _isLoading = false;
      });

      // Show completion message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Processed ${summary.totalVideos} videos. '
            '${summary.validVideos} successful, ${summary.failedVideos} failed.',
          ),
          backgroundColor: summary.failedVideos == 0
              ? Colors.green
              : Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _retryVideo(int index) async {
    if (index >= _yourVideoUrls.length || _summary == null) return;

    try {
      final videoMetadata = await VideoMetadataService.extractVideoMetadata(
        _yourVideoUrls[index],
        title: index < _videoTitles.length ? _videoTitles[index] : null,
      );

      // Update the specific video
      final updatedVideos = List<VideoMetadata>.from(_summary!.videos);
      updatedVideos[index] = videoMetadata;

      final updatedSummary = VideoMetadataService.calculateVideoSummary(
        updatedVideos,
      );

      setState(() {
        _summary = updatedSummary;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            videoMetadata.isValid
                ? '✅ Video metadata loaded'
                : '❌ Still failed to load',
          ),
          backgroundColor: videoMetadata.isValid ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Retry failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showVideoDetails(VideoMetadata video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(video.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('URL: ${video.url}'),
            const SizedBox(height: 8),
            Text('Duration: ${video.formattedDuration}'),
            Text('File Size: ${video.formattedSize}'),
            Text('Size (bytes): ${video.fileSizeBytes}'),
            Text('Duration (seconds): ${video.duration.inSeconds}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// How to integrate this into your existing app:
/// 
/// 1. Add the dio package to pubspec.yaml:
///    ```yaml
///    dependencies:
///      dio: ^5.4.0
///    ```
/// 
/// 2. Create your list of video URLs:
///    ```dart
///    final List<String> myVideoUrls = [
///      'https://example.com/video1.mp4',
///      'https://example.com/video2.mp4',
///    ];
///    ```
/// 
/// 3. Extract metadata:
///    ```dart
///    final videoMetadataList = await VideoMetadataService.extractMultipleVideoMetadata(
///      myVideoUrls,
///      titles: ['Video 1', 'Video 2'],
///    );
///    
///    final summary = VideoMetadataService.calculateVideoSummary(videoMetadataList);
///    
///    print('Total duration: ${summary.formattedTotalDuration}');
///    print('Total size: ${summary.formattedTotalSize}');
///    ```
/// 
/// 4. Use the data in your UI:
///    ```dart
///    Text('${summary.validVideos} videos'),
///    Text('Total: ${summary.formattedTotalDuration}'),
///    Text('Size: ${summary.formattedTotalSize}'),
///    ```
