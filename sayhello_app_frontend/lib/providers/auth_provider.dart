import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_config.dart';
import '../models/learner.dart';
import '../models/instructor.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client = SupabaseConfig.client;
  String? _error;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  dynamic _currentUser; // Can be Learner or Instructor

  // Getters
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  dynamic get currentUser => _currentUser;

  // Get learner by username
  Future<Map<String, dynamic>?> _getLearnerByUsername(String username) async {
    try {
      final response = await _client
          .from('learners')
          .select()
          .eq('username', username)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Get instructor by username
  Future<Map<String, dynamic>?> _getInstructorByUsername(
    String username,
  ) async {
    try {
      final response = await _client
          .from('instructors')
          .select()
          .eq('username', username)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Learner Sign In
  Future<bool> signInLearner(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // First check if user exists and get their data
      final learner = await _getLearnerByUsername(username);

      if (learner == null) {
        _setError('User not found. Please check your username.');
        return false;
      }

      // Now verify the password separately
      if (learner['password'] != password) {
        // In production, use proper password hashing
        _setError('Incorrect password. Please try again.');
        return false;
      }

      // If we get here, both username and password are correct
      _currentUser = Learner.fromJson(learner);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to sign in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Instructor Sign In
  Future<bool> signInInstructor(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // First check if instructor exists and get their data
      final instructor = await _getInstructorByUsername(username);

      if (instructor == null) {
        _setError('Instructor not found. Please check your username.');
        return false;
      }

      // Now verify the password separately
      if (instructor['password'] != password) {
        // In production, use proper password hashing
        _setError('Incorrect password. Please try again.');
        return false;
      }

      // If we get here, both username and password are correct
      _currentUser = Instructor.fromJson(instructor);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to sign in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Error handling
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
