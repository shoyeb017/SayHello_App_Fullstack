/// StudyMaterial Repository - Handles backend operations for study materials
/// Provides CRUD operations with Supabase storage and database integration following data layer pattern

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/study_material.dart';

class StudyMaterialRepository {
  static final StudyMaterialRepository _instance =
      StudyMaterialRepository._internal();
  factory StudyMaterialRepository() => _instance;
  StudyMaterialRepository._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String tableName = 'study_materials';
  static const String bucketName = 'study_material';

  /// Get all study materials for a specific course
  Future<List<StudyMaterial>> getStudyMaterials(String courseId) async {
    try {
      print(
        'StudyMaterialRepository: Loading study materials for course: $courseId',
      );

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('course_id', courseId)
          .order('created_at', ascending: false);

      print('StudyMaterialRepository: Response: $response');

      final List<StudyMaterial> studyMaterials = (response as List)
          .map((json) => StudyMaterial.fromJson(json))
          .toList();

      print(
        'StudyMaterialRepository: Loaded ${studyMaterials.length} study materials',
      );
      return studyMaterials;
    } on PostgrestException catch (e) {
      print('StudyMaterialRepository: Database error: ${e.message}');
      throw Exception('Failed to load study materials: ${e.message}');
    } catch (e) {
      print('StudyMaterialRepository: Unexpected error: $e');
      throw Exception('Failed to load study materials: $e');
    }
  }

  /// Upload a study material file and create database record
  Future<StudyMaterial> uploadStudyMaterial({
    required String courseId,
    required String title,
    required String description,
    required String type,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      print('StudyMaterialRepository: Starting upload process...');

      // Step 1: Upload file to Supabase Storage
      final filePath =
          'course_$courseId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      print('StudyMaterialRepository: Uploading file to storage...');
      await _supabase.storage
          .from(bucketName)
          .uploadBinary(filePath, fileBytes);

      // Step 2: Get the public URL
      final publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      print('StudyMaterialRepository: File uploaded, URL: $publicUrl');

      // Step 3: Create database record
      print('StudyMaterialRepository: Creating database record...');
      final response = await _supabase
          .from(tableName)
          .insert({
            'course_id': courseId,
            'material_title': title,
            'material_description': description,
            'material_link': publicUrl,
            'material_type': type,
          })
          .select()
          .single();

      print('StudyMaterialRepository: Database record created: $response');

      final studyMaterial = StudyMaterial.fromJson(response);
      print('StudyMaterialRepository: Upload completed successfully');
      return studyMaterial;
    } on StorageException catch (e) {
      print('StudyMaterialRepository: Storage error: ${e.message}');
      throw Exception('Failed to upload file: ${e.message}');
    } on PostgrestException catch (e) {
      print('StudyMaterialRepository: Database error: ${e.message}');
      throw Exception('Failed to save study material: ${e.message}');
    } catch (e) {
      print('StudyMaterialRepository: Unexpected error: $e');
      throw Exception('Failed to upload study material: $e');
    }
  }

  /// Update an existing study material
  Future<StudyMaterial> updateStudyMaterial({
    required String id,
    String? title,
    String? description,
    String? type,
  }) async {
    try {
      print('StudyMaterialRepository: Updating study material: $id');

      final updateData = <String, dynamic>{};
      if (title != null) updateData['material_title'] = title;
      if (description != null) updateData['material_description'] = description;
      if (type != null) updateData['material_type'] = type;

      final response = await _supabase
          .from(tableName)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      print('StudyMaterialRepository: Update completed');
      return StudyMaterial.fromJson(response);
    } on PostgrestException catch (e) {
      print('StudyMaterialRepository: Database error: ${e.message}');
      throw Exception('Failed to update study material: ${e.message}');
    } catch (e) {
      print('StudyMaterialRepository: Unexpected error: $e');
      throw Exception('Failed to update study material: $e');
    }
  }

  /// Delete a study material
  Future<void> deleteStudyMaterial(String id) async {
    try {
      print('StudyMaterialRepository: Deleting study material: $id');

      // First get the study material to get the file path
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .single();

      final studyMaterial = StudyMaterial.fromJson(response);
      print(
        'StudyMaterialRepository: Found study material: ${studyMaterial.materialTitle}',
      );

      // Extract file path from the URL
      final url = studyMaterial.materialLink;
      if (url.isNotEmpty) {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 3) {
          final filePath = pathSegments.sublist(2).join('/');
          print('StudyMaterialRepository: Deleting file: $filePath');

          try {
            await _supabase.storage.from(bucketName).remove([filePath]);
            print('StudyMaterialRepository: File deleted from storage');
          } catch (storageError) {
            print(
              'StudyMaterialRepository: Storage deletion failed: $storageError',
            );
            // Continue with database deletion even if file deletion fails
          }
        }
      }

      // Delete database record
      await _supabase.from(tableName).delete().eq('id', id);

      print('StudyMaterialRepository: Study material deleted successfully');
    } on PostgrestException catch (e) {
      print('StudyMaterialRepository: Database error: ${e.message}');
      throw Exception('Failed to delete study material: ${e.message}');
    } catch (e) {
      print('StudyMaterialRepository: Unexpected error: $e');
      throw Exception('Failed to delete study material: $e');
    }
  }

  /// Get a single study material by ID
  Future<StudyMaterial?> getStudyMaterial(String id) async {
    try {
      print('StudyMaterialRepository: Getting study material: $id');

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        print('StudyMaterialRepository: Study material not found');
        return null;
      }

      final studyMaterial = StudyMaterial.fromJson(response);
      print('StudyMaterialRepository: Study material found');
      return studyMaterial;
    } on PostgrestException catch (e) {
      print('StudyMaterialRepository: Database error: ${e.message}');
      throw Exception('Failed to get study material: ${e.message}');
    } catch (e) {
      print('StudyMaterialRepository: Unexpected error: $e');
      throw Exception('Failed to get study material: $e');
    }
  }
}
