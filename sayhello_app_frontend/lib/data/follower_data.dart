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

      // Extract follower IDs, filtering out null values
      final followerIds = followersResponse
          .map((item) => item['follower_user_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();

      print('Follower IDs: $followerIds');

      // Check if we have any valid IDs
      if (followerIds.isEmpty) {
        print('No valid follower IDs found');
        return [];
      }

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

      // Extract following IDs, filtering out null values
      final followingIds = followingResponse
          .map((item) => item['followed_user_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();

      print('Following IDs: $followingIds');

      // Check if we have any valid IDs
      if (followingIds.isEmpty) {
        print('No valid following IDs found');
        return [];
      }

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
      print('FollowerData: Checking follow status: $followerId -> $followedId');

      final response = await SupabaseConfig.client
          .from('followers')
          .select('id')
          .eq('follower_user_id', followerId)
          .eq('followed_user_id', followedId)
          .limit(1);

      print('FollowerData: Query returned ${response.length} rows');

      // If we get any rows, it means the user is following
      final isFollowing = response.isNotEmpty;

      // Log warning if multiple rows found (indicates duplicate data)
      if (response.length > 1) {
        print(
          '⚠️ WARNING: Found ${response.length} duplicate follow relationships for $followerId -> $followedId',
        );
        print(
          '   This indicates duplicate data in the followers table that should be cleaned up',
        );
      }

      print('FollowerData: Follow status result: $isFollowing');
      return isFollowing;
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
      print('FollowerData: Attempting to follow: $followerId -> $followedId');

      // First check if already following to prevent duplicates
      final alreadyFollowing = await isFollowing(followerId, followedId);
      if (alreadyFollowing) {
        print('FollowerData: Already following, skipping insert');
        return true; // Already following, consider it successful
      }

      await SupabaseConfig.client.from('followers').insert({
        'follower_user_id': followerId,
        'followed_user_id': followedId,
      });

      print('FollowerData: Successfully followed');
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
      print('FollowerData: Attempting to unfollow: $followerId -> $followedId');

      await SupabaseConfig.client
          .from('followers')
          .delete()
          .eq('follower_user_id', followerId)
          .eq('followed_user_id', followedId);

      print('FollowerData: Unfollow operation completed');
      return true;
    } catch (e) {
      print('Error unfollowing learner: $e');
      return false;
    }
  }

  /// Clean up duplicate follow relationships (maintenance method)
  static Future<int> cleanupDuplicateFollows() async {
    try {
      print('FollowerData: Starting cleanup of duplicate follow relationships');

      // Get all follow relationships
      final allFollows = await SupabaseConfig.client
          .from('followers')
          .select('id, follower_user_id, followed_user_id, created_at')
          .order('created_at', ascending: true);

      // Group by follower-followed pair
      Map<String, List<dynamic>> groups = {};
      for (var follow in allFollows) {
        final key =
            '${follow['follower_user_id']}-${follow['followed_user_id']}';
        groups[key] = groups[key] ?? [];
        groups[key]!.add(follow);
      }

      // Find duplicates and remove all but the first one
      int deletedCount = 0;
      for (var entry in groups.entries) {
        if (entry.value.length > 1) {
          print('Found ${entry.value.length} duplicates for ${entry.key}');

          // Keep the first one, delete the rest
          for (int i = 1; i < entry.value.length; i++) {
            await SupabaseConfig.client
                .from('followers')
                .delete()
                .eq('id', entry.value[i]['id']);
            deletedCount++;
          }
        }
      }

      print(
        'FollowerData: Cleanup completed. Deleted $deletedCount duplicate entries',
      );
      return deletedCount;
    } catch (e) {
      print('Error cleaning up duplicate follows: $e');
      return 0;
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
