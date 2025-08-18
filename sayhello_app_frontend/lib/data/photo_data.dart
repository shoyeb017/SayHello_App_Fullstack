import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Enum to specify bucket access level
enum BucketAccess { public, private }

/// Configuration for bucket upload
class BucketConfig {
  final String name;
  final BucketAccess access;
  final List<String> allowedExtensions;
  final int maxSizeInMB;

  const BucketConfig({
    required this.name,
    required this.access,
    this.allowedExtensions = const ['.jpg', '.jpeg', '.png', '.gif'],
    this.maxSizeInMB = 5,
  });
}

/// Photo repository for handling image uploads to Supabase Storage
class PhotoRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  // Predefined bucket configurations
  static const avatarsBucket = BucketConfig(
    name: 'avatars',
    access: BucketAccess.public,
    allowedExtensions: ['.jpg', '.jpeg', '.png'],
    maxSizeInMB: 2,
  );

  static const courseThumbnailsBucket = BucketConfig(
    name: 'course_images',
    access: BucketAccess.public,
    allowedExtensions: ['.jpg', '.jpeg', '.png'],
    maxSizeInMB: 3,
  );

  /// Initialize storage buckets - call this when setting up the app
  Future<void> initializeBuckets() async {
    try {
      // Create avatars bucket if it doesn't exist
      final buckets = await _supabase.storage.listBuckets();
      if (!buckets.any((b) => b.id == avatarsBucket.name)) {
        await _supabase.storage.createBucket(avatarsBucket.name);
        print('Created avatars bucket');
      }

      // Set public access for avatars bucket
      // Note: Public/private access and bucket policies are managed in the Supabase dashboard
    } catch (e) {
      print('Error initializing buckets: $e');
      rethrow;
    }
  }

  /// Validate file before upload
  void _validateFile(File file, BucketConfig config) {
    // Check file extension
    final extension = path.extension(file.path).toLowerCase();
    if (!config.allowedExtensions.contains(extension)) {
      throw Exception(
        'Invalid file type. Allowed types: ${config.allowedExtensions.join(", ")}',
      );
    }

    // Check file size
    final sizeInMB = file.lengthSync() / (1024 * 1024);
    if (sizeInMB > config.maxSizeInMB) {
      throw Exception('File size exceeds ${config.maxSizeInMB}MB limit.');
    }
  }

  /// Generate a unique filename for the upload
  String _generateFileName(String originalPath) {
    final extension = path.extension(originalPath).toLowerCase();
    return '${_uuid.v4()}$extension';
  }

  /// Upload an image to Supabase Storage and return its URL
  Future<String> uploadImage(File imageFile, BucketConfig config) async {
    try {
      // Validate the file
      _validateFile(imageFile, config);

      // Generate unique filename
      final fileName = _generateFileName(imageFile.path);

      // Upload file
      await _supabase.storage
          .from(config.name)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get URL based on access level
      final String imageUrl = config.access == BucketAccess.public
          ? _supabase.storage.from(config.name).getPublicUrl(fileName)
          : await _supabase.storage
                .from(config.name)
                .createSignedUrl(fileName, 3600 * 24 * 365); // 1 year expiry

      print('Uploaded image to ${config.name}: $imageUrl');
      return imageUrl;
    } on StorageException catch (e) {
      print('Storage error: ${e.message}');
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload a profile photo
  Future<String> uploadProfilePhoto(File imageFile) async {
    return uploadImage(imageFile, avatarsBucket);
  }

  /// Upload a course thumbnail
  Future<String> uploadCourseThumbnail(File imageFile) async {
    return uploadImage(imageFile, courseThumbnailsBucket);
  }

  /// Delete an image from storage by its bucket and path
  Future<void> deleteImageFromBucket(String bucket, String path) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      print('Delete error: $e');
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Delete a profile photo
  Future<void> deleteProfilePhoto(String path) async {
    await deleteImageFromBucket(avatarsBucket.name, path);
  }

  /// Delete an image from storage by URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract filename from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.last;
      final bucket = pathSegments[pathSegments.length - 2];

      await _supabase.storage.from(bucket).remove([fileName]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
