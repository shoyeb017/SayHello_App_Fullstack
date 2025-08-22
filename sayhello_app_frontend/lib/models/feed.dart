/// Model classes for Feed functionality from Supabase
/// Handles social feed posts, interactions, and community content

class Feed {
  final String id;
  final String learnerId; // Changed from userId to match SQL schema
  final String contentText; // Changed from content to match SQL schema
  final DateTime createdAt;
  final List<String> imageUrls; // Changed to list to match feed_images table
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  const Feed({
    required this.id,
    required this.learnerId,
    required this.contentText,
    required this.createdAt,
    this.imageUrls = const [],
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
  });

  /// Create Feed from JSON (Supabase response)
  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'] as String,
      learnerId: json['learner_id'] as String,
      contentText: json['content_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  /// Convert Feed to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'learner_id': learnerId,
      'content_text': contentText,
      'created_at': createdAt.toIso8601String(),
      'image_urls': imageUrls,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
    };
  }

  /// Create a copy with modified fields
  Feed copyWith({
    String? id,
    String? learnerId,
    String? contentText,
    DateTime? createdAt,
    List<String>? imageUrls,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return Feed(
      id: id ?? this.id,
      learnerId: learnerId ?? this.learnerId,
      contentText: contentText ?? this.contentText,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? List.from(this.imageUrls),
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  /// Check if feed has media content
  bool get hasMedia => hasImages;

  /// Check if feed has images
  bool get hasImages => imageUrls.isNotEmpty;

  /// Get first image URL
  String? get firstImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Toggle like status
  Feed toggleLike() {
    return copyWith(
      isLiked: !isLiked,
      likesCount: isLiked ? likesCount - 1 : likesCount + 1,
    );
  }

  /// Add comment count
  Feed addComment() {
    return copyWith(commentsCount: commentsCount + 1);
  }

  @override
  String toString() {
    return 'Feed(id: $id, likes: $likesCount, comments: $commentsCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Feed && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class FeedComment {
  final String id;
  final String feedId;
  final String learnerId; // Changed from userId to match SQL schema
  final String contentText; // Changed from comment to match SQL schema
  final String? translatedContent; // Added to match SQL schema
  final String? parentCommentId; // Added to match SQL schema
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;

  const FeedComment({
    required this.id,
    required this.feedId,
    required this.learnerId,
    required this.contentText,
    this.translatedContent,
    this.parentCommentId,
    required this.createdAt,
    required this.likesCount,
    required this.isLiked,
  });

  /// Create FeedComment from JSON (Supabase response)
  factory FeedComment.fromJson(Map<String, dynamic> json) {
    return FeedComment(
      id: json['id'] as String,
      feedId: json['feed_id'] as String,
      learnerId: json['learner_id'] as String,
      contentText: json['content_text'] as String,
      translatedContent: json['translated_content'] as String?,
      parentCommentId: json['parent_comment_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  /// Convert FeedComment to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feed_id': feedId,
      'learner_id': learnerId,
      'content_text': contentText,
      'translated_content': translatedContent,
      'parent_comment_id': parentCommentId,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'is_liked': isLiked,
    };
  }

  /// Create a copy with modified fields
  FeedComment copyWith({
    String? id,
    String? feedId,
    String? learnerId,
    String? contentText,
    String? translatedContent,
    String? parentCommentId,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
  }) {
    return FeedComment(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      learnerId: learnerId ?? this.learnerId,
      contentText: contentText ?? this.contentText,
      translatedContent: translatedContent ?? this.translatedContent,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  /// Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Toggle like status
  FeedComment toggleLike() {
    return copyWith(
      isLiked: !isLiked,
      likesCount: isLiked ? likesCount - 1 : likesCount + 1,
    );
  }

  @override
  String toString() {
    return 'FeedComment(id: $id, feedId: $feedId, likes: $likesCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedComment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model for feed with user details (for joined queries)
class FeedWithUser {
  final Feed feed;
  final String userName;
  final String? userAvatarUrl;

  const FeedWithUser({
    required this.feed,
    required this.userName,
    this.userAvatarUrl,
  });

  /// Create FeedWithUser from JSON with user data
  factory FeedWithUser.fromJson(Map<String, dynamic> json) {
    return FeedWithUser(
      feed: Feed.fromJson(json),
      userName: json['user_name'] as String,
      userAvatarUrl: json['user_avatar_url'] as String?,
    );
  }

  @override
  String toString() {
    return 'FeedWithUser(feed: ${feed.id}, user: $userName)';
  }
}
