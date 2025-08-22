/// Feedback Repository - Handles backend operations for feedback management
/// Provides CRUD operations for course, instructor, and student feedback following data layer pattern

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feedback.dart';

class FeedbackRepository {
  static final FeedbackRepository _instance = FeedbackRepository._internal();
  factory FeedbackRepository() => _instance;
  FeedbackRepository._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String tableName = 'feedback';

  /// Get all feedback for a specific course with user details
  Future<List<Feedback>> getCourseFeedback(String courseId) async {
    try {
      print('FeedbackRepository: Loading course feedback for: $courseId');

      final response = await _supabase
          .from(tableName)
          .select('''
            *,
            learners:learner_id(name, username),
            instructors:instructor_id(name, username),
            courses:course_id(title)
          ''')
          .eq('course_id', courseId)
          .eq('feedback_type', 'course')
          .order('created_at', ascending: false);

      print('FeedbackRepository: Course feedback response: $response');

      final List<Feedback> feedbackList = (response as List).map((json) {
        // Extract nested user data
        final learnerData = json['learners'] as Map<String, dynamic>?;
        final instructorData = json['instructors'] as Map<String, dynamic>?;
        final courseData = json['courses'] as Map<String, dynamic>?;

        return Feedback.fromJson({
          ...json,
          'learner_name': learnerData?['name'],
          'learner_avatar': learnerData?['name']
              ?.toString()
              .substring(0, 1)
              .toUpperCase(),
          'instructor_name': instructorData?['name'],
          'course_name': courseData?['title'],
        });
      }).toList();

      print(
        'FeedbackRepository: Loaded ${feedbackList.length} course feedback items',
      );
      return feedbackList;
    } on PostgrestException catch (e) {
      print('FeedbackRepository: Database error: ${e.message}');
      throw Exception('Failed to load course feedback: ${e.message}');
    } catch (e) {
      print('FeedbackRepository: Error loading course feedback: $e');
      throw Exception('Failed to load course feedback: $e');
    }
  }

  /// Get all instructor feedback for a specific instructor
  Future<List<Feedback>> getInstructorFeedback(String instructorId) async {
    try {
      print(
        'FeedbackRepository: Loading instructor feedback for: $instructorId',
      );

      final response = await _supabase
          .from(tableName)
          .select('''
            *,
            learners:learner_id(name, username),
            instructors:instructor_id(name, username),
            courses:course_id(title)
          ''')
          .eq('instructor_id', instructorId)
          .eq('feedback_type', 'instructor')
          .order('created_at', ascending: false);

      print('FeedbackRepository: Instructor feedback response: $response');

      final List<Feedback> feedbackList = (response as List).map((json) {
        final learnerData = json['learners'] as Map<String, dynamic>?;
        final instructorData = json['instructors'] as Map<String, dynamic>?;
        final courseData = json['courses'] as Map<String, dynamic>?;

        return Feedback.fromJson({
          ...json,
          'learner_name': learnerData?['name'],
          'learner_avatar': learnerData?['name']
              ?.toString()
              .substring(0, 1)
              .toUpperCase(),
          'instructor_name': instructorData?['name'],
          'course_name': courseData?['title'],
        });
      }).toList();

      print(
        'FeedbackRepository: Loaded ${feedbackList.length} instructor feedback items',
      );
      return feedbackList;
    } on PostgrestException catch (e) {
      print('FeedbackRepository: Database error: ${e.message}');
      throw Exception('Failed to load instructor feedback: ${e.message}');
    } catch (e) {
      print('FeedbackRepository: Error loading instructor feedback: $e');
      throw Exception('Failed to load instructor feedback: $e');
    }
  }

