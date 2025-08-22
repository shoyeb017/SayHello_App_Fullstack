/// Feedback Provider - State management for feedback system
/// Handles course reviews, instructor reviews, and student feedback

import 'package:flutter/material.dart';
import '../models/feedback.dart' as feedback_model;
import '../data/feedback_data.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackRepository _feedbackRepository = FeedbackRepository();

  // Feedback state
  List<feedback_model.Feedback> _courseFeedback = [];
  List<feedback_model.Feedback> _instructorFeedback = [];
  List<feedback_model.Feedback> _studentFeedback = [];
  List<Map<String, dynamic>> _courseStudents = [];
  Map<String, dynamic> _feedbackStatistics = {};

  // Loading states
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Error state
  String? _error;

  // Getters
  List<feedback_model.Feedback> get courseFeedback => _courseFeedback;
  List<feedback_model.Feedback> get instructorFeedback => _instructorFeedback;
  List<feedback_model.Feedback> get studentFeedback => _studentFeedback;
  List<Map<String, dynamic>> get courseStudents {
    print(
      'FeedbackProvider: courseStudents getter called, returning ${_courseStudents.length} items',
    );
    return _courseStudents;
  }

  Map<String, dynamic> get feedbackStatistics => _feedbackStatistics;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get error => _error;
  bool get hasError => _error != null;

  // Computed properties for statistics
  double get averageCourseRating {
    return _feedbackStatistics['course_rating']?.toDouble() ?? 0.0;
  }

  double get averageInstructorRating {
    return _feedbackStatistics['instructor_rating']?.toDouble() ?? 0.0;
  }

  int get totalReviews {
    return _feedbackStatistics['total_reviews']?.toInt() ?? 0;
  }

  // =============================
  // FEEDBACK LOADING
  // =============================

  /// Load all feedback for a course (course reviews, instructor reviews, students)
  Future<void> loadCourseFeedback(String courseId) async {
    _setLoading(true);
    _clearError();

    try {
      // Load all feedback types and statistics in parallel
      final results = await Future.wait([
        _feedbackRepository.getCourseFeedback(courseId),
        _feedbackRepository.getInstructorFeedback(courseId),
        _feedbackRepository.getStudentFeedback(courseId),
        _feedbackRepository.getFeedbackStatistics(courseId),
        _feedbackRepository.getCourseStudents(courseId),
      ]);

      _courseFeedback = results[0] as List<feedback_model.Feedback>;
      _instructorFeedback = results[1] as List<feedback_model.Feedback>;
      _studentFeedback = results[2] as List<feedback_model.Feedback>;
      _feedbackStatistics = results[3] as Map<String, dynamic>;
      _courseStudents = results[4] as List<Map<String, dynamic>>;

      print(
        'FeedbackProvider: Course students set to: ${_courseStudents.length} items',
      );
      print('FeedbackProvider: Course students data: $_courseStudents');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('FeedbackProvider: Calling notifyListeners()');
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load feedback: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load instructor feedback specifically
  Future<void> loadInstructorFeedback(String instructorId) async {
    _setLoading(true);
    _clearError();

    try {
      _instructorFeedback = await _feedbackRepository.getInstructorFeedback(
        instructorId,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load instructor feedback: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh feedback data
  Future<void> refreshFeedback(String courseId) async {
    await loadCourseFeedback(courseId);
  }

  // =============================
  // FEEDBACK CRUD OPERATIONS
  // =============================

  /// Submit course feedback (student rating course)
  Future<bool> submitCourseFeedback({
    required String courseId,
    required String instructorId,
    required String learnerId,
    required String feedbackText,
    required String feedbackAbout,
    required int rating,
  }) async {
    _setSubmitting(true);
    _clearError();

    try {
      final feedback = await _feedbackRepository.createFeedback(
        courseId: courseId,
        instructorId: instructorId,
        learnerId: learnerId,
        feedbackType: feedback_model.FeedbackType.course,
        feedbackText: feedbackText,
        feedbackAbout: feedbackAbout,
        rating: rating,
      );

      // Add to local list
      _courseFeedback.insert(0, feedback);

      // Update statistics
      await _updateStatistics(courseId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _setError('Failed to submit course feedback: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Submit instructor feedback (student rating instructor)
  Future<bool> submitInstructorFeedback({
    required String courseId,
    required String instructorId,
    required String learnerId,
    required String feedbackText,
    required String feedbackAbout,
    required int rating,
  }) async {
    _setSubmitting(true);
    _clearError();

    try {
      final feedback = await _feedbackRepository.createFeedback(
        courseId: courseId,
        instructorId: instructorId,
        learnerId: learnerId,
        feedbackType: feedback_model.FeedbackType.instructor,
        feedbackText: feedbackText,
        feedbackAbout: feedbackAbout,
        rating: rating,
      );

      // Add to local list
      _instructorFeedback.insert(0, feedback);

      // Update statistics
      await _updateStatistics(courseId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _setError('Failed to submit instructor feedback: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Submit student feedback (instructor giving feedback to student)
  Future<bool> submitStudentFeedback({
    required String courseId,
    required String instructorId,
    required String learnerId,
    required String feedbackText,
    required String feedbackAbout,
    required int rating,
  }) async {
    _setSubmitting(true);
    _clearError();

    try {
      final feedback = await _feedbackRepository.createFeedback(
        courseId: courseId,
        instructorId: instructorId,
        learnerId: learnerId,
        feedbackType: feedback_model.FeedbackType.learner,
        feedbackText: feedbackText,
        feedbackAbout: feedbackAbout,
        rating: rating,
      );

      // Add to local list
      _studentFeedback.insert(0, feedback);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _setError('Failed to submit student feedback: $e');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Update existing feedback
  Future<bool> updateFeedback({
    required String feedbackId,
    String? feedbackText,
    String? feedbackAbout,
    int? rating,
  }) async {
    _setUpdating(true);
    _clearError();

    try {
      final updatedFeedback = await _feedbackRepository.updateFeedback(
        feedbackId: feedbackId,
        feedbackText: feedbackText,
        feedbackAbout: feedbackAbout,
        rating: rating,
      );

      // Update in appropriate local list
      _updateLocalFeedback(updatedFeedback);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _setError('Failed to update feedback: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// Delete feedback
  Future<bool> deleteFeedback(
    String feedbackId,
    feedback_model.FeedbackType feedbackType,
  ) async {
    _setDeleting(true);
    _clearError();

    try {
      await _feedbackRepository.deleteFeedback(feedbackId);

      // Remove from appropriate local list
      switch (feedbackType) {
        case feedback_model.FeedbackType.course:
          _courseFeedback.removeWhere((f) => f.id == feedbackId);
          break;
        case feedback_model.FeedbackType.instructor:
          _instructorFeedback.removeWhere((f) => f.id == feedbackId);
          break;
        case feedback_model.FeedbackType.learner:
          _studentFeedback.removeWhere((f) => f.id == feedbackId);
          break;
        case feedback_model.FeedbackType.general:
          // Handle general feedback if needed
          break;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _setError('Failed to delete feedback: $e');
      return false;
    } finally {
      _setDeleting(false);
    }
  }

  // =============================
  // UTILITY METHODS
  // =============================

  /// Get student by ID from the loaded students list
  Map<String, dynamic>? getStudentById(String studentId) {
    try {
      return _courseStudents.firstWhere((s) => s['id'] == studentId);
    } catch (e) {
      return null;
    }
  }

  /// Clear all feedback data
  void clearFeedback() {
    _courseFeedback.clear();
    _instructorFeedback.clear();
    _studentFeedback.clear();
    _courseStudents.clear();
    _feedbackStatistics.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Get feedback counts by type
  Map<String, int> get feedbackCounts {
    return {
      'course': _courseFeedback.length,
      'instructor': _instructorFeedback.length,
      'student': _studentFeedback.length,
    };
  }

  // =============================
  // PRIVATE HELPER METHODS
  // =============================

  void _updateLocalFeedback(feedback_model.Feedback updatedFeedback) {
    final index = _courseFeedback.indexWhere((f) => f.id == updatedFeedback.id);
    if (index != -1) {
      _courseFeedback[index] = updatedFeedback;
      return;
    }

    final instructorIndex = _instructorFeedback.indexWhere(
      (f) => f.id == updatedFeedback.id,
    );
    if (instructorIndex != -1) {
      _instructorFeedback[instructorIndex] = updatedFeedback;
      return;
    }

    final studentIndex = _studentFeedback.indexWhere(
      (f) => f.id == updatedFeedback.id,
    );
    if (studentIndex != -1) {
      _studentFeedback[studentIndex] = updatedFeedback;
    }
  }

  Future<void> _updateStatistics(String courseId) async {
    try {
      _feedbackStatistics = await _feedbackRepository.getFeedbackStatistics(
        courseId,
      );
    } catch (e) {
      print('Failed to update statistics: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _clearError();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    if (submitting) _clearError();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    if (updating) _clearError();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setDeleting(bool deleting) {
    _isDeleting = deleting;
    if (deleting) _clearError();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String error) {
    _error = error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _clearError() {
    _error = null;
  }
}
