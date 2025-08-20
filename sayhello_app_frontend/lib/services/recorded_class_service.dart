/// RecordedClass Service - Handles backend operations for recorded classes
/// Provides CRUD operations for recorded class management

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recorded_class.dart';

class RecordedClassService {
  static final RecordedClassService _instance =
      RecordedClassService._internal();
  factory RecordedClassService() => _instance;
  RecordedClassService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String tableName = 'recorded_classes';

  /// Get all recorded classes for a specific course
  Future<List<RecordedClass>> getRecordedClasses(String courseId) async {
    try {
      print(
        'RecordedClassService: Loading recorded classes for course: $courseId',
      );

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('course_id', courseId)
          .order('created_at', ascending: false);

      print('RecordedClassService: Response: $response');

      final List<RecordedClass> recordedClasses = (response as List)
          .map((json) => RecordedClass.fromJson(json))
          .toList();

      print(
        'RecordedClassService: Loaded ${recordedClasses.length} recorded classes',
      );
      return recordedClasses;
    } on PostgrestException catch (e) {
      print('RecordedClassService: Database error: ${e.message}');
      print('RecordedClassService: Error details: ${e.details}');
      throw Exception('Failed to load recorded classes: ${e.message}');
    } catch (e) {
      print('RecordedClassService: Error loading recorded classes: $e');
      throw Exception('Failed to load recorded classes: $e');
    }
  }

  /// Add a video link (YouTube, Vimeo, or direct link) without file upload
  Future<RecordedClass> addVideoLink({
    required String courseId,
    required String recordedName,
    required String recordedDescription,
    required String videoLink,
  }) async {
    try {
      print('RecordedClassService: Adding video link: $recordedName');

      // Create the database record directly with the video link
      final recordedClassData = {
        'course_id': courseId,
        'recorded_name': recordedName,
        'recorded_description': recordedDescription,
        'recorded_link': videoLink,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('RecordedClassService: Inserting database record...');
      final response = await _supabase
          .from(tableName)
          .insert(recordedClassData)
          .select()
          .single();

      print('RecordedClassService: Database record created: $response');

      final recordedClass = RecordedClass.fromJson(response);
      print(
        'RecordedClassService: Video link added successfully: ${recordedClass.id}',
      );

      return recordedClass;
    } on PostgrestException catch (e) {
      print('RecordedClassService: Database error: ${e.message}');
      throw Exception('Failed to add video link: ${e.message}');
    } catch (e) {
      print('RecordedClassService: Error adding video link: $e');
      throw Exception('Failed to add video link: $e');
    }
  }

  /// Update recorded class (name and description only)
  Future<RecordedClass> updateRecordedClass({
    required String recordedClassId,
    required String recordedName,
    required String recordedDescription,
  }) async {
    try {
      print('RecordedClassService: Updating recorded class: $recordedClassId');

      final updateData = {
        'recorded_name': recordedName,
        'recorded_description': recordedDescription,
      };

      final response = await _supabase
          .from(tableName)
          .update(updateData)
          .eq('id', recordedClassId)
          .select()
          .single();

      print('RecordedClassService: Recorded class updated: $response');

      final updatedRecordedClass = RecordedClass.fromJson(response);
      return updatedRecordedClass;
    } on PostgrestException catch (e) {
      print('RecordedClassService: Database error: ${e.message}');
      throw Exception('Failed to update recorded class: ${e.message}');
    } catch (e) {
      print('RecordedClassService: Error updating recorded class: $e');
      throw Exception('Failed to update recorded class: $e');
    }
  }

  /// Delete recorded class
  Future<void> deleteRecordedClass(String recordedClassId) async {
    try {
      print('RecordedClassService: Deleting recorded class: $recordedClassId');

      // First, get the recorded class to retrieve any additional info if needed
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', recordedClassId)
          .single();

      final recordedClass = RecordedClass.fromJson(response);
      print(
        'RecordedClassService: Found recorded class: ${recordedClass.recordedName}',
      );

      // Delete the database record
      print('RecordedClassService: Deleting database record...');
      await _supabase.from(tableName).delete().eq('id', recordedClassId);

      print('RecordedClassService: Recorded class deleted successfully');
    } on PostgrestException catch (e) {
      print('RecordedClassService: Database error: ${e.message}');
      throw Exception('Failed to delete recorded class: ${e.message}');
    } catch (e) {
      print('RecordedClassService: Error deleting recorded class: $e');
      throw Exception('Failed to delete recorded class: $e');
    }
  }

  /// Get recorded class by ID
  Future<RecordedClass> getRecordedClassById(String recordedClassId) async {
    try {
      print(
        'RecordedClassService: Loading recorded class by ID: $recordedClassId',
      );

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', recordedClassId)
          .single();

      print('RecordedClassService: Recorded class loaded: $response');
      return RecordedClass.fromJson(response);
    } on PostgrestException catch (e) {
      print('RecordedClassService: Database error: ${e.message}');
      throw Exception('Failed to load recorded class: ${e.message}');
    } catch (e) {
      print('RecordedClassService: Error loading recorded class: $e');
      throw Exception('Failed to load recorded class: $e');
    }
  }

  /// Test database schema and connection
  Future<void> testDatabaseSchema() async {
    try {
      print('RecordedClassService: Testing database schema...');

      // Try to select from the table to check if it exists
      final response = await _supabase
          .from(tableName)
          .select('id, course_id, recorded_name')
          .limit(1);

      print(
        'RecordedClassService: Schema test successful. Sample response: $response',
      );
    } catch (e) {
      print('RecordedClassService: Schema test failed: $e');
      rethrow;
    }
  }
}
