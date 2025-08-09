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
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      // // Optional: Add additional configuration
      // authCallbackUrlHostname: 'localhost',
      // authFlowType: AuthFlowType.pkce,
    );
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
