/// Instructor Provider - State management for instructor operations
/// Handles instructor profiles and teaching operations

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/data.dart';

class InstructorProvider extends ChangeNotifier {
  final InstructorRepository _repository = InstructorRepository();

  // Instructor state
  List<Instructor> _instructors = [];
  Instructor? _currentInstructor;
  List<Instructor> _searchResults = [];
  Map<String, dynamic>? _instructorStats;

  // Loading states
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isUpdating = false;

  // Error state
  String? _error;

  // Getters
  List<Instructor> get instructors => _instructors;
  Instructor? get currentInstructor => _currentInstructor;
  List<Instructor> get searchResults => _searchResults;
  Map<String, dynamic>? get instructorStats => _instructorStats;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  bool get hasError => _error != null;

  // =============================
  // INSTRUCTOR OPERATIONS
  // =============================

  /// Load all instructors
  Future<void> loadAllInstructors({
    int limit = 20,
    int offset = 0,
    bool append = false,
  }) async {
    if (!append) _setLoading(true);
    _clearError();

    try {
      final instructors = await _repository.getAllInstructors(
        limit: limit,
        offset: offset,
      );

      if (append) {
        _instructors.addAll(instructors);
      } else {
        _instructors = instructors;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load instructors: $e');
    } finally {
      if (!append) _setLoading(false);
    }
  }

  /// Get instructor by ID
  Future<void> loadInstructorById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      _currentInstructor = await _repository.getInstructorById(id);

      // Load instructor statistics
      if (_currentInstructor != null) {
        await loadInstructorStats(id);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load instructor: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new instructor
  Future<bool> createInstructor(Instructor instructor) async {
    _setLoading(true);
    _clearError();

    try {
      final newInstructor = await _repository.createInstructor(instructor);
      _instructors.insert(0, newInstructor);
      _currentInstructor = newInstructor;

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create instructor: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update instructor
  Future<bool> updateInstructor(Map<String, dynamic> updates) async {
    _setUpdating(true);
    _clearError();

    try {
      if (_currentInstructor == null) {
        _setError('No instructor loaded');
        return false;
      }
      final updatedInstructor = await _repository.updateInstructor(
        _currentInstructor!.copyWith(
          id: _currentInstructor!.id,
          profileImage:
              updates['profile_image'] ?? _currentInstructor!.profileImage,
          name: updates['name'] ?? _currentInstructor!.name,
          email: updates['email'] ?? _currentInstructor!.email,
          username: updates['username'] ?? _currentInstructor!.username,
          dateOfBirth: updates['date_of_birth'] != null
              ? DateTime.parse(updates['date_of_birth'])
              : _currentInstructor!.dateOfBirth,
          gender: updates['gender'] ?? _currentInstructor!.gender,
          country: updates['country'] ?? _currentInstructor!.country,
          bio: updates['bio'] ?? _currentInstructor!.bio,
          nativeLanguage:
              updates['native_language'] ?? _currentInstructor!.nativeLanguage,
          teachingLanguage:
              updates['teaching_language'] ??
              _currentInstructor!.teachingLanguage,
          yearsOfExperience:
              updates['years_of_experience'] ??
              _currentInstructor!.yearsOfExperience,
          createdAt: updates['created_at'] != null
              ? DateTime.parse(updates['created_at'])
              : _currentInstructor!.createdAt,
        ),
      );
      // Update in list
      final index = _instructors.indexWhere(
        (i) => i.id == updatedInstructor.id,
      );
      if (index != -1) {
        _instructors[index] = updatedInstructor;
      }
      // Update current instructor
      _currentInstructor = updatedInstructor;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update instructor: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// Delete instructor
  Future<bool> deleteInstructor(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteInstructor(id);

      // Remove from list
      _instructors.removeWhere((instructor) => instructor.id == id);

      // Clear current instructor if it's the same
      if (_currentInstructor?.id == id) {
        _currentInstructor = null;
        _instructorStats = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete instructor: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =============================
  // SEARCH & FILTER OPERATIONS
  // =============================

  /// Search instructors
  Future<void> searchInstructors(
    String query, {
    bool clearPrevious = true,
  }) async {
    _setSearching(true);
    _clearError();

    try {
      final results = await _repository.searchInstructors(
        query: query.isEmpty ? null : query,
      );

      if (clearPrevious) {
        _searchResults = results;
      } else {
        _searchResults.addAll(results);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to search instructors: $e');
    } finally {
      _setSearching(false);
    }
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // =============================
  // STATISTICS OPERATIONS
  // =============================

  /// Load instructor statistics
  Future<void> loadInstructorStats(String instructorId) async {
    _clearError();

    try {
      _instructorStats = await _repository.getInstructorStats(instructorId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load instructor stats: $e');
    }
  }

  // =============================
  // UTILITY METHODS
  // =============================

  /// Get instructor from list by ID
  Instructor? getInstructorById(String id) {
    try {
      return _instructors.firstWhere((instructor) => instructor.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Set current instructor
  void setCurrentInstructor(Instructor? instructor) {
    _currentInstructor = instructor;
    if (instructor != null) {
      loadInstructorStats(instructor.id);
    } else {
      _instructorStats = null;
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
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
    _instructors = [];
    _currentInstructor = null;
    _searchResults = [];
    _instructorStats = null;
    _isLoading = false;
    _isSearching = false;
    _isUpdating = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
