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
      print(
        '🔍 AuthProvider: Searching for learner with username: "$username"',
      );

      final response = await _client
          .from('learners')
          .select()
          .eq('username', username)
          .single();

      print('✅ AuthProvider: Found learner data: ${response.toString()}');
      return response;
    } catch (e) {
      print('❌ AuthProvider: Error finding learner "$username": $e');
      print('📋 AuthProvider: Error type: ${e.runtimeType}');

      // Check if it's a PostgrestException for more details
      if (e is PostgrestException) {
        print('🔍 AuthProvider: Postgrest error details:');
        print('   - Code: ${e.code}');
        print('   - Message: ${e.message}');
        print('   - Details: ${e.details}');
        print('   - Hint: ${e.hint}');
      }

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
    print(
      '🚀 AuthProvider: Starting sign-in process for username: "$username"',
    );

    _setLoading(true);
    _clearError();

    try {
      // Debug: Check connection to database
      print('📡 AuthProvider: Checking database connection...');

      // First, let's check if we can connect to the learners table at all
      try {
        await _client.from('learners').select('id').limit(1);
        print(
          '✅ AuthProvider: Database connection successful. Can access learners table.',
        );
      } catch (dbError) {
        print('❌ AuthProvider: Database connection failed: $dbError');
        _setError(
          'Database connection failed. Please check your internet connection.',
        );
        return false;
      }

      // Debug: Show all usernames in the table (for debugging only)
      try {
        final allUsers = await _client.from('learners').select('username');
        print('📋 AuthProvider: Available usernames in database:');
        for (var user in allUsers) {
          print('   - "${user['username']}"');
        }
      } catch (e) {
        print('⚠️ AuthProvider: Could not fetch all usernames: $e');
      }

      print(
        '🔍 AuthProvider: Looking up user with exact username: "$username"',
      );

      // First check if user exists and get their data
      final learner = await _getLearnerByUsername(username);

      if (learner == null) {
        print('❌ AuthProvider: User not found in database');
        _setError('User not found. Please check your username.');
        return false;
      }

      print(
        '✅ AuthProvider: User found! ID: ${learner['id']}, Name: ${learner['name']}',
      );
      print('🔐 AuthProvider: Verifying password...');

      // Now verify the password separately
      final storedPassword = learner['password'];
      print(
        '🔍 AuthProvider: Stored password length: ${storedPassword?.length ?? 0}',
      );
      print('🔍 AuthProvider: Provided password length: ${password.length}');

      if (storedPassword != password) {
        print('❌ AuthProvider: Password mismatch');
        print('   - Expected: "$storedPassword"');
        print('   - Provided: "$password"');
        _setError('Incorrect password. Please try again.');
        return false;
      }

      print('✅ AuthProvider: Password verified successfully');

      // If we get here, both username and password are correct
      _currentUser = Learner.fromJson(learner);
      _isAuthenticated = true;

      print(
        '🎉 AuthProvider: Sign-in successful for user: ${_currentUser.name}',
      );
      print('📱 AuthProvider: User ID: ${_currentUser.id}');
      print('🌐 AuthProvider: Native Language: ${_currentUser.nativeLanguage}');
      print(
        '📚 AuthProvider: Learning Language: ${_currentUser.learningLanguage}',
      );

      notifyListeners();
      return true;
    } catch (e) {
      print('💥 AuthProvider: Unexpected error during sign-in: $e');
      print('📋 AuthProvider: Error type: ${e.runtimeType}');
      print('📍 AuthProvider: Stack trace: ${StackTrace.current}');
      _setError('Failed to sign in: $e');
      return false;
    } finally {
      _setLoading(false);
      print('🏁 AuthProvider: Sign-in process completed');
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

  // Change Password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        _setError('No user logged in');
        return false;
      }

      // Verify current password
      String tableName;
      String currentPasswordFromDB;
      String userId;

      if (_currentUser is Learner) {
        tableName = 'learners';
        userId = (_currentUser as Learner).id;

        // Get current user data to verify password
        final userData = await _client
            .from(tableName)
            .select('password')
            .eq('id', userId)
            .single();

        currentPasswordFromDB = userData['password'];
      } else if (_currentUser is Instructor) {
        tableName = 'instructors';
        userId = (_currentUser as Instructor).id;

        // Get current user data to verify password
        final userData = await _client
            .from(tableName)
            .select('password')
            .eq('id', userId)
            .single();

        currentPasswordFromDB = userData['password'];
      } else {
        _setError('Invalid user type');
        return false;
      }

      // Verify current password
      if (currentPasswordFromDB != currentPassword) {
        _setError('Current password is incorrect');
        return false;
      }

      // Update password in database
      await _client
          .from(tableName)
          .update({'password': newPassword})
          .eq('id', userId);

      return true;
    } catch (e) {
      _setError('Failed to change password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
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
