/// Utility class to generate thumbnail URLs for different video platforms
/// Automatically generates thumbnails from video URLs without manual upload

import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoThumbnailGenerator {
  /// Generate thumbnail URL for YouTube videos
  static String? getYouTubeThumbnail(String videoUrl) {
    try {
      final uri = Uri.parse(videoUrl);
      String? videoId;

      if (uri.host.contains('youtu.be')) {
        // Short URL format: https://youtu.be/VIDEO_ID
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      } else if (uri.host.contains('youtube.com')) {
        // Long URL format: https://www.youtube.com/watch?v=VIDEO_ID
        videoId = uri.queryParameters['v'];
      }

      if (videoId != null) {
        // Return high quality thumbnail (best available options)
        // Try maxres first, fallback to hq, then standard
        return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
      }
    } catch (e) {
      print('Error generating YouTube thumbnail: $e');
    }

    return null;
  }

  /// Generate thumbnail URL for Vimeo videos using their API
  static Future<String?> getVimeoThumbnail(String videoUrl) async {
    try {
      final uri = Uri.parse(videoUrl);

      if (uri.host.contains('vimeo.com')) {
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final videoId = pathSegments.last;

          // Use Vimeo's oEmbed API to get thumbnail
          final apiUrl =
              'https://vimeo.com/api/oembed.json?url=https://vimeo.com/$videoId';

          try {
            final response = await http.get(Uri.parse(apiUrl));
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              return data['thumbnail_url'] as String?;
            }
          } catch (e) {
            print('Vimeo API error: $e');
          }

          // Fallback: Use vumbnail service
          return 'https://vumbnail.com/$videoId.jpg';
        }
      }
    } catch (e) {
      print('Error generating Vimeo thumbnail: $e');
    }

    return null;
  }

  /// Generate thumbnail for direct video files (.mp4, .mov, etc.)
  static String? getDirectVideoThumbnail(String videoUrl) {
    try {
      final uri = Uri.parse(videoUrl);
      final path = uri.path.toLowerCase();

      // Check if it's a direct video file
      if (path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi') ||
          path.endsWith('.mkv') ||
          path.endsWith('.webm') ||
          path.endsWith('.m4v') ||
          path.endsWith('.flv') ||
          path.endsWith('.3gp') ||
          path.endsWith('.wmv') ||
          path.endsWith('.ogv')) {
        // For direct video files, we can't easily generate thumbnails
        // without downloading the video. Return a placeholder or null
        // In a real app, you might use a video thumbnail generation service
        return null; // Could return a default video icon placeholder
      }
    } catch (e) {
      print('Error processing direct video URL: $e');
    }

    return null;
  }

  /// Auto-generate thumbnail URL based on video URL
  static Future<String?> autoGenerateThumbnail(String videoUrl) async {
    try {
      final uri = Uri.parse(videoUrl);
      final host = uri.host.toLowerCase();

      // YouTube - instant generation
      if (host.contains('youtube.com') || host.contains('youtu.be')) {
        return getYouTubeThumbnail(videoUrl);
      }

      // Vimeo - requires API call
      if (host.contains('vimeo.com')) {
        return await getVimeoThumbnail(videoUrl);
      }

      // Dailymotion
      if (host.contains('dailymotion.com') || host.contains('dai.ly')) {
        return getDailymotionThumbnail(videoUrl);
      }

      // Direct video files
      return getDirectVideoThumbnail(videoUrl);
    } catch (e) {
      print('Error auto-generating thumbnail: $e');
      return null;
    }
  }

  /// Generate thumbnail for Dailymotion videos
  static String? getDailymotionThumbnail(String videoUrl) {
    try {
      final uri = Uri.parse(videoUrl);

      if (uri.host.contains('dailymotion.com')) {
        // Extract video ID from Dailymotion URL
        String? videoId;

        if (uri.path.contains('/video/')) {
          final segments = uri.path.split('/');
          final videoIndex = segments.indexOf('video');
          if (videoIndex != -1 && videoIndex + 1 < segments.length) {
            videoId = segments[videoIndex + 1];
          }
        }

        if (videoId != null) {
          return 'https://www.dailymotion.com/thumbnail/video/$videoId';
        }
      } else if (uri.host.contains('dai.ly')) {
        // Short Dailymotion URL
        final videoId = uri.pathSegments.isNotEmpty
            ? uri.pathSegments[0]
            : null;
        if (videoId != null) {
          return 'https://www.dailymotion.com/thumbnail/video/$videoId';
        }
      }
    } catch (e) {
      print('Error generating Dailymotion thumbnail: $e');
    }

    return null;
  }

  /// Get multiple thumbnail quality options for YouTube
  static Map<String, String> getYouTubeThumbnailOptions(String videoUrl) {
    final videoId = _extractYouTubeId(videoUrl);
    if (videoId == null) return {};

    return {
      'maxres': 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
      'high': 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
      'medium': 'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
      'standard': 'https://img.youtube.com/vi/$videoId/sddefault.jpg',
      'default': 'https://img.youtube.com/vi/$videoId/default.jpg',
    };
  }

  /// Extract YouTube video ID from URL
  static String? _extractYouTubeId(String videoUrl) {
    try {
      final uri = Uri.parse(videoUrl);

      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      } else if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      }
    } catch (e) {
      print('Error extracting YouTube ID: $e');
    }

    return null;
  }

  /// Check if a thumbnail URL is valid by testing HTTP response
  static Future<bool> isValidThumbnail(String thumbnailUrl) async {
    try {
      final response = await http.head(Uri.parse(thumbnailUrl));
      return response.statusCode == 200 &&
          response.headers['content-type']?.startsWith('image/') == true;
    } catch (e) {
      return false;
    }
  }

  /// Get best available thumbnail for any video URL
  static Future<String?> getBestThumbnail(String videoUrl) async {
    try {
      final uri = Uri.parse(videoUrl);
      final host = uri.host.toLowerCase();

      // For YouTube, try multiple qualities
      if (host.contains('youtube.com') || host.contains('youtu.be')) {
        final options = getYouTubeThumbnailOptions(videoUrl);

        // Try in order of quality
        for (final quality in [
          'maxres',
          'high',
          'medium',
          'standard',
          'default',
        ]) {
          final thumbnail = options[quality];
          if (thumbnail != null && await isValidThumbnail(thumbnail)) {
            return thumbnail;
          }
        }
      }

      // For other platforms, use auto-generate
      return await autoGenerateThumbnail(videoUrl);
    } catch (e) {
      print('Error getting best thumbnail: $e');
      return null;
    }
  }

  /// Get suggested thumbnail help text for user
  static String getSuggestedThumbnailHelp(String videoUrl) {
    try {
      final uri = Uri.parse(videoUrl);
      final host = uri.host.toLowerCase();

      if (host.contains('youtube.com') || host.contains('youtu.be')) {
        return 'Thumbnail will be auto-generated from YouTube';
      }

      if (host.contains('vimeo.com')) {
        return 'Thumbnail will be auto-generated from Vimeo';
      }

      if (host.contains('dailymotion.com') || host.contains('dai.ly')) {
        return 'Thumbnail will be auto-generated from Dailymotion';
      }

      final path = uri.path.toLowerCase();
      if (path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi') ||
          path.endsWith('.mkv') ||
          path.endsWith('.webm')) {
        return 'Direct video file - thumbnail cannot be auto-generated';
      }

      return 'Thumbnail will be auto-generated if possible';
    } catch (e) {
      return 'Enter video URL to auto-generate thumbnail';
    }
  }
}
