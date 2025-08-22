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
    final response = await _client.from('feed').insert(data).select().single();
    return Feed.fromJson(response);
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

    return Feed.fromJson({
      ...response,
      'image_urls': images,
      'likes_count': 0, // Will be calculated separately
      'comments_count': 0, // Will be calculated separately
      'is_liked': false, // Will be calculated separately
    });
  }

  /// Update feed post
  Future<Feed> updateFeedPost(Feed post) async {
    final response = await _client
        .from('feed')
        .update(post.toJson())
        .eq('id', post.id)
        .select()
        .single();
    return Feed.fromJson(response);
  }

  /// Delete feed post
  Future<void> deleteFeedPost(String id) async {
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

    // Process the response to include image URLs
    return (response as List).map((json) {
      final images =
          (json['feed_images'] as List?)
              ?.map((img) => img['image_url'] as String)
              .toList() ??
          [];

      return Feed.fromJson({
        ...json,
        'image_urls': images,
        'likes_count': 0, // Will be calculated separately
        'comments_count': 0, // Will be calculated separately
        'is_liked': false, // Will be calculated separately
      });
    }).toList();
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

    // Process the response to include image URLs
    return (response as List).map((json) {
      final images =
          (json['feed_images'] as List?)
              ?.map((img) => img['image_url'] as String)
              .toList() ??
          [];

      return Feed.fromJson({
        ...json,
        'image_urls': images,
        'likes_count': 0, // Will be calculated separately
        'comments_count': 0, // Will be calculated separately
        'is_liked': false, // Will be calculated separately
      });
    }).toList();
  }

  // =============================
  // COMMENT OPERATIONS
  // =============================

  /// Add comment to feed post
  Future<FeedComment> addFeedComment(FeedComment comment) async {
    final data = comment.toJson();
    data.remove('id');
    final response = await _client
        .from('feed_comments')
        .insert(data)
        .select()
        .single();
    return FeedComment.fromJson(response);
  }

  /// Get comments for feed post
  Future<List<FeedComment>> getFeedComments(
    String feedId, {
    int limit = 50,
  }) async {
    final response = await _client
        .from('feed_comments')
        .select()
        .eq('feed_id', feedId)
        .order('created_at', ascending: true)
        .limit(limit);
    return (response as List)
        .map((json) => FeedComment.fromJson(json))
        .toList();
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
