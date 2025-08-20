/// Recorded Class Provider - State management for recorded classes
/// Handles recorded class loading, creation, updates, and deletion

import 'package:flutter/material.dart';
import '../models/recorded_class.dart';
import '../services/recorded_class_service.dart';

class RecordedClassProvider extends ChangeNotifier {
  final RecordedClassService _recordedClassService = RecordedClassService();

  // Recorded class state
  List<RecordedClass> _recordedClasses = [];
  RecordedClass? _currentRecordedClass;

  // Loading states
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Error state
  String? _error;

  // Upload progress
  double _uploadProgress = 0.0;

  // Getters
  List<RecordedClass> get recordedClasses => _recordedClasses;
  RecordedClass? get currentRecordedClass => _currentRecordedClass;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get error => _error;
  bool get hasError => _error != null;
  double get uploadProgress => _uploadProgress;

  // =============================
  // RECORDED CLASS LOADING
  // =============================

  /// Load all recorded classes for a course
  Future<void> loadRecordedClasses(String courseId) async {
    _setLoading(true);
    _clearError();

    try {
      _recordedClasses = await _recordedClassService.getRecordedClasses(
        courseId,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load recorded classes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh recorded classes data
  Future<void> refreshRecordedClasses(String courseId) async {
    await loadRecordedClasses(courseId);
  }

  // =============================
  // RECORDED CLASS CRUD OPERATIONS
  // =============================

  /// Add a video link (YouTube, Vimeo, or direct link) without file upload
  Future<bool> addVideoLink({
    required String courseId,
    required String recordedName,
    required String recordedDescription,
    required String videoLink,
  }) async {
    _setUploading(true);
    _clearError();
    _setUploadProgress(0.0);

    try {
      final newRecordedClass = await _recordedClassService.addVideoLink(
        courseId: courseId,
        recordedName: recordedName,
        recordedDescription: recordedDescription,
        videoLink: videoLink,
      );

      // Add to local list
      _recordedClasses.add(newRecordedClass);
      _recordedClasses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _setUploadProgress(1.0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _setError('Failed to add video link: $e');
      return false;
    } finally {
      _setUploading(false);
    }
  }

  /// Update an existing recorded class
  Future<bool> updateRecordedClass({
    required String recordedClassId,
    required String recordedName,
    required String recordedDescription,
  }) async {
    _setUpdating(true);
    _clearError();

    try {
      final updatedRecordedClass = await _recordedClassService
          .updateRecordedClass(
            recordedClassId: recordedClassId,
            recordedName: recordedName,
            recordedDescription: recordedDescription,
          );

      // Update local list
      final index = _recordedClasses.indexWhere(
        (rc) => rc.id == recordedClassId,
      );
      if (index != -1) {
        _recordedClasses[index] = updatedRecordedClass;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _setError('Failed to update recorded class: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// Delete a recorded class
  Future<bool> deleteRecordedClass(String recordedClassId) async {
    _setDeleting(true);
    _clearError();

    try {
      await _recordedClassService.deleteRecordedClass(recordedClassId);

      // Remove from local list
      _recordedClasses.removeWhere((rc) => rc.id == recordedClassId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _setError('Failed to delete recorded class: $e');
      return false;
    } finally {
      _setDeleting(false);
    }
  }

  /// Get recorded class by ID
  Future<RecordedClass?> getRecordedClass(String recordedClassId) async {
    try {
      _currentRecordedClass = await _recordedClassService.getRecordedClassById(
        recordedClassId,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return _currentRecordedClass;
    } catch (e) {
      _setError('Failed to load recorded class: $e');
      return null;
    }
  }

  // =============================
  // UTILITY METHODS
  // =============================

  /// Clear current recorded class
  void clearCurrentRecordedClass() {
    _currentRecordedClass = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Clear all recorded classes (useful when switching courses)
  void clearRecordedClasses() {
    _recordedClasses.clear();
    _currentRecordedClass = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Get recorded classes count
  int get recordedClassesCount => _recordedClasses.length;

  // =============================
  // PRIVATE METHODS
  // =============================

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _clearError();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setUploading(bool uploading) {
    _isUploading = uploading;
    if (uploading) _clearError();
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

  void _setUploadProgress(double progress) {
    _uploadProgress = progress;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
