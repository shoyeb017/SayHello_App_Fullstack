/// StudyMaterial Service - Handles backend operations for study materials
/// Provides CRUD operations with Supabase storage and database integration

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/study_material.dart';

class StudyMaterialService {
  static final StudyMaterialService _instance =
      StudyMaterialService._internal();
  factory StudyMaterialService() => _instance;
  StudyMaterialService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String tableName = 'study_materials';
  static const String bucketName = 'study_material';

  /// Get all study materials for a specific course
  Future<List<StudyMaterial>> getStudyMaterials(String courseId) async {
    try {
      print(
        'StudyMaterialService: Loading study materials for course: $courseId',
      );

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('course_id', courseId)
          .order('created_at', ascending: false);

      print('StudyMaterialService: Response: $response');

      final List<StudyMaterial> studyMaterials = (response as List)
          .map((json) => StudyMaterial.fromJson(json))
          .toList();

      // Get download URLs for each material
      for (int i = 0; i < studyMaterials.length; i++) {
        final downloadUrl = await getDownloadUrl(studyMaterials[i].filePath);
        studyMaterials[i] = studyMaterials[i].copyWith(
          downloadUrl: downloadUrl,
        );
      }

      print(
        'StudyMaterialService: Loaded ${studyMaterials.length} study materials',
      );
      return studyMaterials;
    } on PostgrestException catch (e) {
      print('StudyMaterialService: Database error: ${e.message}');
      print('StudyMaterialService: Error details: ${e.details}');
      throw Exception('Failed to load study materials: ${e.message}');
    } catch (e) {
      print('StudyMaterialService: Error loading study materials: $e');
      throw Exception('Failed to load study materials: $e');
    }
  }

  /// Upload study material with file to Supabase storage
  Future<StudyMaterial> uploadStudyMaterial({
    required String courseId,
    required String title,
    required String description,
    required String type,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      print('StudyMaterialService: Uploading study material: $title');

      // Generate unique file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${courseId}_${timestamp}_${fileName}';
      final filePath = '$courseId/$uniqueFileName';

      print('StudyMaterialService: Uploading file to storage...');

      // Upload file to Supabase storage
      await _supabase.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: _getContentType(type),
              upsert: false,
            ),
          );

      print('StudyMaterialService: File uploaded successfully: $filePath');

      // Get file size
      final fileSize = _formatFileSize(fileBytes.length);

      // Get download URL
      final downloadUrl = await getDownloadUrl(filePath);

      // Create database record
      final now = DateTime.now();
      final studyMaterialData = {
        'course_id': courseId,
        'material_title': title,
        'material_description': description,
        'material_type': type,
        'material_link': filePath,
        'file_name': fileName,
        'file_path': filePath,
        'file_size': fileSize,
        'upload_time':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        'download_url': downloadUrl,
      };

      print('StudyMaterialService: Creating database record...');
      final response = await _supabase
          .from(tableName)
          .insert(studyMaterialData)
          .select()
          .single();

      print('StudyMaterialService: Database record created: $response');

      final studyMaterial = StudyMaterial.fromJson(response);
      print(
        'StudyMaterialService: Study material uploaded successfully: ${studyMaterial.id}',
      );

