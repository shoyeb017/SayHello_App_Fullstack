/// Feed Provider - State management for social feed functionality
/// Handles feed posts, comments, likes, and following/followers operations

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/data.dart';

class FeedProvider extends ChangeNotifier {
  final FeedRepository _repository = FeedRepository();

  // Feed state
  List<FeedWithUser> _recentFeeds = [];
  List<FeedWithUser> _forYouFeeds = [];
  Map<String, List<FeedCommentWithUser>> _feedComments = {};
  Map<String, List<FeedLike>> _feedLikes = {};
  Map<String, bool> _likedPosts = {};

  // Loading states
  bool _isLoading = false;
  bool _isCommentsLoading = false;
  bool _isSending = false;
  bool _isFollowOperationInProgress = false;

  // Error state
  String? _error;

  // Getters
  List<FeedWithUser> get recentFeeds => _recentFeeds;
  List<FeedWithUser> get forYouFeeds => _forYouFeeds;
  List<FeedWithUser> get allFeeds => [..._recentFeeds, ..._forYouFeeds];
  Map<String, List<FeedCommentWithUser>> get feedComments => _feedComments;
  Map<String, List<FeedLike>> get feedLikes => _feedLikes;
  Map<String, bool> get likedPosts => _likedPosts;
  bool get isLoading => _isLoading;
  bool get isCommentsLoading => _isCommentsLoading;
  bool get isSending => _isSending;
  bool get isFollowOperationInProgress => _isFollowOperationInProgress;
  bool get hasError => _error != null;
  String? get error => _error;

  // =============================
  // FEED OPERATIONS
  // =============================
  // FEED LOADING OPERATIONS
  // =============================

