import '../services/supabase_config.dart';
import '../models/learner.dart';

/// Data service for follower operations
class FollowerData {
  /// Get followers count for a learner
  static Future<int> getFollowersCount(String learnerId) async {
    try {
      final response = await SupabaseConfig.client
          .from('followers')
          .select('id')
          .eq('followed_user_id', learnerId);

      return response.length;
    } catch (e) {
      print('Error getting followers count: $e');
      return 0;
    }
  }

  /// Get following count for a learner
  static Future<int> getFollowingCount(String learnerId) async {
    try {
      final response = await SupabaseConfig.client
          .from('followers')
          .select('id')
          .eq('follower_user_id', learnerId);

      return response.length;
    } catch (e) {
      print('Error getting following count: $e');
      return 0;
    }
  }

  /// Get feed count for a learner
  static Future<int> getFeedCount(String learnerId) async {
    try {
      final response = await SupabaseConfig.client
          .from('feed')
          .select('id')
          .eq('learner_id', learnerId);

      return response.length;
    } catch (e) {
      print('Error getting feed count: $e');
      return 0;
    }
  }

  /// Get followers list with learner details
  static Future<List<Learner>> getFollowers(String learnerId) async {
    try {
      print('Getting followers for learner: $learnerId');

      // First get follower relationships
      final followersResponse = await SupabaseConfig.client
          .from('followers')
          .select('follower_user_id')
          .eq('followed_user_id', learnerId);

      print('Followers response: $followersResponse');

      if (followersResponse.isEmpty) {
        print('No followers found');
        return [];
      }

      // Extract follower IDs
      final followerIds = followersResponse
          .map((item) => item['follower_user_id'] as String)
          .toList();

      print('Follower IDs: $followerIds');

      // Get learner details for these IDs
      final learnersResponse = await SupabaseConfig.client
          .from('learners')
          .select('*')
          .inFilter('id', followerIds);

      print('Learners response: $learnersResponse');

      return learnersResponse.map<Learner>((item) {
        return Learner.fromJson(item);
      }).toList();
    } catch (e) {
      print('Error getting followers: $e');
      return [];
    }
  }

  /// Get following list with learner details
  static Future<List<Learner>> getFollowing(String learnerId) async {
    try {
      print('Getting following for learner: $learnerId');

      // First get following relationships
      final followingResponse = await SupabaseConfig.client
          .from('followers')
          .select('followed_user_id')
          .eq('follower_user_id', learnerId);

      print('Following response: $followingResponse');

      if (followingResponse.isEmpty) {
        print('No following found');
        return [];
      }

      // Extract following IDs
      final followingIds = followingResponse
          .map((item) => item['followed_user_id'] as String)
          .toList();

      print('Following IDs: $followingIds');

      // Get learner details for these IDs
      final learnersResponse = await SupabaseConfig.client
          .from('learners')
          .select('*')
          .inFilter('id', followingIds);

      print('Learners response: $learnersResponse');

      return learnersResponse.map<Learner>((item) {
        return Learner.fromJson(item);
      }).toList();
    } catch (e) {
      print('Error getting following: $e');
      return [];
    }
  }

  /// Check if learner is following another learner
  static Future<bool> isFollowing(String followerId, String followedId) async {
    try {
      final response = await SupabaseConfig.client
          .from('followers')
          .select('id')
          .eq('follower_user_id', followerId)
          .eq('followed_user_id', followedId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  /// Follow a learner
  static Future<bool> followLearner(
    String followerId,
    String followedId,
  ) async {
    try {
      await SupabaseConfig.client.from('followers').insert({
        'follower_user_id': followerId,
        'followed_user_id': followedId,
      });

      return true;
    } catch (e) {
      print('Error following learner: $e');
      return false;
    }
  }

  /// Unfollow a learner
  static Future<bool> unfollowLearner(
    String followerId,
    String followedId,
  ) async {
    try {
      await SupabaseConfig.client
          .from('followers')
          .delete()
          .eq('follower_user_id', followerId)
          .eq('followed_user_id', followedId);

      return true;
    } catch (e) {
      print('Error unfollowing learner: $e');
      return false;
    }
  }

  /// Get mutual followers (people who follow both users)
  static Future<List<Learner>> getMutualFollowers(
    String learner1Id,
    String learner2Id,
  ) async {
    try {
      // Get followers of learner1
      final followers1 = await SupabaseConfig.client
          .from('followers')
          .select('follower_user_id')
          .eq('followed_user_id', learner1Id);

      // Get followers of learner2
      final followers2 = await SupabaseConfig.client
          .from('followers')
          .select('follower_user_id')
          .eq('followed_user_id', learner2Id);

      // Find mutual follower IDs
      final follower1Ids = followers1
          .map((f) => f['follower_user_id'] as String)
          .toSet();
      final follower2Ids = followers2
          .map((f) => f['follower_user_id'] as String)
          .toSet();
      final mutualIds = follower1Ids.intersection(follower2Ids).toList();

      if (mutualIds.isEmpty) return [];

      // Get learner details for mutual followers
      final response = await SupabaseConfig.client
          .from('learners')
          .select('*')
          .inFilter('id', mutualIds);

      return response.map<Learner>((item) => Learner.fromJson(item)).toList();
    } catch (e) {
      print('Error getting mutual followers: $e');
      return [];
    }
  }
}
