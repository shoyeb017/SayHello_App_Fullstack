import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/data.dart';
import 'dart:io';
import '../services/storage_service.dart';
import '../services/supabase_config.dart';

/// Instructor Provider - State management for instructor operations
class InstructorProvider extends ChangeNotifier {
  final InstructorRepository _repository = InstructorRepository();
  final StorageService _storage = StorageService();

  // Instructor state
  List<Instructor> _instructors = [];
  Instructor? _currentInstructor;
  List<Instructor> _searchResults = [];
  Map<String, dynamic>? _instructorStats;

  // Loading states
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isUpdating = false;
  bool _isRetrying = false;

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
  bool get isRetrying => _isRetrying;
  String? get error => _error;
  bool get hasError => _error != null;

  // =============================
  // INITIALIZATION & SESSION MANAGEMENT
  // =============================

  /// Initialize current instructor from auth session
  Future<void> initializeFromSession() async {
    if (_isLoading) return; // Prevent multiple simultaneous initializations

    try {
      final session = SupabaseConfig.client.auth.currentSession;
      if (session != null) {
        await loadInstructorById(session.user.id);
      }
    } catch (e) {
      _setError('Failed to initialize instructor: $e');
    }
  }

  // =============================
  // INSTRUCTOR OPERATIONS
  // =============================

  /// Load instructor by ID with retry mechanism
  Future<void> loadInstructorById(String id) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        _setRetrying(retryCount > 0);

        // Load instructor and stats in parallel
        final instructorFuture = _repository.getInstructorById(id);
        final statsFuture = _repository.getInstructorStats(id);

        final results = await Future.wait([instructorFuture, statsFuture]);

        final newInstructor = results[0] as Instructor?;
        final newStats = results[1] as Map<String, dynamic>?;

        if (newInstructor == null) {
          throw Exception('Instructor not found');
        }

        // Update state in a single microtask
        Future.microtask(() {
          _currentInstructor = newInstructor;
          _instructorStats = newStats;
          notifyListeners();
        });

        break; // Success, exit retry loop
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          _setError(
            'Failed to load instructor data. Please check your connection and try again.',
          );
          rethrow;
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }

    _setRetrying(false);
    _setLoading(false);
  }

  /// Load all instructors with pagination
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

  /// Create new instructor with optional profile photo
  Future<bool> createInstructor(
    Map<String, dynamic> instructorData, [
    File? profileImage,
  ]) async {
    _setLoading(true);
    _clearError();

    try {
      // First create the instructor record
      final newInstructor = await _repository.createInstructor(instructorData);

      // If we have a profile image, upload it
      if (profileImage != null) {
        final imageUrl = await _storage.uploadProfilePhoto(
          profileImage,
          newInstructor.id,
        );

        // Update the instructor record with the image URL
        final updates = {'profile_image': imageUrl};
        _currentInstructor = await _repository.updateInstructor(
          newInstructor.id,
          updates,
        );
      } else {
        _currentInstructor = newInstructor;
      }

      _instructors.insert(0, _currentInstructor!);

      // Load instructor stats
      await loadInstructorStats(_currentInstructor!.id);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create instructor: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update instructor with optimistic update
  Future<bool> updateInstructor(Map<String, dynamic> updates) async {
    _setUpdating(true);
    _clearError();

    // Store previous state for rollback
    final previousInstructor = _currentInstructor;
    final previousStats = _instructorStats;

    try {
      if (_currentInstructor == null) {
        _setError('No instructor loaded');
        return false;
      }

      // Optimistically update the UI
      _currentInstructor = _currentInstructor!.copyWith(
        name: updates['name'] as String? ?? _currentInstructor!.name,
        email: updates['email'] as String? ?? _currentInstructor!.email,
        profileImage:
            updates['profile_image'] as String? ??
            _currentInstructor!.profileImage,
        bio: updates['bio'] as String? ?? _currentInstructor!.bio,
        gender: updates['gender'] as String? ?? _currentInstructor!.gender,
        country: updates['country'] as String? ?? _currentInstructor!.country,
        nativeLanguage:
            updates['native_language'] as String? ??
            _currentInstructor!.nativeLanguage,
        teachingLanguage:
            updates['teaching_language'] as String? ??
            _currentInstructor!.teachingLanguage,
        yearsOfExperience:
            updates['years_of_experience'] as int? ??
            _currentInstructor!.yearsOfExperience,
      );
      notifyListeners();

      // Perform the actual update
      final updatedInstructor = await _repository.updateInstructor(
        _currentInstructor!.id,
        updates,
      );

      // Update local state
      _currentInstructor = updatedInstructor;
      final index = _instructors.indexWhere(
        (i) => i.id == updatedInstructor.id,
      );
      if (index != -1) {
        _instructors[index] = updatedInstructor;
      }

      // Refresh stats if needed
      if (updates.containsKey('teaching_language') ||
          updates.containsKey('years_of_experience')) {
        await loadInstructorStats(updatedInstructor.id);
      }

      notifyListeners();
      return true;
    } catch (e) {
      // Rollback on error
      _currentInstructor = previousInstructor;
      _instructorStats = previousStats;
      _setError('Failed to update instructor: $e');
      notifyListeners();
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// Delete instructor with confirmation
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

  /// Search instructors with debounce
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
  Future<void> setCurrentInstructor(Instructor? instructor) async {
    if (_currentInstructor?.id == instructor?.id)
      return; // Prevent unnecessary updates

    _currentInstructor = instructor;
    _instructorStats = null;
    notifyListeners();

    if (instructor != null) {
      // Load stats after notifying about the instructor change
      await loadInstructorStats(instructor.id);
    }
  }

  // State management helpers
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    Future.microtask(notifyListeners);
  }

  void _setSearching(bool searching) {
    if (_isSearching == searching) return;
    _isSearching = searching;
    Future.microtask(notifyListeners);
  }

  void _setUpdating(bool updating) {
    if (_isUpdating == updating) return;
    _isUpdating = updating;
    Future.microtask(notifyListeners);
  }

  void _setRetrying(bool retrying) {
    if (_isRetrying == retrying) return;
    _isRetrying = retrying;
    Future.microtask(notifyListeners);
  }

  void _setError(String? error) {
    if (_error == error) return;
    _error = error;
    Future.microtask(notifyListeners);
  }

  void _clearError() {
    if (_error == null) return;
    _error = null;
    Future.microtask(notifyListeners);
  }

  /// Clear all data
  void clear() {
    // Schedule state updates for the next frame
    Future.microtask(() {
      _instructors = [];
      _currentInstructor = null;
      _searchResults = [];
      _instructorStats = null;
      _isLoading = false;
      _isSearching = false;
      _isUpdating = false;
      _isRetrying = false;
      _error = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
