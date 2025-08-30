/// Supabase Configuration and Initialization
/// Handles Supabase client setup and configuration

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Replace with your actual Supabase URL and Anon Key
  // Get these from your Supabase project dashboard
  static const String supabaseUrl = 'https://grunwttngjfnwfzlgopi.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdydW53dHRuZ2pmbndmemxnb3BpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2NjY4ODAsImV4cCI6MjA3MDI0Mjg4MH0.sP7JZn1YZdTt5gez4vNiu1ZPHAyXpK2bYRdKVHwXHcQ';

  /// Initialize Supabase
  static Future<void> initialize() async {
    print('🚀 SupabaseConfig: Initializing Supabase...');
    print('🔗 SupabaseConfig: URL: $supabaseUrl');
    print(
      '🔑 SupabaseConfig: Using anon key: ${supabaseAnonKey.substring(0, 20)}...',
    );

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        // // Optional: Add additional configuration
        // authCallbackUrlHostname: 'localhost',
        // authFlowType: AuthFlowType.pkce,
      );

      print('✅ SupabaseConfig: Supabase initialized successfully');

      // Test the connection
      await _testConnection();
    } catch (e) {
      print('❌ SupabaseConfig: Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  /// Test the database connection
  static Future<void> _testConnection() async {
    try {
      print('🧪 SupabaseConfig: Testing database connection...');

      // Try to access the learners table
      final response = await client
          .from('learners')
          .select('count(*)')
          .limit(1);

      print('✅ SupabaseConfig: Database connection test successful');
      print('📊 SupabaseConfig: Response type: ${response.runtimeType}');
    } catch (e) {
      print('❌ SupabaseConfig: Database connection test failed: $e');
      print('🔍 SupabaseConfig: Error type: ${e.runtimeType}');

      if (e is PostgrestException) {
        print('🔍 SupabaseConfig: Postgrest error details:');
        print('   - Code: ${e.code}');
        print('   - Message: ${e.message}');
        print('   - Details: ${e.details}');
        print('   - Hint: ${e.hint}');
      }
    }
  }

  /// Public method to test connection (for debugging)
  static Future<void> testConnection() async {
    await _testConnection();
  }

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}

/// Extension to add helper methods to SupabaseClient
extension SupabaseClientExtensions on SupabaseClient {
  /// Helper method to check if user is authenticated
  bool get isAuthenticated => auth.currentUser != null;

  /// Helper method to get current user ID
  String? get currentUserId => auth.currentUser?.id;

  /// Helper method to sign out
  Future<void> signOut() async {
    await auth.signOut();
  }
}
