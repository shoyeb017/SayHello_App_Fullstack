import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  // Constants
  static const String profileBucket = 'profile_pics';
  static const String courseBucket = 'course_thumbnails';
  static const List<String> allowedExtensions = ['.jpg', '.jpeg', '.png'];

  /// Initialize storage buckets - must be called at app startup
  Future<void> initializeStorage() async {
    try {
      // Check if buckets exist
      final buckets = await _supabase.storage.listBuckets();
      print(
        'StorageService: Available buckets: ${buckets.map((b) => b.id).toList()}',
      );

      // Initialize profile bucket
      if (!buckets.any((b) => b.id == profileBucket)) {
        print('StorageService: profile_pics bucket not found');
        // await _supabase.storage.createBucket(profileBucket);
        // print('Created profile_pics bucket');
      } else {
        print('StorageService: profile_pics bucket exists');
      }

      // Initialize course bucket
      if (!buckets.any((b) => b.id == courseBucket)) {
        print('StorageService: course_thumbnails bucket not found');
        // await _supabase.storage.createBucket(courseBucket);
        // print('Created course_thumbnails bucket');
      } else {
        print('StorageService: course_thumbnails bucket exists');
      }
    } catch (e) {
      print('StorageService: Error initializing storage: $e');
      rethrow;
    }
  }

  /// Validate file before upload
  void _validateFile(File file) {
    // Check file extension
    final extension = path.extension(file.path).toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      throw Exception('Invalid file type. Please use JPG or PNG images.');
    }
  }

  /// Upload learner profile photo
  Future<String> uploadProfilePhoto(File imageFile, String learnerId) async {
    try {
      _validateFile(imageFile);

      // Generate unique filename using learner ID and UUID
      final extension = path.extension(imageFile.path).toLowerCase();
      final fileName = 'learner_${learnerId}_${_uuid.v4()}$extension';

      // Upload to Supabase Storage
      await _supabase.storage
          .from(profileBucket)
          .upload(
            fileName,
            imageFile,
            fileOptions: FileOptions(
              contentType: extension == '.png' ? 'image/png' : 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final imageUrl = _supabase.storage
          .from(profileBucket)
          .getPublicUrl(fileName);
      print('Uploaded profile photo: $imageUrl');

      return imageUrl;
    } on StorageException catch (e) {
      print('Storage error: ${e.message}');
      throw Exception('Failed to upload profile photo: ${e.message}');
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  /// Delete profile photo
  Future<void> deleteProfilePhoto(String fileName) async {
    try {
      await _supabase.storage.from(profileBucket).remove([fileName]);
    } catch (e) {
      print('Failed to delete profile photo: $e');
      throw Exception('Failed to delete profile photo: $e');
    }
  }

  /// Upload course thumbnail
  Future<String> uploadCourseThumbnail(File imageFile, String courseId) async {
    try {
      print('StorageService: Starting upload for course $courseId');
      print('StorageService: File path: ${imageFile.path}');
      print('StorageService: File exists: ${await imageFile.exists()}');

      _validateFile(imageFile);

      // Generate unique filename using course ID and UUID
      final extension = path.extension(imageFile.path).toLowerCase();
      final fileName = 'course_${courseId}_${_uuid.v4()}$extension';
      print('StorageService: Generated filename: $fileName');

      // Upload to Supabase Storage
      print('StorageService: Uploading to bucket: $courseBucket');
      await _supabase.storage
          .from(courseBucket)
          .upload(
            fileName,
            imageFile,
            fileOptions: FileOptions(
              contentType: extension == '.png' ? 'image/png' : 'image/jpeg',
              upsert: true,
            ),
          );

      // Get public URL
      final imageUrl = _supabase.storage
          .from(courseBucket)
          .getPublicUrl(fileName);
      print('StorageService: Upload successful, URL: $imageUrl');

      return imageUrl;
    } on StorageException catch (e) {
      print('StorageService: Storage error: ${e.message}');
      print('StorageService: Error details: ${e.toString()}');
      throw Exception('Failed to upload course thumbnail: ${e.message}');
    } catch (e) {
      print('StorageService: Upload error: $e');
      throw Exception('Failed to upload course thumbnail: $e');
    }
  }
}
