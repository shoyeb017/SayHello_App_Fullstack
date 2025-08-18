/// Course Provider - State management for course-related operations
/// Handles courses, enrollments, and course portal functionality

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/data.dart';
import '../services/storage_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository = CourseRepository();
  final StorageService _storage = StorageService();

  // Course state
  List<Course> _courses = [];
  Course? _currentCourse;
  List<CourseEnrollment> _enrollments = [];
  List<EnrollmentWithCourse> _learnerEnrollments = [];
  List<Course> _searchResults = [];

  // Loading states
  bool _isLoading = false;
  bool _isEnrollmentsLoading = false;
  bool _isSearching = false;

  // Error state
  String? _error;

  // Getters
  List<Course> get courses => _courses;
  Course? get currentCourse => _currentCourse;
  List<CourseEnrollment> get enrollments => _enrollments;
  List<EnrollmentWithCourse> get learnerEnrollments => _learnerEnrollments;
  List<Course> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isEnrollmentsLoading => _isEnrollmentsLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  bool get hasError => _error != null;

  // =============================
  // COURSE CRUD OPERATIONS
  // =============================

  /// Load all courses with pagination
  Future<void> loadCourses({int limit = 50, int offset = 0}) async {
    _setLoading(true);
    _clearError();

    try {
      final courseList = await _repository.getAllCourses(
        limit: limit,
        offset: offset,
      );
      if (offset == 0) {
        _courses = courseList;
      } else {
        _courses.addAll(courseList);
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to load courses: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load course by ID
  Future<void> loadCourse(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final course = await _repository.getCourseById(id);
      _currentCourse = course;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load course: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load courses by instructor
  Future<void> loadInstructorCourses(String instructorId) async {
    _setLoading(true);
    _clearError();

    try {
      _courses = await _repository.getCoursesByInstructor(instructorId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load instructor courses: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new course with optional thumbnail
  Future<bool> createCourse(
    Map<String, dynamic> courseData, [
    File? thumbnail,
  ]) async {
    _setLoading(true);
    _clearError();

    try {
      // If thumbnail provided, upload it first
      if (thumbnail != null) {
        final thumbnailUrl = await _storage.uploadCourseThumbnail(
          thumbnail,
          DateTime.now().millisecondsSinceEpoch.toString(),
        );
        courseData['thumbnail_url'] = thumbnailUrl;
      }

      final newCourse = await _repository.createCourse(courseData);
      _courses.insert(0, newCourse);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create course: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update course
  Future<bool> updateCourse(String id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedCourse = await _repository.updateCourse(id, updates);

      // Update in courses list
      final index = _courses.indexWhere((course) => course.id == id);
      if (index != -1) {
        _courses[index] = updatedCourse;
      }

      // Update current course if it's the same
      if (_currentCourse?.id == id) {
        _currentCourse = updatedCourse;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update course: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete course
  Future<bool> deleteCourse(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteCourse(id);

      // Remove from courses list
      _courses.removeWhere((course) => course.id == id);

      // Clear current course if it's the same
      if (_currentCourse?.id == id) {
        _currentCourse = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete course: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =============================
  // SEARCH AND FILTER OPERATIONS
  // =============================

  /// Search courses by title or description
  Future<void> searchCourses(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _clearError();
    notifyListeners();

    try {
      _searchResults = await _repository.searchCourses(query);
    } catch (e) {
      _setError('Failed to search courses: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Get courses by language
  Future<List<Course>> getCoursesByLanguage(String language) async {
    _clearError();

    try {
      return await _repository.getCoursesByLanguage(language);
    } catch (e) {
      _setError('Failed to get courses by language: $e');
      return [];
    }
  }

  /// Get courses by level
  Future<List<Course>> getCoursesByLevel(String level) async {
    _clearError();

    try {
      return await _repository.getCoursesByLevel(level);
    } catch (e) {
      _setError('Failed to get courses by level: $e');
      return [];
    }
  }

  /// Get courses by status
  Future<List<Course>> getCoursesByStatus(String status) async {
    _clearError();

    try {
      return await _repository.getCoursesByStatus(status);
    } catch (e) {
      _setError('Failed to get courses by status: $e');
      return [];
    }
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // =============================
  // ENROLLMENT OPERATIONS
  // =============================

  /// Enroll learner in course
  Future<bool> enrollInCourse(String courseId, String learnerId) async {
    _clearError();

    try {
      final enrollment = await _repository.enrollInCourse(courseId, learnerId);
      _enrollments.add(enrollment);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to enroll in course: $e');
      return false;
    }
  }

  /// Unenroll learner from course
  Future<bool> unenrollFromCourse(String courseId, String learnerId) async {
    _clearError();

    try {
      await _repository.unenrollFromCourse(courseId, learnerId);
      _enrollments.removeWhere(
        (enrollment) =>
            enrollment.courseId == courseId &&
            enrollment.learnerId == learnerId,
      );
      _learnerEnrollments.removeWhere(
        (enrollment) =>
            enrollment.enrollment.courseId == courseId &&
            enrollment.enrollment.learnerId == learnerId,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to unenroll from course: $e');
      return false;
    }
  }

  /// Load learner enrollments
  Future<void> loadLearnerEnrollments(String learnerId) async {
    _isEnrollmentsLoading = true;
    _clearError();
    notifyListeners();

    try {
      _learnerEnrollments = await _repository.getLearnerEnrollments(learnerId);
    } catch (e) {
      _setError('Failed to load learner enrollments: $e');
    } finally {
      _isEnrollmentsLoading = false;
      notifyListeners();
    }
  }

  /// Load course enrollments
  Future<void> loadCourseEnrollments(String courseId) async {
    _isEnrollmentsLoading = true;
    _clearError();
    notifyListeners();

    try {
      _enrollments = await _repository.getCourseEnrollments(courseId);
    } catch (e) {
      _setError('Failed to load course enrollments: $e');
    } finally {
      _isEnrollmentsLoading = false;
      notifyListeners();
    }
  }

  /// Check if learner is enrolled in course
  Future<bool> isEnrolled(String courseId, String learnerId) async {
    try {
      return await _repository.isEnrolled(courseId, learnerId);
    } catch (e) {
      _setError('Failed to check enrollment: $e');
      return false;
    }
  }

  /// Get enrollment count for course
  Future<int> getEnrollmentCount(String courseId) async {
    try {
      return await _repository.getEnrollmentCount(courseId);
    } catch (e) {
      _setError('Failed to get enrollment count: $e');
      return 0;
    }
  }

  // =============================
  // UTILITY METHODS
  // =============================

  /// Get courses by filter criteria
  List<Course> getFilteredCourses({
    String? language,
    String? level,
    String? status,
    double? maxPrice,
  }) {
    return _courses.where((course) {
      if (language != null && course.language != language) return false;
      if (level != null && course.level != level) return false;
      if (status != null && course.status != status) return false;
      if (maxPrice != null && course.price > maxPrice) return false;
      return true;
    }).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear all data
  void clear() {
    _courses = [];
    _currentCourse = null;
    _enrollments = [];
    _learnerEnrollments = [];
    _searchResults = [];
    _isLoading = false;
    _isEnrollmentsLoading = false;
    _isSearching = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