  /// Load both tabs simultaneously for faster initial loading
  Future<void> loadAllFeeds(String currentUserId) async {
    _setLoading(true);
    _clearError();

    try {
      print('FeedProvider: Loading all feeds simultaneously');

      // Load both tabs at the same time
      final recentFeedsTask = _repository.getNotFollowingFeeds(
        currentUserId,
        limit: 15,
      );

      final forYouFeedsTask = _repository.getFollowingFeeds(
        currentUserId,
        limit: 15,
      );

      // Wait for both to complete
      final results = await Future.wait([recentFeedsTask, forYouFeedsTask]);
      final recentFeeds = results[0];
      final forYouFeeds = results[1];

      // Update feeds
      _recentFeeds = recentFeeds;
      _forYouFeeds = forYouFeeds;

      // Load interactions for both feed lists
      final allFeeds = [...recentFeeds, ...forYouFeeds];
      if (allFeeds.isNotEmpty) {
        await _loadFeedInteractions(allFeeds, currentUserId);
      }

      print(
        'FeedProvider: Loaded ${recentFeeds.length} recent feeds and ${forYouFeeds.length} for you feeds',
      );
      notifyListeners();
    } catch (e) {
      print('FeedProvider: Error loading feeds: $e');
      _setError('Failed to load feeds: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load recent feeds (feeds from users NOT being followed)
  Future<void> loadRecentFeeds(String currentUserId) async {
    _setLoading(true);
    _clearError();

    try {
      print('FeedProvider: Loading recent feeds (NOT following users)');

      // Get feeds from users NOT being followed
      final feeds = await _repository.getNotFollowingFeeds(
        currentUserId,
        limit: 15, // Reduced limit to prevent crashes
      );

      _recentFeeds = feeds;

      // Load likes and comments count for each feed
      await _loadFeedInteractions(feeds, currentUserId);

      print('FeedProvider: Loaded ${feeds.length} recent feeds');
      notifyListeners();
    } catch (e) {
      print('FeedProvider: Error loading recent feeds: $e');
      _setError('Failed to load recent feeds: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load for you feeds (feeds from followed users only)
  Future<void> loadForYouFeeds(String currentUserId) async {
    _setLoading(true);
    _clearError();

    try {
      print('FeedProvider: Loading for you feeds (followed users only)');

      // Get feeds only from followed users
      final feeds = await _repository.getFollowingFeeds(
        currentUserId,
        limit: 15, // Reduced limit to prevent crashes
      );

      _forYouFeeds = feeds;

      // Load likes and comments count for each feed
      await _loadFeedInteractions(feeds, currentUserId);

      print('FeedProvider: Loaded ${feeds.length} for you feeds');
      notifyListeners();
    } catch (e) {
      print('FeedProvider: Error loading for you feeds: $e');
      _setError('Failed to load for you feeds: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load feed interactions (likes, comments) with optimized performance
  Future<void> _loadFeedInteractions(
    List<FeedWithUser> feeds,
    String currentUserId,
  ) async {
    try {
      // Limit the number of feeds processed to prevent memory issues
      final limitedFeeds = feeds
          .take(15)
          .toList(); // Increased limit since we're optimizing

      print(
        'FeedProvider: Loading interactions for ${limitedFeeds.length} feeds',
      );

      // Set default values immediately to show content faster
      for (final feedWithUser in limitedFeeds) {
        final feedId = feedWithUser.feed.id;
        _feedComments[feedId] ??= [];
        // Don't set empty likes list - let it load from database
        _likedPosts[feedId] ??= false;
      }

      // Notify listeners immediately to show feeds without interactions
      notifyListeners();

      // Load interactions in background batches - smaller batches, faster processing
      const concurrencyLimit =
          2; // Reduced to prevent overwhelming the database
      for (int i = 0; i < limitedFeeds.length; i += concurrencyLimit) {
        final batch = limitedFeeds.skip(i).take(concurrencyLimit).toList();

        // Process batch with shorter timeouts
        final futures = batch.map((feedWithUser) async {
          final feedId = feedWithUser.feed.id;

          try {
            // Only load essential data with shorter timeouts
            final commentsTask = _repository
                .getFeedComments(
                  feedId,
                  limit: 3,
                ) // Reduced limit for faster loading
                .timeout(const Duration(seconds: 3)) // Shorter timeout
                .then((comments) {
                  _feedComments[feedId] = comments;
                });

            final likedTask = _repository
                .isFeedLikedByUser(feedId, currentUserId)
                .timeout(const Duration(seconds: 3)) // Shorter timeout
                .then((isLiked) {
                  _likedPosts[feedId] = isLiked;
                });

            // Load likes when available - for displaying liked users
            final likesTask = _repository
                .getFeedLikes(feedId)
                .timeout(const Duration(seconds: 3))
                .then((likes) {
                  _feedLikes[feedId] = likes;
                });

            // Skip likes count for faster loading - use feed.likesCount from database
            await Future.wait([commentsTask, likedTask, likesTask]);
          } catch (e) {
            print(
              'FeedProvider: Error loading interactions for feed $feedId: $e',
            );
            // Keep safe defaults that were already set
          }
        });

        // Wait for this batch to complete
        await Future.wait(futures);

        // Notify listeners after each batch for progressive loading
        notifyListeners();

        // Smaller delay between batches
        if (i + concurrencyLimit < limitedFeeds.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      print('FeedProvider: Completed loading interactions');
    } catch (e) {
      print('FeedProvider: Error in _loadFeedInteractions: $e');
      // Don't throw, just log the error and continue
    }
  }

  // Cache for user's own posts to avoid repeated database calls
  Map<String, List<FeedWithUser>> _userPostsCache = {};
  Map<String, DateTime> _userPostsCacheTimestamp = {};

  /// Load user's own posts (optimized with caching)
  Future<List<FeedWithUser>> getUserOwnPosts(String userId) async {
    try {
      // Check cache first (cache for 5 minutes)
      final cacheKey = userId;
      final cacheTimestamp = _userPostsCacheTimestamp[cacheKey];
      final now = DateTime.now();

      if (cacheTimestamp != null &&
          now.difference(cacheTimestamp).inMinutes < 5 &&
          _userPostsCache.containsKey(cacheKey)) {
        print('FeedProvider: Returning cached user posts for $userId');
        return _userPostsCache[cacheKey]!;
      }

      print('FeedProvider: Loading user posts from database for $userId');

      // Get user's own posts from the repository
      final ownPosts = await _repository.getFeedPostsByUser(userId);

      // Convert to FeedWithUser format with minimal database calls
      final feedsWithUser = <FeedWithUser>[];
      for (final feed in ownPosts) {
        // Set safe defaults for interactions to show posts immediately
        _feedComments[feed.id] = [];
        _feedLikes[feed.id] = [];
        _likedPosts[feed.id] = false;

        feedsWithUser.add(
          FeedWithUser(
            feed: feed,
            userName: 'You',
            userAvatarUrl: null, // Will be handled by the UI
          ),
        );
      }

      // Cache the results
      _userPostsCache[cacheKey] = feedsWithUser;
      _userPostsCacheTimestamp[cacheKey] = now;

      // Load interactions in background (non-blocking)
      _loadUserPostInteractions(ownPosts, userId);

      return feedsWithUser;
    } catch (e) {
      print('FeedProvider: Error loading user posts: $e');
      return [];
    }
  }

  /// Load interactions for user's own posts in background
  Future<void> _loadUserPostInteractions(
    List<Feed> posts,
    String userId,
  ) async {
    try {
      // Process a few posts at a time to avoid overwhelming the database
      const batchSize = 3;
      for (int i = 0; i < posts.length; i += batchSize) {
        final batch = posts.skip(i).take(batchSize);

        final futures = batch.map((feed) async {
          try {
            final comments = await _repository.getFeedComments(
              feed.id,
              limit: 3,
            );
            final isLiked = await _repository.isFeedLikedByUser(
              feed.id,
              userId,
            );

            _feedComments[feed.id] = comments;
            _likedPosts[feed.id] = isLiked;
          } catch (e) {
            print('Error loading interactions for post ${feed.id}: $e');
          }
        });

        await Future.wait(futures);
        notifyListeners(); // Update UI progressively

        // Small delay between batches
        if (i + batchSize < posts.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      print('Error loading user post interactions: $e');
    }
  }

  /// Create a new feed post
  Future<bool> createFeedPost({
    required String learnerId,
    required String contentText,
    List<String> imageUrls = const [],
  }) async {
    _setSending(true);
    _clearError();

    try {
      print('FeedProvider: Creating feed post');

      final feed = Feed(
        id: '', // Will be generated by database
        learnerId: learnerId,
        contentText: contentText,
        createdAt: DateTime.now(),
        imageUrls: imageUrls,
        likesCount: 0,
        commentsCount: 0,
        isLiked: false,
      );

      await _repository.createFeedPost(feed);

      // Invalidate user posts cache since we added a new post
      _userPostsCache.remove(learnerId);
      _userPostsCacheTimestamp.remove(learnerId);

      // Refresh feeds to show the new post immediately
      await loadAllFeeds(learnerId);

      print('FeedProvider: Feed post created successfully');
      return true;
    } catch (e) {
      print('FeedProvider: Error creating feed post: $e');
      _setError('Failed to create feed post: $e');
      return false;
    } finally {
      _setSending(false);
    }
  }

  /// Delete a feed post
  Future<bool> deleteFeedPost(String feedId, String currentUserId) async {
    _clearError();

    try {
      await _repository.deleteFeedPost(feedId);

      // Invalidate user posts cache since we deleted a post
      _userPostsCache.remove(currentUserId);
      _userPostsCacheTimestamp.remove(currentUserId);

      // Remove from local lists
      _recentFeeds.removeWhere((f) => f.feed.id == feedId);
      _forYouFeeds.removeWhere((f) => f.feed.id == feedId);
      _feedComments.remove(feedId);
      _feedLikes.remove(feedId);
      _likedPosts.remove(feedId);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete feed post: $e');
      return false;
    }
  }

  // =============================
  // LIKE OPERATIONS
  // =============================

  /// Toggle like on a feed post
  Future<void> toggleFeedLike(String feedId, String userId) async {
    try {
      final isCurrentlyLiked = _likedPosts[feedId] ?? false;

      // Optimistic update - update UI immediately
      if (isCurrentlyLiked) {
        // Optimistically unlike the post
        _likedPosts[feedId] = false;
        _feedLikes[feedId]?.removeWhere((like) => like.learnerId == userId);
        _updateFeedLikeCount(feedId, -1);
      } else {
        // Optimistically like the post
        _likedPosts[feedId] = true;
        _feedLikes[feedId] ??= [];
        // Add optimistic like to the list
        _feedLikes[feedId]!.add(
          FeedLike(
            id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // temporary ID
            feedId: feedId,
            learnerId: userId,
            createdAt: DateTime.now(),
          ),
        );
        _updateFeedLikeCount(feedId, 1);
      }

      // Notify listeners immediately for instant UI update
      notifyListeners();

      // Now perform the actual API call
      if (isCurrentlyLiked) {
        await _repository.unlikeFeed(feedId, userId);
      } else {
        await _repository.likeFeed(feedId, userId);
      }

      // If we reach here, the API call was successful
      // The optimistic update was correct, no need to change anything
      print('FeedProvider: Like toggle successful for feed $feedId');
    } catch (e) {
      print('FeedProvider: Error toggling like: $e');

      // Revert optimistic update on error
      final isCurrentlyLiked = _likedPosts[feedId] ?? false;
      if (isCurrentlyLiked) {
        // Revert the like (was unlike attempt that failed)
        _likedPosts[feedId] = false;
        _feedLikes[feedId]?.removeWhere((like) => like.learnerId == userId);
        _updateFeedLikeCount(feedId, -1);
      } else {
        // Revert the unlike (was like attempt that failed)
        _likedPosts[feedId] = true;
        _feedLikes[feedId] ??= [];
        _feedLikes[feedId]!.add(
          FeedLike(
            id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
            feedId: feedId,
            learnerId: userId,
            createdAt: DateTime.now(),
          ),
        );
        _updateFeedLikeCount(feedId, 1);
      }

      notifyListeners();
      _setError('Failed to toggle like: $e');
    }
  }

  /// Update like count for a feed in local state
  void _updateFeedLikeCount(String feedId, int change) {
    // Update in recent feeds
    final recentIndex = _recentFeeds.indexWhere((f) => f.feed.id == feedId);
    if (recentIndex != -1) {
      final feedWithUser = _recentFeeds[recentIndex];
      final updatedFeed = feedWithUser.feed.copyWith(
        likesCount: feedWithUser.feed.likesCount + change,
        isLiked: _likedPosts[feedId] ?? false,
      );
      _recentFeeds[recentIndex] = FeedWithUser(
        feed: updatedFeed,
        userName: feedWithUser.userName,
        userAvatarUrl: feedWithUser.userAvatarUrl,
      );
    }

    // Update in for you feeds
    final forYouIndex = _forYouFeeds.indexWhere((f) => f.feed.id == feedId);
    if (forYouIndex != -1) {
      final feedWithUser = _forYouFeeds[forYouIndex];
      final updatedFeed = feedWithUser.feed.copyWith(
        likesCount: feedWithUser.feed.likesCount + change,
        isLiked: _likedPosts[feedId] ?? false,
      );
      _forYouFeeds[forYouIndex] = FeedWithUser(
        feed: updatedFeed,
        userName: feedWithUser.userName,
        userAvatarUrl: feedWithUser.userAvatarUrl,
      );
    }
  }

  // =============================
  // COMMENT OPERATIONS
  // =============================

  /// Add comment to feed post
  Future<bool> addFeedComment({
    required String feedId,
    required String learnerId,
    required String contentText,
    String? parentCommentId,
  }) async {
    _clearError();

    try {
      print('FeedProvider: Adding comment to feed: $feedId');

      final comment = FeedComment(
        id: '', // Will be generated by database
        feedId: feedId,
        learnerId: learnerId,
        contentText: contentText,
        parentCommentId: parentCommentId,
        createdAt: DateTime.now(),
        likesCount: 0,
        isLiked: false,
      );

      final createdCommentWithUser = await _repository.addFeedComment(comment);

      // Add to local comments list
      _feedComments[feedId] ??= [];
      _feedComments[feedId]!.add(createdCommentWithUser);

      // Update comment count in feeds
      _updateFeedCommentCount(feedId, 1);

      notifyListeners();
      return true;
    } catch (e) {
      print('FeedProvider: Error adding comment: $e');
      _setError('Failed to add comment: $e');
      return false;
    }
  }

  /// Load comments for a specific feed
  Future<void> loadFeedComments(String feedId) async {
    _isCommentsLoading = true;
    notifyListeners();

    try {
      final comments = await _repository.getFeedComments(feedId);
      _feedComments[feedId] = comments;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load comments: $e');
    } finally {
      _isCommentsLoading = false;
      notifyListeners();
    }
  }

  /// Update comment count for a feed in local state
  void _updateFeedCommentCount(String feedId, int change) {
    // Update in recent feeds
    final recentIndex = _recentFeeds.indexWhere((f) => f.feed.id == feedId);
    if (recentIndex != -1) {
      final feedWithUser = _recentFeeds[recentIndex];
      final updatedFeed = feedWithUser.feed.copyWith(
        commentsCount: feedWithUser.feed.commentsCount + change,
      );
      _recentFeeds[recentIndex] = FeedWithUser(
        feed: updatedFeed,
        userName: feedWithUser.userName,
        userAvatarUrl: feedWithUser.userAvatarUrl,
      );
    }

    // Update in for you feeds
    final forYouIndex = _forYouFeeds.indexWhere((f) => f.feed.id == feedId);
    if (forYouIndex != -1) {
      final feedWithUser = _forYouFeeds[forYouIndex];
      final updatedFeed = feedWithUser.feed.copyWith(
        commentsCount: feedWithUser.feed.commentsCount + change,
      );
      _forYouFeeds[forYouIndex] = FeedWithUser(
        feed: updatedFeed,
        userName: feedWithUser.userName,
        userAvatarUrl: feedWithUser.userAvatarUrl,
      );
    }
  }

  // =============================
  // FOLLOW OPERATIONS
  // =============================

  /// Follow a user
  Future<bool> followUser(String followerId, String followedId) async {
    _isFollowOperationInProgress = true;
    notifyListeners();

    try {
      await _repository.followUser(followerId, followedId);

      // Real-time update: Refresh both tabs after following (without loading indicators)
      await _refreshFeedsQuietly(followerId);

      return true;
    } catch (e) {
      _setError('Failed to follow user: $e');
      return false;
    } finally {
      _isFollowOperationInProgress = false;
      notifyListeners();
    }
  }

  /// Unfollow a user
  Future<bool> unfollowUser(String followerId, String followedId) async {
    _isFollowOperationInProgress = true;
    notifyListeners();

    try {
      await _repository.unfollowUser(followerId, followedId);

      // Real-time update: Refresh both tabs after unfollowing (without loading indicators)
      await _refreshFeedsQuietly(followerId);

      return true;
    } catch (e) {
      _setError('Failed to unfollow user: $e');
      return false;
    } finally {
      _isFollowOperationInProgress = false;
      notifyListeners();
    }
  }

  /// Refresh feeds quietly without showing loading indicators
  Future<void> _refreshFeedsQuietly(String currentUserId) async {
    try {
      // Load feeds without setting loading state
      final recentFeedsTask = _repository.getNotFollowingFeeds(
        currentUserId,
        limit: 15,
      );

      final forYouFeedsTask = _repository.getFollowingFeeds(
        currentUserId,
        limit: 15,
      );

      // Wait for both to complete
      final results = await Future.wait([recentFeedsTask, forYouFeedsTask]);
      final recentFeeds = results[0];
      final forYouFeeds = results[1];

      // Update feeds
      _recentFeeds = recentFeeds;
      _forYouFeeds = forYouFeeds;

      // Load interactions for both feed lists
      final allFeeds = [...recentFeeds, ...forYouFeeds];
      if (allFeeds.isNotEmpty) {
        await _loadFeedInteractions(allFeeds, currentUserId);
      }

      notifyListeners();
    } catch (e) {
      print('Error refreshing feeds quietly: $e');
      // Don't show error for quiet refresh, just log it
    }
  }

  /// Check if current user is following another user
  Future<bool> isFollowing(String followerId, String followedId) async {
    try {
      return await _repository.isFollowing(followerId, followedId);
    } catch (e) {
      print('Error checking if following: $e');
      return false;
    }
  }

  // =============================
  // UTILITY METHODS
  // =============================

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _setSending(bool sending) {
    if (_isSending != sending) {
      _isSending = sending;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _setError(String error) {
    if (_error != error) {
      _error = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Get user information by ID
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      return await _repository.getUserInfo(userId);
    } catch (e) {
      print('FeedProvider: Error getting user info: $e');
      return null;
    }
  }

  /// Load likes for a specific feed if not already loaded
  Future<void> loadFeedLikes(String feedId) async {
    try {
      // Only load if not already loaded or if empty
      if (_feedLikes[feedId] == null || _feedLikes[feedId]!.isEmpty) {
        print('FeedProvider: Loading likes for feed $feedId');
        final likes = await _repository.getFeedLikes(feedId);
        _feedLikes[feedId] = likes;
        print('FeedProvider: Loaded ${likes.length} likes for feed $feedId');
        notifyListeners();
      }
    } catch (e) {
      print('FeedProvider: Error loading likes for feed $feedId: $e');
    }
  }

  /// Clear all data
  void clear() {
    _recentFeeds = [];
    _forYouFeeds = [];
    _feedComments = {};
    _feedLikes = {};
    _likedPosts = {};
    _isLoading = false;
    _isCommentsLoading = false;
    _isSending = false;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