  /// Get all feedback from students for a specific course (instructor perspective)
  Future<List<Feedback>> getStudentFeedback(String courseId) async {
    try {
      print(
        'FeedbackRepository: Loading student feedback for course: $courseId',
      );

      final response = await _supabase
          .from(tableName)
          .select('''
            *,
            learners:learner_id(name, username),
            instructors:instructor_id(name, username),
            courses:course_id(title)
          ''')
          .eq('course_id', courseId)
          .eq('feedback_type', 'learner')
          .order('created_at', ascending: false);

      print('FeedbackRepository: Student feedback response: $response');

      final List<Feedback> feedbackList = (response as List).map((json) {
        final learnerData = json['learners'] as Map<String, dynamic>?;
        final instructorData = json['instructors'] as Map<String, dynamic>?;
        final courseData = json['courses'] as Map<String, dynamic>?;

        return Feedback.fromJson({
          ...json,
          'learner_name': learnerData?['name'],
          'learner_avatar': learnerData?['name']
              ?.toString()
              .substring(0, 1)
              .toUpperCase(),
          'instructor_name': instructorData?['name'],
          'course_name': courseData?['title'],
        });
      }).toList();

      print(
        'FeedbackRepository: Loaded ${feedbackList.length} student feedback items',
      );
      return feedbackList;
    } on PostgrestException catch (e) {
      print('FeedbackRepository: Database error: ${e.message}');
      throw Exception('Failed to load student feedback: ${e.message}');
    } catch (e) {
      print('FeedbackRepository: Error loading student feedback: $e');
      throw Exception('Failed to load student feedback: $e');
    }
  }

