/// Session Service - Handles backend operations for course sessions
/// Provides CRUD operations for session management

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_session.dart';

class SessionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new course session
  Future<CourseSession> createSession(CourseSession session) async {
    try {
      print('Creating session with data: ${session.toJson()}');

      final response = await _supabase
          .from('course_sessions')
          .insert(session.toJson())
          .select()
          .single();

      print('Session created successfully: $response');
      return CourseSession.fromJson(response);
    } catch (e) {
      print('Error creating session: $e');
      throw Exception('Failed to create session: $e');
    }
  }

  /// Get all sessions for a specific course
  Future<List<CourseSession>> getSessionsByCourse(String courseId) async {
    try {
      print('Loading sessions for course: $courseId');

      final response = await _supabase
          .from('course_sessions')
          .select()
          .eq('course_id', courseId)
          .order('session_date', ascending: true);

      print('Sessions loaded: ${response.length} sessions found');

      // Debug: Print the structure of the first session if any exist
      if (response.isNotEmpty) {
        print('First session structure: ${response[0]}');
        print('First session keys: ${response[0].keys.toList()}');
      }

      return (response as List)
          .map((json) => CourseSession.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading sessions: $e');
      throw Exception('Failed to load sessions: $e');
    }
  }

  /// Update an existing session
  Future<CourseSession> updateSession(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('Updating session $sessionId with: $updates');

      final response = await _supabase
          .from('course_sessions')
          .update(updates)
          .eq('id', sessionId)
          .select()
          .single();

      print('Session updated successfully: $response');
      return CourseSession.fromJson(response);
    } catch (e) {
      print('Error updating session: $e');
      throw Exception('Failed to update session: $e');
    }
  }

  /// Delete a session
  Future<void> deleteSession(String sessionId) async {
    try {
      print('Deleting session: $sessionId');
      print('Attempting to delete from course_sessions where id = $sessionId');

      // Try using a more explicit approach to ensure we're using the correct column
      final result = await _supabase.from('course_sessions').delete().match({
        'id': sessionId,
      });

      print('Delete result: $result');
      print('Session deleted successfully');
    } catch (e) {
      print('Error deleting session: $e');
      print('Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('PostgrestException details:');
        print('  Message: ${e.message}');
        print('  Code: ${e.code}');
        print('  Details: ${e.details}');
        print('  Hint: ${e.hint}');
      }
      throw Exception('Failed to delete session: $e');
    }
  }

  /// Get upcoming sessions for a course
  Future<List<CourseSession>> getUpcomingSessions(String courseId) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('course_sessions')
          .select()
          .eq('course_id', courseId)
          .gte('session_date', now)
          .order('session_date', ascending: true);

      return (response as List)
          .map((json) => CourseSession.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading upcoming sessions: $e');
      throw Exception('Failed to load upcoming sessions: $e');
    }
  }

  /// Get completed sessions for a course
  Future<List<CourseSession>> getCompletedSessions(String courseId) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('course_sessions')
          .select()
          .eq('course_id', courseId)
          .lt('session_date', now)
          .order('session_date', ascending: false);

      return (response as List)
          .map((json) => CourseSession.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading completed sessions: $e');
      throw Exception('Failed to load completed sessions: $e');
    }
  }

  /// Get session by ID
  Future<CourseSession> getSessionById(String sessionId) async {
    try {
      print('Loading session by ID: $sessionId');

      final response = await _supabase
          .from('course_sessions')
          .select()
          .eq('id', sessionId)
          .single();

      print('Session loaded by ID: $response');
      return CourseSession.fromJson(response);
    } catch (e) {
      print('Error loading session: $e');
      if (e is PostgrestException) {
        print('PostgrestException details:');
        print('  Message: ${e.message}');
        print('  Code: ${e.code}');
        print('  Details: ${e.details}');
        print('  Hint: ${e.hint}');
      }
      throw Exception('Failed to load session: $e');
    }
  }

  /// Get session statistics for a course
  Future<Map<String, int>> getSessionStats(String courseId) async {
    try {
      final sessions = await getSessionsByCourse(courseId);

      int total = sessions.length;
      int completed = sessions.where((s) => s.isCompleted).length;
      int upcoming = sessions.where((s) => s.isUpcoming).length;

      return {'total': total, 'completed': completed, 'upcoming': upcoming};
    } catch (e) {
      print('Error loading session stats: $e');
      return {'total': 0, 'completed': 0, 'upcoming': 0};
    }
  }

  /// Test database connection and schema
  Future<void> testDatabaseSchema() async {
    try {
      print('Testing database schema for course_sessions table...');

      // Try to get the table structure
      final result = await _supabase.from('course_sessions').select().limit(1);

      print('Schema test successful. Sample structure: $result');

      if (result.isNotEmpty) {
        print('Available columns: ${result[0].keys.toList()}');
      }
    } catch (e) {
      print('Schema test failed: $e');
      if (e is PostgrestException) {
        print('PostgrestException details:');
        print('  Message: ${e.message}');
        print('  Code: ${e.code}');
        print('  Details: ${e.details}');
        print('  Hint: ${e.hint}');
      }
    }
  }
}
