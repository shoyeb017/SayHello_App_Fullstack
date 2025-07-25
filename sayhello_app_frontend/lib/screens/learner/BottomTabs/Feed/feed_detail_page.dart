import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'feed_page.dart'; // Import for data models

class FeedDetailPage extends StatefulWidget {
  final FeedPost post;
  final List<FeedComment> comments;
  final List<FeedLike> likes;

  const FeedDetailPage({
    super.key,
    required this.post,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Post Card (Expanded)
                  DetailedPostCard(post: widget.post, likes: widget.likes),

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
                          )!.commentsWithCount(widget.comments.length),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Comments List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.comments.length,
                          itemBuilder: (context, index) {
                            return CommentCard(
                              comment: widget.comments[index],
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
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=10',
                    ),
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
                          Icon(
                            Icons.emoji_emotions_outlined,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
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
                          Icon(
                            Icons.translate,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Color(0xFF7d54fb),
                              size: 20,
                            ),
                            onPressed: () {
                              // Handle send comment
                              _commentController.clear();
                            },
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
      ),
    );
  }
}

class DetailedPostCard extends StatefulWidget {
  final FeedPost post;
  final List<FeedLike> likes;

  const DetailedPostCard({super.key, required this.post, required this.likes});

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
                backgroundImage: NetworkImage(widget.post.userAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.post.userName,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTimeAgo(widget.post.createdAt),
                          style: TextStyle(color: iconColor, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
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
                              widget.post.nativeLanguage,
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
                              widget.post.learningLanguage,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.post.isFollowing
                      ? (isDark
                            ? const Color(0xFF311c85)
                            : const Color(0xFFefecff))
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.post.isFollowing
                      ? AppLocalizations.of(context)!.following
                      : AppLocalizations.of(context)!.follow,
                  style: TextStyle(
                    color: widget.post.isFollowing
                        ? const Color(0xFF7758f3)
                        : (isDark ? Colors.white : Colors.black),
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
          if (widget.post.images.isNotEmpty) ...[
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.post.images.length == 1 ? 1 : 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: widget.post.images.length == 1 ? 16 / 9 : 1,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.post.images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: Image.network(
                      widget.post.images[index],
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
    final content = _isTranslated ? _dummyTranslation : widget.post.content;

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
    return Row(
      children: [
        // Like button
        GestureDetector(
          onTap: () {
            // Handle like
          },
          child: Row(
            children: [
              Icon(
                widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                color: widget.post.isLiked
                    ? const Color(0xFF7d54fb)
                    : iconColor,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.post.likeCount}',
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
              '${widget.post.commentCount}',
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
        const SizedBox(width: 16),
        // Share button
        Icon(Icons.share, color: iconColor, size: 20),
      ],
    );
  }

  Widget _buildLikedUsersRow(Color? iconColor) {
    // Use actual likes data instead of likedByAvatars
    final likesData = widget.likes.take(3).toList();

    return Row(
      children: [
        // Liked users avatars - show up to 3, use actual likes data
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
                    backgroundImage: NetworkImage(likesData[0].userAvatar),
                  ),
                if (likesData.length > 1)
                  Positioned(
                    left: 16,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(likesData[1].userAvatar),
                    ),
                  ),
                if (likesData.length > 2)
                  Positioned(
                    left: 32,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(likesData[2].userAvatar),
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
            AppLocalizations.of(context)!.likesWithCount(widget.post.likeCount),
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
    // Show modal with actual users who liked
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
            // List of users who liked using actual data
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
                        backgroundImage: NetworkImage(like.userAvatar),
                      ),
                      title: Text(like.userName),
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

class CommentCard extends StatelessWidget {
  final FeedComment comment;
  final int index;

  const CommentCard({super.key, required this.comment, required this.index});

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
            backgroundImage: NetworkImage(comment.userAvatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Color(0xFF7d54fb),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: TextStyle(color: iconColor, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.comment,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite_border, color: iconColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${comment.likeCount}',
                          style: TextStyle(color: iconColor, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Text(
                      AppLocalizations.of(context)!.reply,
                      style: TextStyle(color: iconColor, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    const Text('😊 ❤️ 👍', style: TextStyle(fontSize: 12)),
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
