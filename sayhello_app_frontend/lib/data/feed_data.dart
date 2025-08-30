/// Feed Repository - Handles all social feed and feed-related database operations
/// Provides CRUD operations for posts, comments, and likes functionality
///
/// TODO: Add Supabase dependency to pubspec.yaml:
/// dependencies:
///   supabase_flutter: ^2.0.0

import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_config.dart';
import '../models/models.dart';

class FeedRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  // =============================
  // FEED POST OPERATIONS
  // =============================

  /// Create a new feed post
  Future<Feed> createFeedPost(Feed post) async {
    final data = post.toJson();
    data.remove('id');
    data.remove('likes_count');
    data.remove('comments_count');
    data.remove('is_liked');
    data.remove('image_urls'); // Will be handled separately

    final response = await _client.from('feed').insert(data).select().single();

    // Insert images if any
    if (post.imageUrls.isNotEmpty) {
      final feedId = response['id'] as String;
      await _insertFeedImages(feedId, post.imageUrls);
    }

    return Feed.fromJson({
      ...response,
      'image_urls': post.imageUrls,
      'likes_count': 0,
      'comments_count': 0,
      'is_liked': false,
    });
  }

  /// Insert feed images
  Future<void> _insertFeedImages(String feedId, List<String> imageUrls) async {
    final imageData = imageUrls.asMap().entries.map((entry) {
      return {
        'feed_id': feedId,
        'image_url': entry.value,
        'position': entry.key,
      };
    }).toList();

    await _client.from('feed_images').insert(imageData);
  }

  /// Get feed post by ID
  Future<Feed?> getFeedPostById(String id) async {
    final response = await _client
        .from('feed')
        .select('''
          id,
          learner_id,
          content_text,
          created_at,
          feed_images (
            image_url
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    final images =
        (response['feed_images'] as List?)
            ?.map((img) => img['image_url'] as String)
            .toList() ??
        [];

    // Get counts separately
    final likesCount = await getFeedLikeCount(id);
    final commentsCount = await getFeedCommentCount(id);

    return Feed.fromJson({
      ...response,
      'image_urls': images,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': false, // Will be calculated separately if needed
    });
  }

  /// Update feed post
  Future<Feed> updateFeedPost(Feed post) async {
    final data = {'content_text': post.contentText};

    final response = await _client
        .from('feed')
        .update(data)
        .eq('id', post.id)
        .select()
        .single();
    return Feed.fromJson({
      ...response,
      'image_urls': post.imageUrls,
      'likes_count': post.likesCount,
      'comments_count': post.commentsCount,
      'is_liked': post.isLiked,
    });
  }

  /// Delete feed post
  Future<void> deleteFeedPost(String id) async {
    // Delete images first (due to foreign key constraint)
    await _client.from('feed_images').delete().eq('feed_id', id);
    // Delete comments
    await _client.from('feed_comments').delete().eq('feed_id', id);
    // Delete likes
    await _client.from('feed_likes').delete().eq('feed_id', id);
    // Delete feed
    await _client.from('feed').delete().eq('id', id);
  }

  /// Get all feed posts (with pagination)
  Future<List<Feed>> getAllFeedPosts({int limit = 20, int offset = 0}) async {
    final response = await _client
        .from('feed')
        .select('''
          id,
          learner_id,
          content_text,
          created_at,
          feed_images (
            image_url
          )
        ''')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return _processFeedResponse(response);
  }

  /// Get feed posts by user
  Future<List<Feed>> getFeedPostsByUser(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from('feed')
        .select('''
          id,
          learner_id,
          content_text,
          created_at,
          feed_images (
            image_url
          )
        ''')
        .eq('learner_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return _processFeedResponse(response);
  }

  /// Get feeds from users NOT being followed (excluding own posts)
  Future<List<FeedWithUser>> getNotFollowingFeeds(
    String currentUserId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // First get the list of users that the current user follows
      final followingIds = await getFollowing(currentUserId);

      print(
        'Not following feeds - Following IDs for user $currentUserId: $followingIds',
      );

      // Add current user to the exclusion list (don't show own posts)
      final excludeIds = [...followingIds, currentUserId];

      print('Excluding user IDs: $excludeIds');

      // Build the query differently to handle empty excludeIds
      var query = _client.from('feed').select('''
            id,
            learner_id,
            content_text,
            created_at,
            feed_images (
              image_url
            ),
            learner:learner_id (
              name,
              profile_image
            )
          ''');

      // If there are users to exclude, add the filter
      if (excludeIds.isNotEmpty) {
        query = query.not('learner_id', 'in', '(${excludeIds.join(',')})');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      print('Not following feeds query response: ${response.length} feeds');
      return _processFeedWithUserResponse(response);
    } catch (e) {
      print('Error in getNotFollowingFeeds: $e');
      return [];
    }
  }

  /// Get following feeds (feeds from users that current user follows)
  Future<List<FeedWithUser>> getFollowingFeeds(
    String currentUserId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // First get the list of users that the current user follows
      final followingIds = await getFollowing(currentUserId);

      print('Following IDs for user $currentUserId: $followingIds');

      // If not following anyone, return empty list
      if (followingIds.isEmpty) {
        print('No users being followed, returning empty list');
        return [];
      }

      final response = await _client
          .from('feed')
          .select('''
            id,
            learner_id,
            content_text,
            created_at,
            feed_images (
              image_url
            ),
            learner:learner_id (
              name,
              profile_image
            )
          ''')
          .inFilter('learner_id', followingIds)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      print('Following feeds query response: ${response.length} feeds');
      return _processFeedWithUserResponse(response);
    } catch (e) {
      print('Error in getFollowingFeeds: $e');
      throw e;
    }
  }

  /// Get public feeds (all feeds except current user's)
  Future<List<FeedWithUser>> getPublicFeeds({
    String? excludeUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client.from('feed').select('''
          id,
          learner_id,
          content_text,
          created_at,
          feed_images (
            image_url
          ),
          learner:learner_id (
            name,
            profile_image
          )
        ''');

    if (excludeUserId != null) {
      query = query.neq('learner_id', excludeUserId);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return _processFeedWithUserResponse(response);
  }

  /// Process feed response helper
  Future<List<Feed>> _processFeedResponse(List<dynamic> response) async {
    final feeds = <Feed>[];

    for (final json in response) {
      final images =
          (json['feed_images'] as List?)
              ?.map((img) => img['image_url'] as String)
              .toList() ??
          [];

      final feedId = json['id'] as String;
      final likesCount = await getFeedLikeCount(feedId);
      final commentsCount = await getFeedCommentCount(feedId);

      feeds.add(
        Feed.fromJson({
          ...json,
          'image_urls': images,
          'likes_count': likesCount,
          'comments_count': commentsCount,
          'is_liked': false, // Will be set by provider
        }),
      );
    }

    return feeds;
  }

  /// Process feed with user response helper
  Future<List<FeedWithUser>> _processFeedWithUserResponse(
    List<dynamic> response,
  ) async {
    final feedsWithUser = <FeedWithUser>[];

    for (final json in response) {
      try {
        final images =
            (json['feed_images'] as List?)
                ?.map((img) => img['image_url'] as String)
                .toList() ??
            [];

        final feedId = json['id'] as String;
        final likesCount = await getFeedLikeCount(feedId);
        final commentsCount = await getFeedCommentCount(feedId);

        final learner = json['learner'] as Map<String, dynamic>?;

        final feed = Feed.fromJson({
          ...json,
          'image_urls': images,
          'likes_count': likesCount,
          'comments_count': commentsCount,
          'is_liked': false, // Will be set by provider
        });

        feedsWithUser.add(
          FeedWithUser(
            feed: feed,
            userName: learner?['name'] as String? ?? 'Unknown User',
            userAvatarUrl: learner?['profile_image'] as String?,
          ),
        );
      } catch (e) {
        print('Error processing feed item: $e');
        print('JSON data: $json');
        // Skip this item and continue with others
        continue;
      }
    }

    return feedsWithUser;
  }

  // =============================
  // COMMENT OPERATIONS
  // =============================

  /// Add comment to feed post
  Future<FeedCommentWithUser> addFeedComment(FeedComment comment) async {
    final data = comment.toJson();
    data.remove('id');
    data.remove('likes_count');
    data.remove('is_liked');

    final response = await _client
        .from('feed_comments')
        .insert(data)
        .select('''
          id,
          feed_id,
          learner_id,
          content_text,
          translated_content,
          parent_comment_id,
          created_at,
          learner:learner_id (
            name,
            profile_image
          )
        ''')
        .single();
    
    final learner = response['learner'] as Map<String, dynamic>?;
    return FeedCommentWithUser(
      comment: FeedComment.fromJson({
        ...response,
        'likes_count': 0,
        'is_liked': false,
      }),
      userName: learner?['name'] as String? ?? 'Unknown User',
      userAvatarUrl: learner?['profile_image'] as String?,
    );
  }

  /// Get comments for feed post
  Future<List<FeedCommentWithUser>> getFeedComments(
    String feedId, {
    int limit = 50,
  }) async {
    final response = await _client
        .from('feed_comments')
        .select('''
          id,
          feed_id,
          learner_id,
          content_text,
          translated_content,
          parent_comment_id,
          created_at,
          learner:learner_id (
            name,
            profile_image
          )
        ''')
        .eq('feed_id', feedId)
        .order('created_at', ascending: true)
        .limit(limit);
    
    return (response as List)
        .map((json) {
          final learner = json['learner'] as Map<String, dynamic>?;
          return FeedCommentWithUser(
            comment: FeedComment.fromJson({
              ...json,
              'likes_count': 0, // TODO: Implement comment likes
              'is_liked': false,
            }),
            userName: learner?['name'] as String? ?? 'Unknown User',
            userAvatarUrl: learner?['profile_image'] as String?,
          );
        })
        .toList();
  }

  /// Get comment count for feed
  Future<int> getFeedCommentCount(String feedId) async {
    final response = await _client
        .from('feed_comments')
        .select()
        .eq('feed_id', feedId);
    return (response as List).length;
  }

  /// Delete feed comment
  Future<void> deleteFeedComment(String commentId) async {
    await _client.from('feed_comments').delete().eq('id', commentId);
  }

  // =============================
  // LIKE OPERATIONS
  // =============================

  /// Like a feed post
  Future<void> likeFeed(String feedId, String userId) async {
    await _client.from('feed_likes').insert({
      'feed_id': feedId,
      'learner_id': userId,
    });
  }

  /// Unlike a feed post
  Future<void> unlikeFeed(String feedId, String userId) async {
    await _client
        .from('feed_likes')
        .delete()
        .eq('feed_id', feedId)
        .eq('learner_id', userId);
  }

  /// Get like count for feed post
  Future<int> getFeedLikeCount(String feedId) async {
    final response = await _client
        .from('feed_likes')
        .select()
        .eq('feed_id', feedId);
    return (response as List).length;
  }

  /// Get likes for a feed post
  Future<List<FeedLike>> getFeedLikes(String feedId) async {
    final response = await _client
        .from('feed_likes')
        .select()
        .eq('feed_id', feedId)
        .order('created_at', ascending: false);
    return (response as List).map((json) => FeedLike.fromJson(json)).toList();
  }

  /// Check if user liked feed post
  Future<bool> isFeedLikedByUser(String feedId, String userId) async {
    final response = await _client
        .from('feed_likes')
        .select()
        .eq('feed_id', feedId)
        .eq('learner_id', userId)
        .maybeSingle();
    return response != null;
  }

  // =============================
  // FOLLOW OPERATIONS
  // =============================

  /// Follow a user
  Future<void> followUser(String followerId, String followedId) async {
    await _client.from('followers').insert({
      'follower_user_id': followerId,
      'followed_user_id': followedId,
    });
  }

  /// Unfollow a user
  Future<void> unfollowUser(String followerId, String followedId) async {
    await _client
        .from('followers')
        .delete()
        .eq('follower_user_id', followerId)
        .eq('followed_user_id', followedId);
  }

  /// Check if user is following another user
  Future<bool> isFollowing(String followerId, String followedId) async {
    final response = await _client
        .from('followers')
        .select()
        .eq('follower_user_id', followerId)
        .eq('followed_user_id', followedId)
        .maybeSingle();
    return response != null;
  }

  /// Get followers for a user
  Future<List<String>> getFollowers(String userId) async {
    try {
      final response = await _client
          .from('followers')
          .select('follower_user_id')
          .eq('followed_user_id', userId);
      return (response as List)
          .map((item) => item['follower_user_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();
    } catch (e) {
      print('Error in getFollowers: $e');
      return [];
    }
  }

  /// Get following list for a user
  Future<List<String>> getFollowing(String userId) async {
    try {
      final response = await _client
          .from('followers')
          .select('followed_user_id')
          .eq('follower_user_id', userId);
      return (response as List)
          .map((item) => item['followed_user_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();
    } catch (e) {
      print('Error in getFollowing: $e');
      return [];
    }
  }

  // =============================
  // REAL-TIME SUBSCRIPTIONS (Commented out for compatibility)
  // =============================

  /*
  /// Subscribe to new posts
  Stream<FeedPost> subscribeToNewPosts() {
    return _client
        .from('feed_posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => FeedPost.fromJson(data.first));
  }

  /// Subscribe to comments for a post
  Stream<List<FeedComment>> subscribeToComments(String postId) {
    return _client
        .from('feed_comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .map((data) => (data as List)
            .map((json) => FeedComment.fromJson(json))
            .toList());
  }
  */
}
