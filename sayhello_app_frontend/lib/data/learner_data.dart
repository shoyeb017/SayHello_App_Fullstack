/// Learner Repository - Handles all learner-related database operations
/// Provides CRUD operations and real-time subscriptions for learners and followers

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class LearnerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =============================
  // LEARNER CRUD OPERATIONS
  // =============================

  /// Create a new learner profile
  Future<Learner> createLearner(Map<String, dynamic> learnerData) async {
    try {
      final response = await _supabase
          .from('learners')
          .insert(learnerData)
          .select()
          .single();

      return Learner.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create learner: $e');
    }
  }

  /// Get learner by ID
  Future<Learner?> getLearnerById(String id) async {
    try {
      print('LearnerRepository: Getting learner by ID: $id');
      final response = await _supabase
          .from('learners')
          .select()
          .eq('id', id)
          .maybeSingle();

      print(
        'LearnerRepository: Query response: ${response != null ? 'Found' : 'Not found'}',
      );
      return response != null ? Learner.fromJson(response) : null;
    } catch (e) {
      print('LearnerRepository: Error getting learner by ID: $e');
      throw Exception('Failed to get learner: $e');
    }
  }

  /// Get learner by email
  Future<Learner?> getLearnerByEmail(String email) async {
    try {
      final response = await _supabase
          .from('learners')
          .select()
          .eq('email', email)
          .maybeSingle();

      return response != null ? Learner.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to get learner by email: $e');
    }
  }

  /// Get learner by username
  Future<Learner?> getLearnerByUsername(String username) async {
    try {
      final response = await _supabase
          .from('learners')
          .select()
          .eq('username', username)
          .maybeSingle();

      return response != null ? Learner.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to get learner by username: $e');
    }
  }

  /// Update learner profile
  Future<Learner> updateLearner(String id, Map<String, dynamic> updates) async {
    try {
      print('LearnerData: Updating learner $id with data: $updates');

      final response = await _supabase
          .from('learners')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      print('LearnerData: Update response: $response');

      final updatedLearner = Learner.fromJson(response);
      print('LearnerData: Parsed learner: ${updatedLearner.toJson()}');

      return updatedLearner;
    } catch (e) {
      print('LearnerData: Update failed with error: $e');
      throw Exception('Failed to update learner: $e');
    }
  }

  /// Delete learner profile
  Future<void> deleteLearner(String id) async {
    try {
      await _supabase.from('learners').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete learner: $e');
    }
  }

  /// Search learners by name or username
  Future<List<Learner>> searchLearners(String query, {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('learners')
          .select()
          .or('name.ilike.%$query%,username.ilike.%$query%')
          .limit(limit);

      return response.map((json) => Learner.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search learners: $e');
    }
  }

  /// Get learners by native language (for language partner matching)
  /// This finds learners whose native language matches the given language
  /// Used to find language partners: if user is learning Japanese, find native Japanese speakers
  Future<List<Learner>> getLearnersByLanguage(
    String language, {
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('learners')
          .select()
          .eq('native_language', language)
          .limit(limit);

      return response.map((json) => Learner.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get learners by language: $e');
    }
  }

  // =============================
  // FOLLOWER OPERATIONS
  // =============================

  /// Follow another learner
  Future<Follower> followLearner(String followerId, String followedId) async {
    try {
      print('LearnerRepository: Attempting to follow - follower: $followerId, followed: $followedId');
      
      // Create insert data without created_at (not in database schema)
      final insertData = {
        'follower_user_id': followerId,
        'followed_user_id': followedId,
      };

      print('LearnerRepository: Inserting follower data: $insertData');

      final response = await _supabase
          .from('followers')
          .insert(insertData)
          .select()
          .single();

      print('LearnerRepository: Follow successful, response: $response');
      return Follower.fromJson(response);
    } catch (e) {
      print('LearnerRepository: Follow failed with error: $e');
      throw Exception('Failed to follow learner: $e');
    }
  }

  /// Unfollow a learner
  Future<void> unfollowLearner(String followerId, String followedId) async {
    try {
      print('LearnerRepository: Attempting to unfollow - follower: $followerId, followed: $followedId');
      
      await _supabase
          .from('followers')
          .delete()
          .eq('follower_user_id', followerId)
          .eq('followed_user_id', followedId);
          
      print('LearnerRepository: Unfollow operation completed');
    } catch (e) {
      print('LearnerRepository: Unfollow failed with error: $e');
      throw Exception('Failed to unfollow learner: $e');
    }
  }

  /// Get followers of a learner
  Future<List<Follower>> getFollowers(
    String learnerId, {
    int limit = 100,
  }) async {
    try {
      final response = await _supabase
          .from('followers')
          .select()
          .eq('followed_user_id', learnerId)
          .limit(limit);

      return response.map((json) => Follower.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  /// Get learners that a user is following
  Future<List<Follower>> getFollowing(
    String learnerId, {
    int limit = 100,
  }) async {
    try {
      final response = await _supabase
          .from('followers')
          .select()
          .eq('follower_user_id', learnerId)
          .limit(limit);

      return response.map((json) => Follower.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }

  /// Check if user is following another user
  Future<bool> isFollowing(String followerId, String followedId) async {
    try {
      print('LearnerRepository: Checking follow status - follower: $followerId, followed: $followedId');
      
      final response = await _supabase
          .from('followers')
          .select('id')
          .eq('follower_user_id', followerId)
          .eq('followed_user_id', followedId)
          .maybeSingle();

      final isFollowing = response != null;
      print('LearnerRepository: Follow status result: $isFollowing');
      return isFollowing;
    } catch (e) {
      print('LearnerRepository: Check follow status failed with error: $e');
      throw Exception('Failed to check following status: $e');
    }
  }

  /// Get follower count for a learner
  Future<int> getFollowerCount(String learnerId) async {
    try {
      final response = await _supabase
          .from('followers')
          .select()
          .eq('followed_user_id', learnerId);

      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get follower count: $e');
    }
  }

  /// Get following count for a learner
  Future<int> getFollowingCount(String learnerId) async {
    try {
      final response = await _supabase
          .from('followers')
          .select()
          .eq('follower_user_id', learnerId);

      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to get following count: $e');
    }
  }

  // =============================
  // REAL-TIME SUBSCRIPTIONS
  // =============================

  /// Real-time subscription to learners table
  Stream<List<Learner>> subscribeLearners() {
    return _supabase
        .from('learners')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((e) => Learner.fromJson(e)).toList());
  }
}
