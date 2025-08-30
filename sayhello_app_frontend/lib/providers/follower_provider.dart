import 'package:flutter/foundation.dart';
import '../models/learner.dart';
import '../data/follower_data.dart';

/// Provider for managing follower-related state and operations
class FollowerProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Counts
  int _followersCount = 0;
  int _followingCount = 0;
  int _feedCount = 0;

  // Lists
  List<Learner> _followers = [];
  List<Learner> _following = [];

  // Follow status tracking
  Map<String, bool> _followStatus = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get followersCount => _followersCount;
  int get followingCount => _followingCount;
  int get feedCount => _feedCount;
  List<Learner> get followers => _followers;
  List<Learner> get following => _following;

  /// Get follow status for a specific user
  bool isFollowingUser(String userId) {
    return _followStatus[userId] ?? false;
  }

  /// Load all counts for a learner
  Future<void> loadCounts(String learnerId) async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        FollowerData.getFollowersCount(learnerId),
        FollowerData.getFollowingCount(learnerId),
        FollowerData.getFeedCount(learnerId),
      ]);

      _followersCount = results[0];
      _followingCount = results[1];
      _feedCount = results[2];
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading counts: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load followers list
  Future<void> loadFollowers(String learnerId) async {
    print('FollowerProvider: Loading followers for learner $learnerId');
    _setLoading(true);
    try {
      _followers = await FollowerData.getFollowers(learnerId);
      _followersCount = _followers.length;
      _error = null;
      print('FollowerProvider: Loaded ${_followers.length} followers');
    } catch (e) {
      _error = e.toString();
      print('Error loading followers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load following list
  Future<void> loadFollowing(String learnerId) async {
    print('FollowerProvider: Loading following for learner $learnerId');
    _setLoading(true);
    try {
      _following = await FollowerData.getFollowing(learnerId);
      _followingCount = _following.length;
      _error = null;
      print('FollowerProvider: Loaded ${_following.length} following');
    } catch (e) {
      _error = e.toString();
      print('Error loading following: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Check and cache follow status for a user
  Future<void> checkFollowStatus(String followerId, String followedId) async {
    try {
      print(
        'FollowerProvider: Checking follow status: $followerId -> $followedId',
      );
      final isFollowing = await FollowerData.isFollowing(
        followerId,
        followedId,
      );
      _followStatus[followedId] = isFollowing;
      print(
        'FollowerProvider: Follow status $followerId -> $followedId: $isFollowing',
      );
      notifyListeners();
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  /// Toggle follow status
  Future<bool> toggleFollow(String followerId, String followedId) async {
    final currentStatus = _followStatus[followedId] ?? false;
    print(
      'FollowerProvider: Toggling follow: $followerId -> $followedId (current: $currentStatus)',
    );

    try {
      bool success;
      if (currentStatus) {
        print('FollowerProvider: Unfollowing user');
        success = await FollowerData.unfollowLearner(followerId, followedId);
        if (success) {
          _followStatus[followedId] = false;
          _followingCount = (_followingCount > 0) ? _followingCount - 1 : 0;
          print(
            'FollowerProvider: Successfully unfollowed. New following count: $_followingCount',
          );
        }
      } else {
        print('FollowerProvider: Following user');
        success = await FollowerData.followLearner(followerId, followedId);
        if (success) {
          _followStatus[followedId] = true;
          _followingCount++;
          print(
            'FollowerProvider: Successfully followed. New following count: $_followingCount',
          );
        }
      }

      if (success) {
        notifyListeners();
      }

      return success;
    } catch (e) {
      print('Error toggling follow: $e');
      return false;
    }
  }

  /// Follow a user
  Future<bool> followUser(String followerId, String followedId) async {
    try {
      final success = await FollowerData.followLearner(followerId, followedId);
      if (success) {
        _followStatus[followedId] = true;
        _followingCount++;
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }

  /// Unfollow a user
  Future<bool> unfollowUser(String followerId, String followedId) async {
    try {
      final success = await FollowerData.unfollowLearner(
        followerId,
        followedId,
      );
      if (success) {
        _followStatus[followedId] = false;
        _followingCount = (_followingCount > 0) ? _followingCount - 1 : 0;
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }

  /// Refresh all data for a learner
  Future<void> refreshAll(String learnerId) async {
    await loadCounts(learnerId);
  }

  /// Clear all data
  void clear() {
    _followersCount = 0;
    _followingCount = 0;
    _feedCount = 0;
    _followers.clear();
    _following.clear();
    _followStatus.clear();
    _error = null;
    notifyListeners();
  }

  /// Update feed count (called when user creates/deletes a feed)
  void updateFeedCount(int delta) {
    _feedCount += delta;
    if (_feedCount < 0) _feedCount = 0;
    notifyListeners();
  }

  /// Update followers count (called when someone follows/unfollows this user)
  void updateFollowersCount(int delta) {
    _followersCount += delta;
    if (_followersCount < 0) _followersCount = 0;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
