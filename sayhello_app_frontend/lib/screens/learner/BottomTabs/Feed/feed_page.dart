import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'feed_detail_page.dart';
import '../../Notifications/notifications.dart';
import '../../../../providers/settings_provider.dart';

// Data Models for Backend Integration
class FeedPost {
  final String feedId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String nativeLanguage;
  final String learningLanguage;
  final String content;
  final List<String> images;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final bool isFollowing;
  final bool isLiked;
  final List<String> likedByAvatars;

  FeedPost({
    required this.feedId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.nativeLanguage,
    required this.learningLanguage,
    required this.content,
    required this.images,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.isFollowing = false,
    this.isLiked = false,
    this.likedByAvatars = const [],
  });
}

class FeedLike {
  final String likeId;
  final String feedId;
  final String userId;
  final String userName;
  final String userAvatar;
  final DateTime createdAt;

  FeedLike({
    required this.likeId,
    required this.feedId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.createdAt,
  });
}

class FeedComment {
  final String commentId;
  final String feedId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String comment;
  final DateTime createdAt;
  final int likeCount;
  final Color userNameColor;

  FeedComment({
    required this.commentId,
    required this.feedId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.comment,
    required this.createdAt,
    required this.likeCount,
    required this.userNameColor,
  });
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data - replace with API calls later
  final List<FeedPost> _feedPosts = [
    FeedPost(
      feedId: 'feed_001',
      userId: 'user_001',
      userName: 'Yuki',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      nativeLanguage: 'JP',
      learningLanguage: 'EN',
      content:
          'Hello everyone! 👋\nI\'m learning English and would love to practice with native speakers. I can help you with Japanese in return! 🇯🇵\n\nI love anime, manga, and Japanese culture. Let\'s be friends! 😊 This is a longer caption to test the "more" functionality that should be truncated when it gets too long.',
      images: [
        'https://picsum.photos/200/200?random=1',
        'https://picsum.photos/200/200?random=2',
        'https://picsum.photos/200/200?random=3',
        'https://picsum.photos/200/200?random=4',
        'https://picsum.photos/200/200?random=5',
        'https://picsum.photos/200/200?random=6',
      ],
      likeCount: 42,
      commentCount: 47,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isLiked: false,
      likedByAvatars: [
        'https://i.pravatar.cc/150?img=2',
        'https://i.pravatar.cc/150?img=3',
        'https://i.pravatar.cc/150?img=4',
      ],
    ),
    FeedPost(
      feedId: 'feed_002',
      userId: 'user_002',
      userName: 'Maria',
      userAvatar: 'https://i.pravatar.cc/150?img=5',
      nativeLanguage: 'ES',
      learningLanguage: 'EN',
      content:
          '¡Hola! Learning English is so challenging but exciting! 📚\nAnyone want to practice conversation with me? I can help with Spanish! 🇪🇸',
      images: [
        'https://picsum.photos/200/200?random=5',
        'https://picsum.photos/200/200?random=6',
      ],
      likeCount: 28,
      commentCount: 15,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      isFollowing: true,
      isLiked: true,
      likedByAvatars: [
        'https://i.pravatar.cc/150?img=6',
        'https://i.pravatar.cc/150?img=7',
      ],
    ),
    FeedPost(
      feedId: 'feed_003',
      userId: 'user_003',
      userName: 'Chen Wei',
      userAvatar: 'https://i.pravatar.cc/150?img=8',
      nativeLanguage: 'ZH',
      learningLanguage: 'EN',
      content:
          'Just finished my first week of English classes! 🎉\nThe grammar is so different from Chinese. Any tips for remembering irregular verbs?',
      images: ['https://picsum.photos/200/200?random=7'],
      likeCount: 35,
      commentCount: 23,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      isLiked: false,
      likedByAvatars: [
        'https://i.pravatar.cc/150?img=9',
        'https://i.pravatar.cc/150?img=10',
        'https://i.pravatar.cc/150?img=11',
      ],
    ),
  ];

