/// StudyMaterial Provider - State management for study materials
/// Handles loading, uploading, editing, and deleting study materials

import 'package:flutter/foundation.dart';
import '../models/study_material.dart';
import '../services/study_material_service.dart';

class StudyMaterialProvider with ChangeNotifier {
  final StudyMaterialService _studyMaterialService = StudyMaterialService();

  List<StudyMaterial> _studyMaterials = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<StudyMaterial> get studyMaterials => List.unmodifiable(_studyMaterials);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasStudyMaterials => _studyMaterials.isNotEmpty;

  /// Load study materials for a specific course
  Future<void> loadStudyMaterials(String courseId) async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      print(
        'StudyMaterialProvider: Loading study materials for course: $courseId',
      );

      final materials = await _studyMaterialService.getStudyMaterials(courseId);

      _studyMaterials = materials;
      print(
        'StudyMaterialProvider: Loaded ${materials.length} study materials',
      );

      notifyListeners();
    } catch (e) {
      print('StudyMaterialProvider: Error loading study materials: $e');
      _setError('Failed to load study materials: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Upload a new study material
  Future<bool> uploadStudyMaterial({
    required String courseId,
    required String title,
    required String description,
    required String type,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    if (_isLoading) return false;

    _setLoading(true);
    _setError(null);

    try {
      print('StudyMaterialProvider: Uploading study material: $title');

      final studyMaterial = await _studyMaterialService.uploadStudyMaterial(
        courseId: courseId,
        title: title,
        description: description,
        type: type,
        fileName: fileName,
        fileBytes: fileBytes,
      );

      // Add to the beginning of the list (newest first)
      _studyMaterials.insert(0, studyMaterial);

      print(
        'StudyMaterialProvider: Study material uploaded successfully: ${studyMaterial.id}',
      );
      notifyListeners();
      return true;
    } catch (e) {
      print('StudyMaterialProvider: Error uploading study material: $e');
      _setError('Failed to upload study material: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing study material
  Future<bool> updateStudyMaterial({
    required String studyMaterialId,
    required String title,
    required String description,
  }) async {
    if (_isLoading) return false;

    _setLoading(true);
    _setError(null);

    try {
      print('StudyMaterialProvider: Updating study material: $studyMaterialId');

      final updatedMaterial = await _studyMaterialService.updateStudyMaterial(
        studyMaterialId: studyMaterialId,
        title: title,
        description: description,
      );

      // Update the material in the list
      final index = _studyMaterials.indexWhere((m) => m.id == studyMaterialId);
      if (index != -1) {
        _studyMaterials[index] = updatedMaterial;
        print('StudyMaterialProvider: Study material updated successfully');
        notifyListeners();
        return true;
      } else {
        throw Exception('Study material not found in local list');
      }
    } catch (e) {
      print('StudyMaterialProvider: Error updating study material: $e');
      _setError('Failed to update study material: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a study material
  Future<bool> deleteStudyMaterial(String studyMaterialId) async {
    if (_isLoading) return false;

    _setLoading(true);
    _setError(null);

    try {
      print('StudyMaterialProvider: Deleting study material: $studyMaterialId');

      await _studyMaterialService.deleteStudyMaterial(studyMaterialId);

      // Remove from the list
      _studyMaterials.removeWhere((m) => m.id == studyMaterialId);

      print('StudyMaterialProvider: Study material deleted successfully');
      notifyListeners();
      return true;
    } catch (e) {
      print('StudyMaterialProvider: Error deleting study material: $e');
      _setError('Failed to delete study material: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get a study material by ID
  StudyMaterial? getStudyMaterialById(String studyMaterialId) {
    try {
      return _studyMaterials.firstWhere((m) => m.id == studyMaterialId);
    } catch (e) {
      return null;
    }
  }

  /// Get study materials by type
  List<StudyMaterial> getStudyMaterialsByType(String type) {
    return _studyMaterials
        .where((m) => m.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  /// Search study materials by title or description
  List<StudyMaterial> searchStudyMaterials(String query) {
    if (query.isEmpty) return _studyMaterials;

    final lowerQuery = query.toLowerCase();
    return _studyMaterials.where((m) {
      return m.title.toLowerCase().contains(lowerQuery) ||
          m.description.toLowerCase().contains(lowerQuery) ||
          m.fileName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Refresh study materials (reload from server)
  Future<void> refreshStudyMaterials(String courseId) async {
    print('StudyMaterialProvider: Refreshing study materials...');
    await loadStudyMaterials(courseId);
  }

  /// Clear all study materials from state
  void clearStudyMaterials() {
    _studyMaterials.clear();
    _setError(null);
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _setError(null);
  }

  /// Initialize storage bucket
  Future<void> initializeStorage() async {
    try {
      await _studyMaterialService.initializeBucket();
      print('StudyMaterialProvider: Storage initialized successfully');
    } catch (e) {
      print('StudyMaterialProvider: Error initializing storage: $e');
      _setError('Failed to initialize storage: ${e.toString()}');
    }
  }

  /// Test database connection and schema
  Future<bool> testDatabaseConnection() async {
    try {
      await _studyMaterialService.testDatabaseSchema();
      print('StudyMaterialProvider: Database connection test successful');
      return true;
    } catch (e) {
      print('StudyMaterialProvider: Database connection test failed: $e');
      _setError('Database connection failed: ${e.toString()}');
      return false;
    }
  }

  /// Get download URL for a study material
  Future<String> getDownloadUrl(String filePath) async {
    try {
      return await _studyMaterialService.getDownloadUrl(filePath);
    } catch (e) {
      print('StudyMaterialProvider: Error getting download URL: $e');
      return '';
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _studyMaterials.clear();
    super.dispose();
  }
}
