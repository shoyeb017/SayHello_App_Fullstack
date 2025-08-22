/// Course Repository - Handles all course-related database operations
/// Provides CRUD operations, enrollments, and course management functionality

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class CourseRepository {
  final _supabase = Supabase.instance.client;

  // =============================
  // COURSE CRUD OPERATIONS
  // =============================

  /// Create a new course
  Future<Course> createCourse(Map<String, dynamic> courseData) async {
    try {
      print('Attempting to create course with data: $courseData');

      // Ensure all required fields are present and correctly formatted
      final validatedData = {
        'title': courseData['title'],
        'description': courseData['description'],
        'language': courseData['language'],
        'level': courseData['level'],
        'total_sessions': courseData['total_sessions'],
        'price': courseData['price'],
        'start_date': courseData['start_date'],
        'end_date': courseData['end_date'],
        'status': courseData['status'],
        'instructor_id': courseData['instructor_id'],
        'thumbnail_url': courseData['thumbnail_url'],
        'created_at': courseData['created_at'],
      };

      print('Inserting course into Supabase...');
      final response = await _supabase
          .from('courses')
          .insert(validatedData)
          .select()
          .single();

      print('Course created successfully. Response: $response');
      return Course.fromJson(response);
    } catch (e, stackTrace) {
      print('Failed to create course: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to create course: $e');
    }
  }

  /// Get course by ID
  Future<Course?> getCourseById(String id) async {
    try {
      print('Fetching course by ID: $id');
      final response = await _supabase
          .from('courses')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        print('No course found with ID: $id');
        return null;
      }

      print('Course retrieved: $response');
      return Course.fromJson(response);
    } catch (e, stackTrace) {
      print('Error fetching course by ID: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get course: $e');
    }
  }

  /// Get all courses with pagination
  Future<List<Course>> getAllCourses({int limit = 50, int offset = 0}) async {
    // TODO: Implement with Supabase
    /*
    try {
      final response = await _supabase
          .from('courses')
          .select()
          .range(offset, offset + limit - 1);
      
      return response.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get courses: $e');
    }
    */
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Get courses by instructor with enrollment counts
  Future<List<Course>> getCoursesByInstructor(
    String instructorId, {
    int limit = 50,
  }) async {
    try {
      print('Fetching courses for instructor: $instructorId');

      // First, get all courses for the instructor
      final coursesResponse = await _supabase
          .from('courses')
          .select()
          .eq('instructor_id', instructorId)
          .order('created_at', ascending: false)
          .limit(limit);

      print('Retrieved courses from Supabase: $coursesResponse');

      if (coursesResponse.isEmpty) {
        print('No courses found for instructor');
        return [];
      }

      // Get enrollment counts for all courses in a single query
      final courseIds = coursesResponse.map((course) => course['id']).toList();

      final enrollmentResponse = await _supabase
          .from('course_enrollments')
          .select('course_id')
          .inFilter('course_id', courseIds);

      print(
        'Retrieved enrollments: ${enrollmentResponse.length} total enrollments',
      );

      // Count enrollments per course
      final enrollmentCounts = <String, int>{};
      for (final enrollment in enrollmentResponse) {
        final courseId = enrollment['course_id'] as String;
        enrollmentCounts[courseId] = (enrollmentCounts[courseId] ?? 0) + 1;
      }

      print('Enrollment counts: $enrollmentCounts');

      // Create Course objects with enrollment counts
      final courses = coursesResponse.map((courseJson) {
        final courseId = courseJson['id'] as String;
        final enrolledStudents = enrollmentCounts[courseId] ?? 0;

        // Add enrolled_students to the JSON data
        final enrichedJson = Map<String, dynamic>.from(courseJson);
        enrichedJson['enrolled_students'] = enrolledStudents;

        return Course.fromJson(enrichedJson);
      }).toList();

      print('Parsed ${courses.length} courses with enrollment counts');
      return courses;
    } catch (e, stackTrace) {
      print('Error fetching instructor courses: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get instructor courses: $e');
    }
  }

  /// Get courses by language
  Future<List<Course>> getCoursesByLanguage(
    String language, {
    int limit = 50,
  }) async {
    // TODO: Implement with Supabase
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Get courses by level
  Future<List<Course>> getCoursesByLevel(String level, {int limit = 50}) async {
    // TODO: Implement with Supabase
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Get courses by status
  Future<List<Course>> getCoursesByStatus(
    String status, {
    int limit = 50,
  }) async {
    // TODO: Implement with Supabase
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Search courses by title or description
  Future<List<Course>> searchCourses(String query, {int limit = 20}) async {
    // TODO: Implement with Supabase
    /*
    try {
      final response = await _supabase
          .from('courses')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .limit(limit);
      
      return response.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search courses: $e');
    }
    */
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Update course
  Future<Course> updateCourse(String id, Map<String, dynamic> updates) async {
    try {
      print('Updating course $id with data: $updates');

      // Remove any fields that shouldn't be updated
      final sanitizedUpdates = Map<String, dynamic>.from(updates);
      sanitizedUpdates.remove('id');
      sanitizedUpdates.remove('created_at');
      sanitizedUpdates.remove('updated_at'); // This column doesn't exist

      final response = await _supabase
          .from('courses')
          .update(sanitizedUpdates)
          .eq('id', id)
          .select()
          .single();

      print('Course updated successfully: $response');
      return Course.fromJson(response);
    } catch (e, stackTrace) {
      print('Error updating course: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to update course: $e');
    }
  }

  /// Delete course
  Future<void> deleteCourse(String id) async {
    try {
      print('Deleting course: $id');

      await _supabase.from('courses').delete().eq('id', id);

      print('Course deleted successfully');
    } catch (e, stackTrace) {
      print('Error deleting course: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to delete course: $e');
    }
  }

  // =============================
  // ENROLLMENT OPERATIONS
  // =============================

  /// Enroll learner in course
  Future<CourseEnrollment> enrollInCourse(
    String courseId,
    String learnerId,
  ) async {
    // TODO: Implement with Supabase
    /*
    try {
      final enrollment = CourseEnrollment(
        id: '', // Will be generated
        courseId: courseId,
        learnerId: learnerId,
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('course_enrollments')
          .insert(enrollment.toJson())
          .select()
          .single();
      
      return CourseEnrollment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to enroll in course: $e');
    }
    */
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Unenroll learner from course
  Future<void> unenrollFromCourse(String courseId, String learnerId) async {
    // TODO: Implement with Supabase
    /*
    try {
      await _supabase
          .from('course_enrollments')
          .delete()
          .eq('course_id', courseId)
          .eq('learner_id', learnerId);
    } catch (e) {
      throw Exception('Failed to unenroll from course: $e');
    }
    */
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Get course enrollments for learner
  Future<List<EnrollmentWithCourse>> getLearnerEnrollments(
    String learnerId, {
    int limit = 50,
  }) async {
    // TODO: Implement with Supabase
    /*
    try {
      final response = await _supabase
          .from('course_enrollments')
          .select('*, course:courses(*)')
          .eq('learner_id', learnerId)
          .limit(limit);
      
      return response.map((json) => EnrollmentWithCourse.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get learner enrollments: $e');
    }
    */
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Get enrollments for course
  Future<List<CourseEnrollment>> getCourseEnrollments(
    String courseId, {
    int limit = 100,
  }) async {
    // TODO: Implement with Supabase
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Check if learner is enrolled in course
  Future<bool> isEnrolled(String courseId, String learnerId) async {
    // TODO: Implement with Supabase
    /*
    try {
      final response = await _supabase
          .from('course_enrollments')
          .select('id')
          .eq('course_id', courseId)
          .eq('learner_id', learnerId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      throw Exception('Failed to check enrollment: $e');
    }
    */
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Get enrollment count for course
  Future<int> getEnrollmentCount(String courseId) async {
    try {
      print('Getting enrollment count for course: $courseId');

      final response = await _supabase
          .from('course_enrollments')
          .select('id')
          .eq('course_id', courseId);

      final count = response.length;
      print('Enrollment count for course $courseId: $count');
      return count;
    } catch (e, stackTrace) {
      print('Error getting enrollment count: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get enrollment count: $e');
    }
  }

  // =============================
  // COURSE PORTAL OPERATIONS
  // =============================

  /// Get course portal content
  Future<List<CoursePortal>> getCoursePortalContent(String courseId) async {
    // TODO: Implement with Supabase
    /*
    try {
      final response = await _supabase
          .from('course_portal')
          .select()
          .eq('course_id', courseId)
          .order('order');
      
      return response.map((json) => CoursePortal.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get course portal content: $e');
    }
    */
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Add course portal content
  Future<CoursePortal> addCoursePortalContent(CoursePortal portal) async {
    // TODO: Implement with Supabase
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Update course portal content
  Future<CoursePortal> updateCoursePortalContent(
    String id,
    Map<String, dynamic> updates,
  ) async {
    // TODO: Implement with Supabase
    throw UnimplementedError('Add Supabase dependency first');
  }

  /// Delete course portal content
  Future<void> deleteCoursePortalContent(String id) async {
    // TODO: Implement with Supabase
    throw UnimplementedError('Add Supabase dependency first');
  }

  // =============================
  // COURSE ANALYTICS
  // =============================

  /// Get course statistics
  Future<Map<String, dynamic>> getCourseStats(String courseId) async {
    // TODO: Implement with Supabase
    /*
    try {
      final enrollmentCount = await getEnrollmentCount(courseId);
      final course = await getCourseById(courseId);
      
      return {
        'enrollmentCount': enrollmentCount,
        'isActive': course?.isActive ?? false,
        'hasStarted': course?.hasStarted ?? false,
        'hasEnded': course?.hasEnded ?? false,
      };
    } catch (e) {
      throw Exception('Failed to get course stats: $e');
    }
    */
    throw UnimplementedError('Add Supabase dependency first');
  }

  // =============================
  // COURSE RATING OPERATIONS
  // =============================

  /// Get average rating for a course based on feedback
  Future<double> getCourseAverageRating(String courseId) async {
    try {
      final response = await _supabase
          .from('feedback')
          .select('rating')
          .eq('course_id', courseId);

      if (response.isEmpty) {
        return 0.0;
      }

      final ratings = response
          .map((item) => (item['rating'] as num).toDouble())
          .toList();
      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

      return double.parse(averageRating.toStringAsFixed(1));
    } catch (e) {
      print('Failed to get course average rating: $e');
      return 0.0;
    }
  }

  // =============================
  // REAL-TIME SUBSCRIPTIONS
  // =============================

  /// Subscribe to course changes
  // RealtimeChannel subscribeToCourse(String courseId, Function(Course) onUpdate) {
  //   return _supabase.channel('course_$courseId')...
  // }

  /// Subscribe to course enrollments
  // RealtimeChannel subscribeToCourseEnrollments(String courseId, Function(List<CourseEnrollment>) onUpdate) {
  //   return _supabase.channel('enrollments_$courseId')...
  // }
}
