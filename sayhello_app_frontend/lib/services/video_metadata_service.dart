import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoMetadata {
  final String url;
  final Duration duration;
  final int fileSizeBytes;
  final String title;
  final bool isValid;
  final String? error;

  VideoMetadata({
    required this.url,
    required this.duration,
    required this.fileSizeBytes,
    required this.title,
    this.isValid = true,
    this.error,
  });

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedSize {
    if (fileSizeBytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = fileSizeBytes.toDouble();
    int suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${suffixes[suffixIndex]}';
  }

  factory VideoMetadata.error(
    String url,
    String error, [
    String title = 'Unknown',
  ]) {
    return VideoMetadata(
      url: url,
      duration: Duration.zero,
      fileSizeBytes: 0,
      title: title,
      isValid: false,
      error: error,
    );
  }
}

class VideoMetadataService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'User-Agent': 'Flutter Video Player App'},
    ),
  );

  /// Extracts metadata from a single video URL
  static Future<VideoMetadata> extractVideoMetadata(
    String videoUrl, {
    String? title,
  }) async {
    try {
      // Get file size from HTTP HEAD request
      final fileSizeBytes = await _getVideoFileSize(videoUrl);

      // Get duration using video_player
      final duration = await _getVideoDuration(videoUrl);

      return VideoMetadata(
        url: videoUrl,
        duration: duration,
        fileSizeBytes: fileSizeBytes,
        title: title ?? _extractTitleFromUrl(videoUrl),
      );
    } catch (e) {
      debugPrint('Error extracting metadata for $videoUrl: $e');
      return VideoMetadata.error(
        videoUrl,
        e.toString(),
        title ?? _extractTitleFromUrl(videoUrl),
      );
    }
  }

  /// Extracts metadata from multiple video URLs concurrently
  static Future<List<VideoMetadata>> extractMultipleVideoMetadata(
    List<String> videoUrls, {
    List<String>? titles,
    Function(int completed, int total)? onProgress,
  }) async {
    final List<VideoMetadata> results = [];
    int completed = 0;

    // Process videos in batches to avoid overwhelming the system
    const batchSize = 3;
    for (int i = 0; i < videoUrls.length; i += batchSize) {
      final batch = videoUrls.skip(i).take(batchSize).toList();
      final batchTitles = titles?.skip(i).take(batchSize).toList();

      final batchFutures = batch.asMap().entries.map((entry) {
        final index = entry.key;
        final url = entry.value;
        final title = batchTitles?[index];

        return extractVideoMetadata(url, title: title).then((metadata) {
          completed++;
          onProgress?.call(completed, videoUrls.length);
          return metadata;
        });
      });

      final batchResults = await Future.wait(batchFutures);
      results.addAll(batchResults);
    }

    return results;
  }

  /// Calculates total duration and size from video metadata list
  static VideoSummary calculateVideoSummary(List<VideoMetadata> videos) {
    final validVideos = videos.where((v) => v.isValid).toList();

    final totalDuration = validVideos.fold<Duration>(
      Duration.zero,
      (sum, video) => sum + video.duration,
    );

    final totalSizeBytes = validVideos.fold<int>(
      0,
      (sum, video) => sum + video.fileSizeBytes,
    );

    return VideoSummary(
      totalVideos: videos.length,
      validVideos: validVideos.length,
      totalDuration: totalDuration,
      totalSizeBytes: totalSizeBytes,
      videos: videos,
    );
  }

  /// Gets file size using HTTP HEAD request
  static Future<int> _getVideoFileSize(String videoUrl) async {
    try {
      final response = await _dio.head(videoUrl);
      final contentLength = response.headers.value('content-length');

      if (contentLength != null) {
        return int.parse(contentLength);
      }

      // Fallback: Try GET request with range header to get partial content
      final rangeResponse = await _dio.get(
        videoUrl,
        options: Options(
          headers: {'Range': 'bytes=0-1023'}, // Get first 1KB
          validateStatus: (status) => status == 206 || status == 200,
        ),
      );

      final contentRange = rangeResponse.headers.value('content-range');
      if (contentRange != null) {
        // Parse "bytes 0-1023/12345678" format
        final match = RegExp(r'bytes \d+-\d+/(\d+)').firstMatch(contentRange);
        if (match != null) {
          return int.parse(match.group(1)!);
        }
      }

      // Last resort: estimate based on partial content
      final data = rangeResponse.data;
      if (data is List<int>) {
        return data.length * 1000; // Very rough estimate
      }

      return 0;
    } catch (e) {
      debugPrint('Error getting file size for $videoUrl: $e');
      return 0; // Return 0 if we can't determine size
    }
  }

  /// Gets video duration using video_player
  static Future<Duration> _getVideoDuration(String videoUrl) async {
    VideoPlayerController? controller;

    try {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      await controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Video initialization timeout'),
      );

      return controller.value.duration;
    } catch (e) {
      debugPrint('Error getting duration for $videoUrl: $e');
      return Duration.zero;
    } finally {
      controller?.dispose();
    }
  }

  /// Extracts a title from video URL
  static String _extractTitleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      if (segments.isNotEmpty) {
        final fileName = segments.last;
        // Remove file extension and decode
        final nameWithoutExt = fileName.contains('.')
            ? fileName.substring(0, fileName.lastIndexOf('.'))
            : fileName;

        return Uri.decodeComponent(
          nameWithoutExt,
        ).replaceAll(RegExp(r'[_-]'), ' ').trim();
      }

      return 'Video ${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'Unknown Video';
    }
  }
}

class VideoSummary {
  final int totalVideos;
  final int validVideos;
  final Duration totalDuration;
  final int totalSizeBytes;
  final List<VideoMetadata> videos;

  VideoSummary({
    required this.totalVideos,
    required this.validVideos,
    required this.totalDuration,
    required this.totalSizeBytes,
    required this.videos,
  });

  String get formattedTotalDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get formattedTotalSize {
    if (totalSizeBytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = totalSizeBytes.toDouble();
    int suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${suffixes[suffixIndex]}';
  }

  int get failedVideos => totalVideos - validVideos;

  bool get hasErrors => failedVideos > 0;

  double get successRate => totalVideos > 0 ? validVideos / totalVideos : 0.0;
}