  /// Create new feedback (course, instructor, or student feedback)
  Future<Feedback> createFeedback({
    required String courseId,
    required String instructorId,
    required String learnerId,
    required FeedbackType feedbackType,
    required String feedbackText,
    required String feedbackAbout,
    required int rating,
  }) async {
    try {
      print(
        'FeedbackRepository: Creating feedback - Type: ${feedbackType.value}',
      );

      final feedbackData = {
        'course_id': courseId,
        'instructor_id': instructorId,
        'learner_id': learnerId,
        'feedback_type': feedbackType.value,
        'feedback_text': feedbackText,
        'feedback_about': feedbackAbout,
        'rating': rating,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(tableName)
          .insert(feedbackData)
          .select('''
            *,
            learners:learner_id(name, username),
            instructors:instructor_id(name, username),
            courses:course_id(title)
          ''')
          .single();

      print('FeedbackRepository: Feedback created: $response');

      final learnerData = response['learners'] as Map<String, dynamic>?;
      final instructorData = response['instructors'] as Map<String, dynamic>?;
      final courseData = response['courses'] as Map<String, dynamic>?;

      final feedback = Feedback.fromJson({
        ...response,
        'learner_name': learnerData?['name'],
        'learner_avatar': learnerData?['name']
            ?.toString()
            .substring(0, 1)
            .toUpperCase(),
        'instructor_name': instructorData?['name'],
        'course_name': courseData?['title'],
      });

      print(
        'FeedbackRepository: Feedback created successfully: ${feedback.id}',
      );
      return feedback;
    } on PostgrestException catch (e) {
      print('FeedbackRepository: Database error: ${e.message}');
      throw Exception('Failed to create feedback: ${e.message}');
    } catch (e) {
      print('FeedbackRepository: Error creating feedback: $e');
      throw Exception('Failed to create feedback: $e');
    }
  }

  /// Update existing feedback
  Future<Feedback> updateFeedback({
    required String feedbackId,
    String? feedbackText,
    String? feedbackAbout,
    int? rating,
  }) async {
    try {
      print('FeedbackRepository: Updating feedback: $feedbackId');

      final updateData = <String, dynamic>{};
      if (feedbackText != null) updateData['feedback_text'] = feedbackText;
      if (feedbackAbout != null) updateData['feedback_about'] = feedbackAbout;
      if (rating != null) updateData['rating'] = rating;

      final response = await _supabase
          .from(tableName)
          .update(updateData)
          .eq('_id', feedbackId)
          .select('''
            *,
            learners:learner_id(name, username),
            instructors:instructor_id(name, username),
            courses:course_id(title)
          ''')
          .single();

      print('FeedbackRepository: Feedback updated: $response');

      final learnerData = response['learners'] as Map<String, dynamic>?;
      final instructorData = response['instructors'] as Map<String, dynamic>?;
      final courseData = response['courses'] as Map<String, dynamic>?;

      final feedback = Feedback.fromJson({
        ...response,
        'learner_name': learnerData?['name'],
        'learner_avatar': learnerData?['name']
            ?.toString()
            .substring(0, 1)
            .toUpperCase(),
        'instructor_name': instructorData?['name'],
        'course_name': courseData?['title'],
      });

      return feedback;
    } on PostgrestException catch (e) {
      print('FeedbackRepository: Database error: ${e.message}');
      throw Exception('Failed to update feedback: ${e.message}');
    } catch (e) {
      print('FeedbackRepository: Error updating feedback: $e');
      throw Exception('Failed to update feedback: $e');
    }
  }

  /// Delete feedback
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      print('FeedbackRepository: Deleting feedback: $feedbackId');

      await _supabase.from(tableName).delete().eq('_id', feedbackId);

      print('FeedbackRepository: Feedback deleted successfully');
    } on PostgrestException catch (e) {
      print('FeedbackRepository: Database error: ${e.message}');
      throw Exception('Failed to delete feedback: ${e.message}');
    } catch (e) {
      print('FeedbackRepository: Error deleting feedback: $e');
      throw Exception('Failed to delete feedback: $e');
    }
  }

  /// Get feedback statistics for a course
  Future<Map<String, dynamic>> getFeedbackStatistics(String courseId) async {
    try {
      print('FeedbackRepository: Getting feedback statistics for: $courseId');

      // Get course feedback stats
      final courseResponse = await _supabase
          .from(tableName)
          .select('rating')
          .eq('course_id', courseId)
          .eq('feedback_type', 'course');

      // Get instructor feedback stats
      final instructorResponse = await _supabase
          .from(tableName)
          .select('rating')
          .eq('course_id', courseId)
          .eq('feedback_type', 'instructor');

      final courseRatings = (courseResponse as List)
          .map((r) => r['rating'] as int)
          .toList();
      final instructorRatings = (instructorResponse as List)
          .map((r) => r['rating'] as int)
          .toList();

      final stats = {
        'course_rating': courseRatings.isNotEmpty
            ? courseRatings.reduce((a, b) => a + b) / courseRatings.length
            : 0.0,
        'instructor_rating': instructorRatings.isNotEmpty
            ? instructorRatings.reduce((a, b) => a + b) /
                  instructorRatings.length
            : 0.0,
        'total_reviews': courseRatings.length + instructorRatings.length,
        'course_reviews_count': courseRatings.length,
        'instructor_reviews_count': instructorRatings.length,
      };

      print('FeedbackRepository: Statistics: $stats');
      return stats;
    } on PostgrestException catch (e) {
      print('FeedbackRepository: Database error: ${e.message}');
      throw Exception('Failed to get feedback statistics: ${e.message}');
    } catch (e) {
      print('FeedbackRepository: Error getting statistics: $e');
      throw Exception('Failed to get feedback statistics: $e');
    }
  }

  /// Get students enrolled in a course for feedback purposes
  Future<List<Map<String, dynamic>>> getCourseStudents(String courseId) async {
    try {
      print('FeedbackRepository: Getting course students for: $courseId');

      final response = await _supabase
          .from('course_enrollments')
          .select('''
            learner_id,
            created_at,
            learners:learner_id(id, name, username, email)
          ''')
          .eq('course_id', courseId);

      print('FeedbackRepository: Course students response: $response');

      final students = (response as List).map((enrollment) {
        final learnerData = enrollment['learners'] as Map<String, dynamic>?;
        return {
          'id': learnerData?['id'] ?? '',
          'name': learnerData?['name'] ?? 'Unknown',
          'username': learnerData?['username'] ?? '',
          'email': learnerData?['email'] ?? '',
          'avatar':
              learnerData?['name']?.toString().substring(0, 1).toUpperCase() ??
              '?',
          'enrollmentDate': enrollment['created_at'] ?? '',
          'status': 'Active', // Default status since not in schema
        };
      }).toList();

      print('FeedbackRepository: Loaded ${students.length} students');
      return students;
    } on PostgrestException catch (e) {
      print('FeedbackRepository: Database error: ${e.message}');
      throw Exception('Failed to get course students: ${e.message}');
    } catch (e) {
      print('FeedbackRepository: Error getting course students: $e');
      throw Exception('Failed to get course students: $e');
    }
  }

  /// Test database schema and connection
  Future<void> testDatabaseSchema() async {
    try {
      print('FeedbackRepository: Testing database schema...');

      final response = await _supabase
          .from(tableName)
          .select('id, feedback_type, rating')
          .limit(1);

      print(
        'FeedbackRepository: Schema test successful. Sample response: $response',
      );
    } catch (e) {
      print('FeedbackRepository: Schema test failed: $e');
      rethrow;
    }
  }
}