      return studyMaterial;
    } on StorageException catch (e) {
      print('StudyMaterialService: Storage error: ${e.message}');
      throw Exception('Failed to upload file: ${e.message}');
    } on PostgrestException catch (e) {
      print('StudyMaterialService: Database error: ${e.message}');
      throw Exception('Failed to save study material: ${e.message}');
    } catch (e) {
      print('StudyMaterialService: Error uploading study material: $e');
      throw Exception('Failed to upload study material: $e');
    }
  }

  /// Update study material (title and description only)
  Future<StudyMaterial> updateStudyMaterial({
    required String studyMaterialId,
    required String title,
    required String description,
  }) async {
    try {
      print('StudyMaterialService: Updating study material: $studyMaterialId');

      final updateData = {
        'material_title': title,
        'material_description': description,
        'title': title,
        'description': description,
      };

      final response = await _supabase
          .from(tableName)
          .update(updateData)
          .eq('id', studyMaterialId)
          .select()
          .single();

      print('StudyMaterialService: Study material updated: $response');

      final updatedStudyMaterial = StudyMaterial.fromJson(response);

      // Get download URL
      final downloadUrl = await getDownloadUrl(updatedStudyMaterial.filePath);

      return updatedStudyMaterial.copyWith(downloadUrl: downloadUrl);
    } on PostgrestException catch (e) {
      print('StudyMaterialService: Database error: ${e.message}');
      throw Exception('Failed to update study material: ${e.message}');
    } catch (e) {
      print('StudyMaterialService: Error updating study material: $e');
      throw Exception('Failed to update study material: $e');
    }
  }

  /// Delete study material and its file from storage
  Future<void> deleteStudyMaterial(String studyMaterialId) async {
    try {
      print('StudyMaterialService: Deleting study material: $studyMaterialId');

      // First, get the study material to retrieve file path
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', studyMaterialId)
          .single();

      final studyMaterial = StudyMaterial.fromJson(response);
      print(
        'StudyMaterialService: Found study material: ${studyMaterial.title}',
      );

      // Delete file from storage
      print('StudyMaterialService: Deleting file from storage...');
      try {
        await _supabase.storage.from(bucketName).remove([
          studyMaterial.filePath,
        ]);
        print('StudyMaterialService: File deleted from storage');
      } catch (e) {
        print(
          'StudyMaterialService: Warning - Could not delete file from storage: $e',
        );
        // Continue with database deletion even if file deletion fails
      }

      // Delete database record
      print('StudyMaterialService: Deleting database record...');
      await _supabase.from(tableName).delete().eq('id', studyMaterialId);

      print('StudyMaterialService: Study material deleted successfully');
    } on PostgrestException catch (e) {
      print('StudyMaterialService: Database error: ${e.message}');
      throw Exception('Failed to delete study material: ${e.message}');
    } catch (e) {
      print('StudyMaterialService: Error deleting study material: $e');
      throw Exception('Failed to delete study material: $e');
    }
  }

  /// Get study material by ID
  Future<StudyMaterial> getStudyMaterialById(String studyMaterialId) async {
    try {
      print(
        'StudyMaterialService: Loading study material by ID: $studyMaterialId',
      );

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', studyMaterialId)
          .single();

      print('StudyMaterialService: Study material loaded: $response');

      final studyMaterial = StudyMaterial.fromJson(response);

      // Get download URL
      final downloadUrl = await getDownloadUrl(studyMaterial.filePath);

      return studyMaterial.copyWith(downloadUrl: downloadUrl);
    } on PostgrestException catch (e) {
      print('StudyMaterialService: Database error: ${e.message}');
      throw Exception('Failed to load study material: ${e.message}');
    } catch (e) {
      print('StudyMaterialService: Error loading study material: $e');
      throw Exception('Failed to load study material: $e');
    }
  }

  /// Get download URL for a file
  Future<String> getDownloadUrl(String filePath) async {
    try {
      final response = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return response;
    } catch (e) {
      print('StudyMaterialService: Error getting download URL: $e');
      return '';
    }
  }

  /// Pick file using file picker - simplified for web/mobile compatibility
  Future<Map<String, dynamic>?> pickFile() async {
    try {
      // Note: For full implementation, you would need to add file_picker package
      // and implement platform-specific file picking
      // For now, this is a placeholder that would need actual implementation
      throw UnimplementedError(
        'File picking needs platform-specific implementation',
      );
    } catch (e) {
      print('StudyMaterialService: Error picking file: $e');
      throw Exception('Failed to pick file: $e');
    }
  }

  /// Get content type for file upload
  String _getContentType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'image':
        return 'image/*';
      default:
        return 'application/octet-stream';
    }
  }

  /// Format file size in human readable format
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Initialize storage bucket (call this during app initialization)
  Future<void> initializeBucket() async {
    try {
      print('StudyMaterialService: Initializing storage bucket...');

      // Try to get bucket info to check if it exists
      await _supabase.storage.getBucket(bucketName);
      print('StudyMaterialService: Bucket already exists');
    } catch (e) {
      print('StudyMaterialService: Bucket does not exist, creating...');
      try {
        await _supabase.storage.createBucket(
          bucketName,
          BucketOptions(
            public: true,
            allowedMimeTypes: [
              'application/pdf',
              'application/msword',
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              'image/png',
              'image/jpeg',
              'image/jpg',
              'image/gif',
            ],
            fileSizeLimit: '10MB', // 10MB limit
          ),
        );
        print('StudyMaterialService: Bucket created successfully');
      } catch (createError) {
        print('StudyMaterialService: Error creating bucket: $createError');
        // Bucket might already exist, continue
      }
    }
  }

  /// Test database schema and storage
  Future<void> testDatabaseSchema() async {
    try {
      print('StudyMaterialService: Testing database schema...');

      // Try to select from the table to check if it exists
      final response = await _supabase
          .from(tableName)
          .select('id, course_id, title')
          .limit(1);

      print(
        'StudyMaterialService: Schema test successful. Sample response: $response',
      );
    } catch (e) {
      print('StudyMaterialService: Schema test failed: $e');
      rethrow;
    }
  }
}
