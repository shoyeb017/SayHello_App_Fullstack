/// Model classes for Feed functionality from Supabase
/// Handles social feed posts, interactions, and community content

class Feed {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? imageUrl;
  final String? videoUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final String? language;
  final List<String> tags;

  const Feed({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    this.videoUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    this.language,
    required this.tags,
  });

  /// Create Feed from JSON (Supabase response)
  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      language: json['language'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  /// Convert Feed to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
      'video_url': videoUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
      'language': language,
      'tags': tags,
    };
  }

  /// Create a copy with modified fields
  Feed copyWith({
    String? id,
    String? userId,
    String? content,
    DateTime? createdAt,
    String? imageUrl,
    String? videoUrl,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    String? language,
    List<String>? tags,
  }) {
    return Feed(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      language: language ?? this.language,
      tags: tags ?? List.from(this.tags),
    );
  }

  /// Check if feed has media content
  bool get hasMedia => hasImage || hasVideo;

  /// Check if feed has image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Check if feed has video
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

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
  final String userId;
  final String comment;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;

  const FeedComment({
    required this.id,
    required this.feedId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    required this.likesCount,
    required this.isLiked,
  });

  /// Create FeedComment from JSON (Supabase response)
  factory FeedComment.fromJson(Map<String, dynamic> json) {
    return FeedComment(
      id: json['id'] as String,
      feedId: json['feed_id'] as String,
      userId: json['user_id'] as String,
      comment: json['comment'] as String,
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
      'user_id': userId,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'is_liked': isLiked,
    };
  }

  /// Create a copy with modified fields
  FeedComment copyWith({
    String? id,
    String? feedId,
    String? userId,
    String? comment,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
  }) {
    return FeedComment(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      userId: userId ?? this.userId,
      comment: comment ?? this.comment,
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
  final bool isInstructor;

  const FeedWithUser({
    required this.feed,
    required this.userName,
    this.userAvatarUrl,
    required this.isInstructor,
  });

  /// Create FeedWithUser from JSON with user data
  factory FeedWithUser.fromJson(Map<String, dynamic> json) {
    return FeedWithUser(
      feed: Feed.fromJson(json),
      userName: json['user_name'] as String,
      userAvatarUrl: json['user_avatar_url'] as String?,
      isInstructor: json['is_instructor'] as bool? ?? false,
    );
  }

  /// Get user display name with instructor badge
  String get userDisplayName {
    return isInstructor ? '$userName 👨‍🏫' : userName;
  }

  @override
  String toString() {
    return 'FeedWithUser(feed: ${feed.id}, user: $userName)';
  }
}
