import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'feed_detail_page.dart';
import '../../Notifications/notifications.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../providers/feed_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/models.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update tab button colors
    });

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final userId = authProvider.currentUser!.id;
      // Load both tabs' data
      feedProvider.loadRecentFeeds(userId);
      feedProvider.loadForYouFeeds(userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildFeedContent(
                feedProvider,
                isRecentTab: true,
              ), // Recent - followed users + own posts
              _buildFeedContent(
                feedProvider,
                isRecentTab: false,
              ), // For You - only followed users' posts
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeedContent(
    FeedProvider feedProvider, {
    required bool isRecentTab,
  }) {
    // Get appropriate feeds based on tab
    final feeds = isRecentTab
        ? feedProvider.recentFeeds
        : feedProvider.forYouFeeds;

    if (feedProvider.isLoading && feeds.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7758f3)),
      );
    }

    if (feedProvider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load feeds',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              feedProvider.error ?? 'Unknown error',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadInitialData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7758f3),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (feeds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feed_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isRecentTab
                  ? 'No recent posts to show'
                  : 'No posts from followed users',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              isRecentTab
                  ? 'Follow some users to see their posts here'
                  : 'Posts from users you follow will appear here',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadInitialData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: feeds.length,
        itemBuilder: (context, index) {
          final feedWithUser = feeds[index];
          final feed = feedWithUser.feed;
          final comments = feedProvider.feedComments[feed.id] ?? [];
          final likes = feedProvider.feedLikes[feed.id] ?? [];

          return FeedPostCard(
            feedWithUser: feedWithUser,
            comments: comments,
            likes: likes,
            isLiked: feedProvider.likedPosts[feed.id] ?? false,
            onLikePressed: () => _handleLike(feed.id),
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
}

class FeedPostCard extends StatefulWidget {
  final FeedWithUser feedWithUser;
  final List<FeedComment> comments;
  final List<FeedLike> likes;
  final bool isLiked;
  final VoidCallback onLikePressed;

  const FeedPostCard({
    super.key,
    required this.feedWithUser,
    required this.comments,
    required this.likes,
    required this.isLiked,
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

    final feed = widget.feedWithUser.feed;

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
                    // Language badges (placeholder for now)
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
    final content = _isTranslated
        ? _dummyTranslation
        : widget.feedWithUser.feed.contentText;
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
    final images = widget.feedWithUser.feed.imageUrls;
    if (images.isEmpty) return const SizedBox.shrink();

    final displayImages = images.take(4).toList();
    final hasMoreImages = images.length > 4;

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
                              '+${images.length - 4}',
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
        GestureDetector(
          onTap: _navigateToDetails,
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: iconColor, size: 20),
              const SizedBox(width: 4),
              Text(
                '${feed.commentsCount}',
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
                        text:
                            'User: ', // Placeholder - would need user name from comment
                        style: const TextStyle(
                          color: Color(0xFF7d54fb),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: comment.contentText,
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
          feedWithUser: widget.feedWithUser,
          comments: widget.comments,
          likes: widget.likes,
        ),
      ),
    );
  }
}
