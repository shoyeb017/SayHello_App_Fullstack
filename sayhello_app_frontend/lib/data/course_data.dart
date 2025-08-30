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
    try {
      print('Fetching all courses with limit: $limit, offset: $offset');

      final response = await _supabase
          .from('courses')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      print('Retrieved courses from Supabase: ${response.length} courses');

      if (response.isEmpty) {
        print('No courses found');
        return [];
      }

      // Get enrollment counts for all courses in a single query
      final courseIds = response.map((course) => course['id']).toList();

      final enrollmentResponse = await _supabase
          .from('course_enrollments')
          .select('course_id')
          .inFilter('course_id', courseIds);

      // Count enrollments per course
      final enrollmentCounts = <String, int>{};
      for (final enrollment in enrollmentResponse) {
        final courseId = enrollment['course_id'] as String;
        enrollmentCounts[courseId] = (enrollmentCounts[courseId] ?? 0) + 1;
      }

      // Create Course objects with enrollment counts
      final courses = response.map((courseJson) {
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
      print('Error fetching all courses: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get courses: $e');
    }
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
    try {
      print('Enrolling learner $learnerId in course $courseId');

      // Check if already enrolled
      final existing = await _supabase
          .from('course_enrollments')
          .select('id')
          .eq('course_id', courseId)
          .eq('learner_id', learnerId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('Learner is already enrolled in this course');
      }

      final enrollment = CourseEnrollment(
        id: '', // Will be generated by database
        courseId: courseId,
        learnerId: learnerId,
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('course_enrollments')
          .insert(enrollment.toJson(includeId: false))
          .select()
          .single();

      print('Enrollment created successfully: $response');
      return CourseEnrollment.fromJson(response);
    } catch (e, stackTrace) {
      print('Error enrolling in course: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to enroll in course: $e');
    }
  }

  /// Unenroll learner from course
  Future<void> unenrollFromCourse(String courseId, String learnerId) async {
    try {
      print('Unenrolling learner $learnerId from course $courseId');

      await _supabase
          .from('course_enrollments')
          .delete()
          .eq('course_id', courseId)
          .eq('learner_id', learnerId);

      print('Unenrollment successful');
    } catch (e, stackTrace) {
      print('Error unenrolling from course: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to unenroll from course: $e');
    }
  }

  /// Get course enrollments for learner
  Future<List<EnrollmentWithCourse>> getLearnerEnrollments(
    String learnerId, {
    int limit = 50,
  }) async {
    try {
      print('Fetching enrollments for learner: $learnerId');

      final response = await _supabase
          .from('course_enrollments')
          .select('''
            *,
            course:course_id (
              id,
              title,
              description,
              language,
              level,
              total_sessions,
              price,
              start_date,
              end_date,
              status,
              instructor_id,
              thumbnail_url,
              created_at
            )
          ''')
          .eq('learner_id', learnerId)
          .order('created_at', ascending: false)
          .limit(limit);

      print(
        'Retrieved enrollments from Supabase: ${response.length} enrollments',
      );

      final enrollments = response.map((json) {
        // Extract course data
        final courseData = json['course'] as Map<String, dynamic>;

        // Add enrolled_students count (set to 0 for now, can be fetched separately if needed)
        courseData['enrolled_students'] = 0;

        // Create enrollment and course objects
        final enrollment = CourseEnrollment.fromJson(json);
        final course = Course.fromJson(courseData);

        return EnrollmentWithCourse(enrollment: enrollment, course: course);
      }).toList();

      print('Parsed ${enrollments.length} enrollments with course details');
      return enrollments;
    } catch (e, stackTrace) {
      print('Error fetching learner enrollments: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get learner enrollments: $e');
    }
  }

  /// Get enrollments for course
  Future<List<CourseEnrollment>> getCourseEnrollments(
    String courseId, {
    int limit = 100,
  }) async {
    try {
      print('Fetching enrollments for course: $courseId');

      final response = await _supabase
          .from('course_enrollments')
          .select()
          .eq('course_id', courseId)
          .order('created_at', ascending: false)
          .limit(limit);

      print('Retrieved course enrollments: ${response.length} enrollments');

      return response.map((json) => CourseEnrollment.fromJson(json)).toList();
    } catch (e, stackTrace) {
      print('Error fetching course enrollments: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get course enrollments: $e');
    }
  }

  /// Check if learner is enrolled in course
  Future<bool> isEnrolled(String courseId, String learnerId) async {
    try {
      print('Checking enrollment for learner $learnerId in course $courseId');

      final response = await _supabase
          .from('course_enrollments')
          .select('id')
          .eq('course_id', courseId)
          .eq('learner_id', learnerId)
          .maybeSingle();

      final isEnrolled = response != null;
      print('Enrollment status: $isEnrolled');
      return isEnrolled;
    } catch (e, stackTrace) {
      print('Error checking enrollment: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to check enrollment: $e');
    }
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
  // INSTRUCTOR OPERATIONS
  // =============================

  /// Get instructor details by ID
  Future<Map<String, dynamic>?> getInstructorById(String instructorId) async {
    try {
      print('Fetching instructor details for ID: $instructorId');

      final response = await _supabase
          .from('instructors')
          .select('id, name, email, bio, profile_image, years_of_experience')
          .eq('id', instructorId)
          .maybeSingle();

      if (response == null) {
        print('No instructor found with ID: $instructorId');
        return null;
      }

      print('Retrieved instructor details: $response');
      return response;
    } catch (e, stackTrace) {
      print('Error fetching instructor details: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get instructor details: $e');
    }
  }

  /// Get instructor's total students count
  Future<int> getInstructorStudentsCount(String instructorId) async {
    try {
      print('Getting total students count for instructor: $instructorId');

      final response = await _supabase
          .from('course_enrollments')
          .select('learner_id')
          .inFilter('course_id', await _getInstructorCourseIds(instructorId));

      // Count unique learners
      final uniqueLearners = response.map((e) => e['learner_id']).toSet();
      final count = uniqueLearners.length;

      print('Total students for instructor $instructorId: $count');
      return count;
    } catch (e, stackTrace) {
      print('Error getting instructor students count: $e');
      print('Stack trace: $stackTrace');
      return 0; // Return 0 instead of throwing to handle gracefully
    }
  }

  /// Helper method to get instructor's course IDs
  Future<List<String>> _getInstructorCourseIds(String instructorId) async {
    final response = await _supabase
        .from('courses')
        .select('id')
        .eq('instructor_id', instructorId);

    return response.map((course) => course['id'] as String).toList();
  }

  /// Get instructor's average rating across all courses
  Future<double> getInstructorAverageRating(String instructorId) async {
    try {
      print('Getting average rating for instructor: $instructorId');

      final response = await _supabase
          .from('feedback')
          .select('rating')
          .eq('instructor_id', instructorId)
          .eq('feedback_type', 'instructor')
          .not('rating', 'is', null);

      if (response.isEmpty) {
        print('No instructor ratings found');
        return 4.5; // Default rating
      }

      final ratings = response
          .map((feedback) => feedback['rating'] as int)
          .toList();
      final average = ratings.reduce((a, b) => a + b) / ratings.length;

      print('Average rating for instructor $instructorId: $average');
      return average;
    } catch (e, stackTrace) {
      print('Error getting instructor average rating: $e');
      print('Stack trace: $stackTrace');
      return 4.5; // Return default rating instead of throwing
    }
  }

  // =============================
  // FEEDBACK OPERATIONS
  // =============================

  /// Get course feedback and calculate average rating
  Future<Map<String, dynamic>> getCourseFeedback(String courseId) async {
    try {
      print('Getting feedback for course: $courseId');

      final response = await _supabase
          .from('feedback')
          .select('''
            id,
            rating,
            feedback_text,
            created_at,
            learner_id,
            learners!inner(name)
          ''')
          .eq('course_id', courseId)
          .eq('feedback_type', 'course')
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        print('No feedback found for course');
        return {
          'averageRating': 4.5,
          'totalReviews': 0,
          'feedbackList': <Map<String, dynamic>>[],
        };
      }

      // Calculate average rating
      final ratings = response
          .where((feedback) => feedback['rating'] != null)
          .map((feedback) => feedback['rating'] as int)
          .toList();

      final averageRating = ratings.isEmpty
          ? 4.5
          : ratings.reduce((a, b) => a + b) / ratings.length;

      print(
        'Course feedback - Average: $averageRating, Total: ${response.length}',
      );

      return {
        'averageRating': averageRating,
        'totalReviews': response.length,
        'feedbackList': response,
      };
    } catch (e, stackTrace) {
      print('Error getting course feedback: $e');
      print('Stack trace: $stackTrace');
      return {
        'averageRating': 4.5,
        'totalReviews': 0,
        'feedbackList': <Map<String, dynamic>>[],
      };
    }
  }

  /// Get course statistics including enrollments and feedback
  Future<Map<String, dynamic>> getCourseStats(String courseId) async {
    try {
      print('Getting course statistics for: $courseId');

      // Get enrollment count
      final enrollmentCount = await getEnrollmentCount(courseId);

      // Get feedback data
      final feedbackData = await getCourseFeedback(courseId);

      return {
        'enrollmentCount': enrollmentCount,
        'averageRating': feedbackData['averageRating'],
        'totalReviews': feedbackData['totalReviews'],
        'feedbackList': feedbackData['feedbackList'],
      };
    } catch (e, stackTrace) {
      print('Error getting course stats: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get course stats: $e');
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
