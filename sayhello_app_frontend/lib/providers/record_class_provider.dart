/// Record Class Provider - State management for record classes
/// Handles record class loading, creation, updates, and deletion

import 'package:flutter/material.dart';
import '../models/record_class.dart';
import '../data/record_class_data.dart';

class RecordClassProvider extends ChangeNotifier {
  final RecordClassRepository _recordClassRepository = RecordClassRepository();

  // Record class state
  List<RecordClass> _recordClasses = [];
  RecordClass? _currentRecordClass;

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
  List<RecordClass> get recordClasses => _recordClasses;
  RecordClass? get currentRecordClass => _currentRecordClass;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get error => _error;
  bool get hasError => _error != null;
  double get uploadProgress => _uploadProgress;

  // =============================
  // RECORD CLASS LOADING
  // =============================

  /// Load all record classes for a course
  Future<void> loadRecordClasses(String courseId) async {
    _setLoading(true);
    _clearError();

    try {
      _recordClasses = await _recordClassRepository.getRecordClasses(courseId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to load record classes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh record classes data
  Future<void> refreshRecordClasses(String courseId) async {
    await loadRecordClasses(courseId);
  }

  // =============================
  // RECORD CLASS CRUD OPERATIONS
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
      final newRecordClass = await _recordClassRepository.addVideoLink(
        courseId: courseId,
        recordedName: recordedName,
        recordedDescription: recordedDescription,
        videoLink: videoLink,
      );

      // Add to local list
      _recordClasses.add(newRecordClass);
      _recordClasses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

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

  /// Update an existing record class
  Future<bool> updateRecordClass({
    required String recordClassId,
    required String recordedName,
    required String recordedDescription,
  }) async {
    _setUpdating(true);
    _clearError();

    try {
      final updatedRecordClass = await _recordClassRepository.updateRecordClass(
        recordClassId: recordClassId,
        recordedName: recordedName,
        recordedDescription: recordedDescription,
      );

      // Update local list
      final index = _recordClasses.indexWhere((rc) => rc.id == recordClassId);
      if (index != -1) {
        _recordClasses[index] = updatedRecordClass;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _setError('Failed to update record class: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// Delete a record class
  Future<bool> deleteRecordClass(String recordClassId) async {
    _setDeleting(true);
    _clearError();

    try {
      await _recordClassRepository.deleteRecordClass(recordClassId);

      // Remove from local list
      _recordClasses.removeWhere((rc) => rc.id == recordClassId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _setError('Failed to delete record class: $e');
      return false;
    } finally {
      _setDeleting(false);
    }
  }

  /// Get record class by ID
  Future<RecordClass?> getRecordClass(String recordClassId) async {
    try {
      _currentRecordClass = await _recordClassRepository.getRecordClassById(
        recordClassId,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return _currentRecordClass;
    } catch (e) {
      _setError('Failed to load record class: $e');
      return null;
    }
  }

  // =============================
  // UTILITY METHODS
  // =============================

  /// Clear current record class
  void clearCurrentRecordClass() {
    _currentRecordClass = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Clear all record classes (useful when switching courses)
  void clearRecordClasses() {
    _recordClasses.clear();
    _currentRecordClass = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Get record classes count
  int get recordClassesCount => _recordClasses.length;

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
