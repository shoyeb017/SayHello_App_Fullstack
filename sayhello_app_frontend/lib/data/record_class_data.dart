/// RecordClass Repository - Handles backend operations for record classes
/// Provides CRUD operations for record class management following data layer pattern

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/record_class.dart';

class RecordClassRepository {
  static final RecordClassRepository _instance =
      RecordClassRepository._internal();
  factory RecordClassRepository() => _instance;
  RecordClassRepository._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String tableName = 'recorded_classes';

  /// Get all record classes for a specific course
  Future<List<RecordClass>> getRecordClasses(String courseId) async {
    try {
      print(
        'RecordClassRepository: Loading record classes for course: $courseId',
      );

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('course_id', courseId)
          .order('created_at', ascending: false);

      print('RecordClassRepository: Response: $response');

      final List<RecordClass> recordClasses = (response as List)
          .map((json) => RecordClass.fromJson(json))
          .toList();

      print(
        'RecordClassRepository: Loaded ${recordClasses.length} record classes',
      );
      return recordClasses;
    } on PostgrestException catch (e) {
      print('RecordClassRepository: Database error: ${e.message}');
      print('RecordClassRepository: Error details: ${e.details}');
      throw Exception('Failed to load record classes: ${e.message}');
    } catch (e) {
      print('RecordClassRepository: Error loading record classes: $e');
      throw Exception('Failed to load record classes: $e');
    }
  }

  /// Add a video link (YouTube, Vimeo, or direct link) without file upload
  Future<RecordClass> addVideoLink({
    required String courseId,
    required String recordedName,
    required String recordedDescription,
    required String videoLink,
  }) async {
    try {
      print('RecordClassRepository: Adding video link: $recordedName');

      // Create the database record directly with the video link
      final recordClassData = {
        'course_id': courseId,
        'recorded_name': recordedName,
        'recorded_description': recordedDescription,
        'recorded_link': videoLink,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('RecordClassRepository: Inserting database record...');
      final response = await _supabase
          .from(tableName)
          .insert(recordClassData)
          .select()
          .single();

      print('RecordClassRepository: Database record created: $response');

      final recordClass = RecordClass.fromJson(response);
      print(
        'RecordClassRepository: Video link added successfully: ${recordClass.id}',
      );

      return recordClass;
    } on PostgrestException catch (e) {
      print('RecordClassRepository: Database error: ${e.message}');
      throw Exception('Failed to add video link: ${e.message}');
    } catch (e) {
      print('RecordClassRepository: Error adding video link: $e');
      throw Exception('Failed to add video link: $e');
    }
  }

  /// Update record class (name and description only)
  Future<RecordClass> updateRecordClass({
    required String recordClassId,
    required String recordedName,
    required String recordedDescription,
  }) async {
    try {
      print('RecordClassRepository: Updating record class: $recordClassId');

      final updateData = {
        'recorded_name': recordedName,
        'recorded_description': recordedDescription,
      };

      final response = await _supabase
          .from(tableName)
          .update(updateData)
          .eq('id', recordClassId)
          .select()
          .single();

      print('RecordClassRepository: Record class updated: $response');

      final updatedRecordClass = RecordClass.fromJson(response);
      return updatedRecordClass;
    } on PostgrestException catch (e) {
      print('RecordClassRepository: Database error: ${e.message}');
      throw Exception('Failed to update record class: ${e.message}');
    } catch (e) {
      print('RecordClassRepository: Error updating record class: $e');
      throw Exception('Failed to update record class: $e');
    }
  }

  /// Delete record class
  Future<void> deleteRecordClass(String recordClassId) async {
    try {
      print('RecordClassRepository: Deleting record class: $recordClassId');

      // First, get the record class to retrieve any additional info if needed
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', recordClassId)
          .single();

      final recordClass = RecordClass.fromJson(response);
      print(
        'RecordClassRepository: Found record class: ${recordClass.recordedName}',
      );

      // Delete the database record
      print('RecordClassRepository: Deleting database record...');
      await _supabase.from(tableName).delete().eq('id', recordClassId);

      print('RecordClassRepository: Record class deleted successfully');
    } on PostgrestException catch (e) {
      print('RecordClassRepository: Database error: ${e.message}');
      throw Exception('Failed to delete record class: ${e.message}');
    } catch (e) {
      print('RecordClassRepository: Error deleting record class: $e');
      throw Exception('Failed to delete record class: $e');
    }
  }

  /// Get record class by ID
  Future<RecordClass> getRecordClassById(String recordClassId) async {
    try {
      print(
        'RecordClassRepository: Loading record class by ID: $recordClassId',
      );

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', recordClassId)
          .single();

      print('RecordClassRepository: Record class loaded: $response');
      return RecordClass.fromJson(response);
    } on PostgrestException catch (e) {
      print('RecordClassRepository: Database error: ${e.message}');
      throw Exception('Failed to load record class: ${e.message}');
    } catch (e) {
      print('RecordClassRepository: Error loading record class: $e');
      throw Exception('Failed to load record class: $e');
    }
  }

  /// Test database schema and connection
  Future<void> testDatabaseSchema() async {
    try {
      print('RecordClassRepository: Testing database schema...');

      // Try to select from the table to check if it exists
      final response = await _supabase
          .from(tableName)
          .select('id, course_id, recorded_name')
          .limit(1);

      print(
        'RecordClassRepository: Schema test successful. Sample response: $response',
      );
    } catch (e) {
      print('RecordClassRepository: Schema test failed: $e');
      rethrow;
    }
  }
}