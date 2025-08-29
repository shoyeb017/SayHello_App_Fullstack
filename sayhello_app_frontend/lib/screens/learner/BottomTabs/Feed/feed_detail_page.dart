import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/models.dart';
import '../../../../providers/feed_provider.dart';
import '../../../../providers/auth_provider.dart';

class FeedDetailPage extends StatefulWidget {
  final FeedWithUser feedWithUser;
  final List<FeedComment> comments;
  final List<FeedLike> likes;

  const FeedDetailPage({
    super.key,
    required this.feedWithUser,
    required this.comments,
    required this.likes,
  });

  @override
  State<FeedDetailPage> createState() => _FeedDetailPageState();
}

class _FeedDetailPageState extends State<FeedDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.details,
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          final feed = widget.feedWithUser.feed;
          final currentComments =
              feedProvider.feedComments[feed.id] ?? widget.comments;
          final currentLikes = feedProvider.feedLikes[feed.id] ?? widget.likes;
          final isLiked = feedProvider.likedPosts[feed.id] ?? false;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Post Card (Expanded)
                      DetailedPostCard(
                        feedWithUser: widget.feedWithUser,
                        likes: currentLikes,
                        isLiked: isLiked,
                        onLikePressed: () => _handleLike(feed.id),
                      ),

                      // Comments Section
                      Container(
                        color: backgroundColor,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.commentsWithCount(currentComments.length),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Comments List
                            if (currentComments.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    'No comments yet. Be the first to comment!',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: currentComments.length,
                                itemBuilder: (context, index) {
                                  return CommentCard(
                                    comment: currentComments[index],
                                    index: index,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Comment Input Section
              Container(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: Row(
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                authProvider.currentUser?.profileImage != null
                                ? NetworkImage(
                                    authProvider.currentUser!.profileImage!,
                                  )
                                : null,
                            child:
                                authProvider.currentUser?.profileImage == null
                                ? Text(
                                    authProvider.currentUser?.name
                                            .substring(0, 1)
                                            .toUpperCase() ??
                                        'U',
                                    style: const TextStyle(fontSize: 12),
                                  )
                                : null,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  style: TextStyle(color: textColor),
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.addComment,
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Color(0xFF7d54fb),
                                  size: 20,
                                ),
                                onPressed: () => _handleAddComment(feed.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleLike(String feedId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      feedProvider.toggleFeedLike(feedId, authProvider.currentUser!.id);
    }
  }

  void _handleAddComment(String feedId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);

    if (authProvider.currentUser != null &&
        _commentController.text.trim().isNotEmpty) {
      feedProvider.addFeedComment(
        feedId: feedId,
        learnerId: authProvider.currentUser!.id,
        contentText: _commentController.text.trim(),
      );
      _commentController.clear();
    }
  }
}

class DetailedPostCard extends StatefulWidget {
  final FeedWithUser feedWithUser;
  final List<FeedLike> likes;
  final bool isLiked;
  final VoidCallback onLikePressed;

  const DetailedPostCard({
    super.key,
    required this.feedWithUser,
    required this.likes,
    required this.isLiked,
    required this.onLikePressed,
  });

  @override
  State<DetailedPostCard> createState() => _DetailedPostCardState();
}

class _DetailedPostCardState extends State<DetailedPostCard> {
  bool _isTranslated = false;

  // Dummy translation - replace with actual API later
  String get _dummyTranslation =>
      'これは投稿内容のダミー翻訳です。将来的には、実際の翻訳APIを使用して、さまざまな言語でリアルタイム翻訳を提供する予定です';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final feed = widget.feedWithUser.feed;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row with updated layout
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.feedWithUser.userAvatarUrl != null
                    ? NetworkImage(widget.feedWithUser.userAvatarUrl!)
                    : null,
                child: widget.feedWithUser.userAvatarUrl == null
                    ? Text(
                        widget.feedWithUser.userName
                            .substring(0, 1)
                            .toUpperCase(),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.feedWithUser.userName,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTimeAgo(feed.createdAt),
                          style: TextStyle(color: iconColor, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Language badges (placeholder)
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 2),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'EN', // Placeholder - would come from user profile
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.sync_alt,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 2),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.purple,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'JP', // Placeholder - would come from user profile
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Follow button placeholder
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.follow,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Text Content with translation
          _buildTranslatableContent(textColor),
          const SizedBox(height: 12),

          // Image Grid
          if (feed.imageUrls.isNotEmpty) ...[
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: feed.imageUrls.length == 1 ? 1 : 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: feed.imageUrls.length == 1 ? 16 / 9 : 1,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: feed.imageUrls.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: Image.network(
                      feed.imageUrls[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],

          // Stats row with like, comment, translate, share
          _buildStatsRow(iconColor),
          const SizedBox(height: 12),

          // Liked users display
          _buildLikedUsersRow(iconColor),
        ],
      ),
    );
  }

  Widget _buildTranslatableContent(Color textColor) {
    final content = _isTranslated
        ? _dummyTranslation
        : widget.feedWithUser.feed.contentText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isTranslated) ...[
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7d54fb).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF7d54fb).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.translate, size: 16, color: const Color(0xFF7d54fb)),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.translated,
                  style: TextStyle(
                    color: const Color(0xFF7d54fb),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        Text(
          content,
          style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildStatsRow(Color? iconColor) {
    final feed = widget.feedWithUser.feed;

    return Row(
      children: [
        // Like button
        GestureDetector(
          onTap: widget.onLikePressed,
          child: Row(
            children: [
              Icon(
                widget.isLiked ? Icons.favorite : Icons.favorite_border,
                color: widget.isLiked ? const Color(0xFF7d54fb) : iconColor,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${feed.likesCount}',
                style: TextStyle(color: iconColor, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Comments button
        Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: iconColor, size: 20),
            const SizedBox(width: 4),
            Text(
              '${feed.commentsCount}',
              style: TextStyle(color: iconColor, fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        // Translate button
        GestureDetector(
          onTap: () {
            setState(() {
              _isTranslated = !_isTranslated;
            });
          },
          child: Icon(
            Icons.translate,
            color: _isTranslated ? const Color(0xFF7d54fb) : iconColor,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildLikedUsersRow(Color? iconColor) {
    // Use actual likes data
    final likesData = widget.likes.take(3).toList();
    final feed = widget.feedWithUser.feed;

    return Row(
      children: [
        // Liked users avatars - show up to 3, using placeholder for now
        if (likesData.isNotEmpty) ...[
          SizedBox(
            height: 32,
            width: likesData.length == 1
                ? 24
                : likesData.length == 2
                ? 40
                : 56,
            child: Stack(
              children: [
                if (likesData.isNotEmpty)
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      '1',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ),
                if (likesData.length > 1)
                  Positioned(
                    left: 16,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        '2',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                if (likesData.length > 2)
                  Positioned(
                    left: 32,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        '3',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
        GestureDetector(
          onTap: () {
            // Show list of users who liked
            _showLikedUsersList();
          },
          child: Text(
            AppLocalizations.of(context)!.likesWithCount(feed.likesCount),
            style: const TextStyle(
              color: Color(0xFF7d54fb),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showLikedUsersList() {
    // Show modal with users who liked (placeholder implementation)
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.likedBy,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Placeholder for likes list
            if (widget.likes.isEmpty)
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(AppLocalizations.of(context)!.noLikesYet),
              )
            else
              ...widget.likes
                  .map(
                    (like) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          'U',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      title: Text(
                        'User ${like.id.substring(0, 8)}',
                      ), // Placeholder
                      trailing: Text(_formatTimeAgo(like.createdAt)),
                    ),
                  )
                  .toList(),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class CommentCard extends StatefulWidget {
  final FeedComment comment;
  final int index;

  const CommentCard({super.key, required this.comment, required this.index});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _isTranslated = false;

  // Dummy translation for comments
  String get _dummyTranslation => 'これはコメントのダミー翻訳です。実際の翻訳APIを使用して翻訳されます。';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtextColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final iconColor = isDark ? Colors.grey[500] : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Text(
              'U',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'User ${widget.comment.id.substring(0, 8)}', // Placeholder username
                      style: const TextStyle(
                        color: Color(0xFF7d54fb),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(widget.comment.createdAt),
                      style: TextStyle(color: iconColor, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isTranslated) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7d54fb).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF7d54fb).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.translate,
                              size: 12,
                              color: const Color(0xFF7d54fb),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.translated,
                              style: TextStyle(
                                color: const Color(0xFF7d54fb),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Text(
                      _isTranslated
                          ? _dummyTranslation
                          : widget.comment.contentText,
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isTranslated = !_isTranslated;
                        });
                      },
                      child: Icon(
                        Icons.translate,
                        color: _isTranslated
                            ? const Color(0xFF7d54fb)
                            : iconColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