  // Dummy likes data - replace with API calls later
  final Map<String, List<FeedLike>> _feedLikes = {
    'feed_001': [
      FeedLike(
        likeId: 'like_001',
        feedId: 'feed_001',
        userId: 'user_004',
        userName: 'Megan',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      FeedLike(
        likeId: 'like_002',
        feedId: 'feed_001',
        userId: 'user_005',
        userName: 'Alex',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
    'feed_002': [
      FeedLike(
        likeId: 'like_003',
        feedId: 'feed_002',
        userId: 'user_current',
        userName: 'You',
        userAvatar: 'https://i.pravatar.cc/150?img=15',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ],
  };

  // Dummy comments data - replace with API calls later
  final Map<String, List<FeedComment>> _feedComments = {
    'feed_001': [
      FeedComment(
        commentId: 'comment_001',
        feedId: 'feed_001',
        userId: 'user_004',
        userName: 'Megan',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        comment: 'Your photos are AMAZINGLY BEAUTIFUL! ✨',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likeCount: 3,
        userNameColor: Colors.blue,
      ),
      FeedComment(
        commentId: 'comment_002',
        feedId: 'feed_001',
        userId: 'user_005',
        userName: 'Alex',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
        comment: 'I\'d love to practice Japanese with you! 🇯🇵',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likeCount: 5,
        userNameColor: Colors.green,
      ),
      FeedComment(
        commentId: 'comment_003',
        feedId: 'feed_001',
        userId: 'user_006',
        userName: 'Sarah',
        userAvatar: 'https://i.pravatar.cc/150?img=4',
        comment: 'Welcome to HelloTalk! 👋',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likeCount: 2,
        userNameColor: Colors.purple,
      ),
      FeedComment(
        commentId: 'comment_004',
        feedId: 'feed_001',
        userId: 'user_006',
        userName: 'Sarah',
        userAvatar: 'https://i.pravatar.cc/150?img=4',
        comment: 'Welcome to HelloTalk! 👋',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likeCount: 2,
        userNameColor: Colors.purple,
      ),
    ],
    'feed_002': [
      FeedComment(
        commentId: 'comment_004',
        feedId: 'feed_002',
        userId: 'user_007',
        userName: 'Tom',
        userAvatar: 'https://i.pravatar.cc/150?img=12',
        comment: 'Let\'s practice together! 😊',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likeCount: 4,
        userNameColor: Colors.orange,
      ),
    ],
    'feed_003': [
      FeedComment(
        commentId: 'comment_005',
        feedId: 'feed_003',
        userId: 'user_008',
        userName: 'Luna',
        userAvatar: 'https://i.pravatar.cc/150?img=13',
        comment: 'Great progress! Keep it up! 🌟',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likeCount: 6,
        userNameColor: Colors.pink,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update tab button colors
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(92),
        child: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              // 🔧 SETTINGS ICON - This is the settings button in the app bar
              // Click this to open the settings bottom sheet with theme and language options
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () =>
                    SettingsProvider.showSettingsBottomSheet(context),
              ),

              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.feed,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
              ),

              // 🔔 NOTIFICATION ICON - This is the notification button in the app bar
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  // Red dot for unread notifications
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        '3', // Number of unread notifications
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                indicator: const BoxDecoration(),
                labelPadding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _tabController.index == 0
                            ? (isDark
                                  ? const Color(0xFF311c85)
                                  : const Color(0xFFefecff))
                            : (isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.recent,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _tabController.index == 0
                                ? const Color(0xFF7758f3)
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _tabController.index == 1
                            ? (isDark
                                  ? const Color(0xFF311c85)
                                  : const Color(0xFFefecff))
                            : (isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.forYou,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _tabController.index == 1
                                ? const Color(0xFF7758f3)
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedContent(isFollowingFeed: true), // Recent - followed users
          _buildFeedContent(isFollowingFeed: false), // For You - public posts
        ],
      ),
    );
  }

  Widget _buildFeedContent({bool isFollowingFeed = true}) {
    // Filter posts based on tab
    List<FeedPost> filteredPosts;
    if (isFollowingFeed) {
      // Recent tab - show followed users' posts sorted by recent
      filteredPosts = _feedPosts
          .where((post) => post.isFollowing || post.userId == 'user_001')
          .toList();
      filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      // For You tab - show public posts (not following)
      filteredPosts = _feedPosts.where((post) => !post.isFollowing).toList();
      filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        final comments = _feedComments[post.feedId] ?? [];
        final likes = _feedLikes[post.feedId] ?? [];
        return FeedPostCard(
          post: post,
          comments: comments,
          likes: likes,
          onLikePressed: () => _handleLike(post.feedId),
        );
      },
    );
  }

  void _handleLike(String feedId) {
    setState(() {
      // Find the post and toggle like status
      final postIndex = _feedPosts.indexWhere((p) => p.feedId == feedId);
      if (postIndex != -1) {
        final post = _feedPosts[postIndex];
        final newLikeCount = post.isLiked
            ? post.likeCount - 1
            : post.likeCount + 1;

        // Update the post
        _feedPosts[postIndex] = FeedPost(
          feedId: post.feedId,
          userId: post.userId,
          userName: post.userName,
          userAvatar: post.userAvatar,
          nativeLanguage: post.nativeLanguage,
          learningLanguage: post.learningLanguage,
          content: post.content,
          images: post.images,
          likeCount: newLikeCount,
          commentCount: post.commentCount,
          createdAt: post.createdAt,
          isFollowing: post.isFollowing,
          isLiked: !post.isLiked,
          likedByAvatars: post.likedByAvatars,
        );

        // Update likes list
        if (post.isLiked) {
          // Remove like
          _feedLikes[feedId]?.removeWhere(
            (like) => like.userId == 'user_current',
          );
        } else {
          // Add like
          _feedLikes[feedId] ??= [];
          _feedLikes[feedId]!.insert(
            0,
            FeedLike(
              likeId: 'like_${DateTime.now().millisecondsSinceEpoch}',
              feedId: feedId,
              userId: 'user_current',
              userName: AppLocalizations.of(context)!.you,
              userAvatar: 'https://i.pravatar.cc/150?img=15',
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    });
  }
}

class FeedPostCard extends StatefulWidget {
  final FeedPost post;
  final List<FeedComment> comments;
  final List<FeedLike> likes;
  final VoidCallback onLikePressed;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.comments,
    required this.likes,
    required this.onLikePressed,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  bool _isExpanded = false;
  bool _isTranslated = false;
  static const int _maxCaptionLength = 100;

  // Dummy translation - replace with actual API later
  String get _dummyTranslation =>
      'これは投稿内容のダミー翻訳です。将来的には、実際の翻訳APIを使用して、さまざまな言語でリアルタイム翻訳を提供する予定です';

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return AppLocalizations.of(context)!.daysAgoCount(difference.inDays);
    } else if (difference.inHours > 0) {
      return AppLocalizations.of(context)!.hoursAgoCount(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return AppLocalizations.of(
        context,
      )!.minutesAgoCount(difference.inMinutes);
    } else {
      return AppLocalizations.of(context)!.now;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[300] : Colors.grey[700];
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
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

          // Text Content with expandable feature
          _buildExpandableCaption(textColor, subtextColor),
          const SizedBox(height: 12),

          // Image Grid with max 4 images
          _buildImageGrid(isDark),

          // Stats Row with working like button
          _buildStatsRow(iconColor),
          const SizedBox(height: 12),

          // Comments Preview
          _buildCommentsPreview(subtextColor, iconColor),
        ],
      ),
    );
  }

  Widget _buildExpandableCaption(Color textColor, Color? subtextColor) {
    final content = _isTranslated ? _dummyTranslation : widget.post.content;
    final shouldTruncate = content.length > _maxCaptionLength;
    final displayText = _isExpanded || !shouldTruncate
        ? content
        : '${content.substring(0, _maxCaptionLength)}...';

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
          displayText,
          style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
        ),
        if (shouldTruncate) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              if (_isExpanded) {
                // Navigate to details if already expanded
                _navigateToDetails();
              } else {
                setState(() {
                  _isExpanded = true;
                });
              }
            },
            child: Text(
              _isExpanded
                  ? AppLocalizations.of(context)!.seeLess
                  : AppLocalizations.of(context)!.seeMore,
              style: const TextStyle(
                color: Color(0xFF7d54fb),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageGrid(bool isDark) {
    if (widget.post.images.isEmpty) return const SizedBox.shrink();

    final displayImages = widget.post.images.take(4).toList();
    final hasMoreImages = widget.post.images.length > 4;

    return Column(
      children: [
        GestureDetector(
          onTap: _navigateToDetails,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: displayImages.length == 1 ? 1 : 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: displayImages.length == 1 ? 16 / 9 : 1,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayImages.length,
            itemBuilder: (context, index) {
              final isLastImage = index == displayImages.length - 1;
              final showOverlay = hasMoreImages && isLastImage;

              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(displayImages[index], fit: BoxFit.cover),
                      if (showOverlay)
                        Container(
                          color: Colors.black.withOpacity(0.6),
                          child: Center(
                            child: Text(
                              '+${widget.post.images.length - 4}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildStatsRow(Color? iconColor) {
    return Row(
      children: [
        // Like button
        GestureDetector(
          onTap: widget.onLikePressed,
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
        GestureDetector(
          onTap: _navigateToDetails,
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: iconColor, size: 20),
              const SizedBox(width: 4),
              Text(
                '${widget.comments.length}',
                style: TextStyle(color: iconColor, fontSize: 14),
              ),
            ],
          ),
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

  Widget _buildCommentsPreview(Color? subtextColor, Color? iconColor) {
    if (widget.comments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show first few comments dynamically
        ...widget.comments
            .take(3)
            .map(
              (comment) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${comment.userName}: ',
                        style: const TextStyle(
                          color: Color(0xFF7d54fb),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: comment.comment,
                        style: TextStyle(color: subtextColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _navigateToDetails,
          child: Text(
            AppLocalizations.of(
              context,
            )!.viewAllComments(widget.comments.length),
            style: const TextStyle(color: Color(0xFF7d54fb), fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _navigateToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedDetailPage(
          post: widget.post,
          comments: widget.comments
              .where((c) => c.feedId == widget.post.feedId)
              .toList(),
          likes: widget.likes,
        ),
      ),
    );
  }
}
