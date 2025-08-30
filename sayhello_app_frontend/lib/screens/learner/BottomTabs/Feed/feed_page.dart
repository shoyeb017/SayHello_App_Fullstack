import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'feed_detail_page.dart';
import 'create_post_page.dart';
import '../../Notifications/notifications.dart';
import '../Connect/others_profile_page.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../providers/feed_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/models.dart';
import '../../../../services/azure_translator_service.dart';

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
      // Load both tabs simultaneously for faster loading
      feedProvider.loadAllFeeds(userId);
    }
  }

  void _showMyPosts() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'My Posts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Expanded(
                    child: Consumer<FeedProvider>(
                      builder: (context, provider, child) {
                        // Show a skeleton loading UI immediately
                        return FutureBuilder<List<FeedWithUser>>(
                          future: provider.getUserOwnPosts(
                            authProvider.currentUser!.id,
                          ),
                          builder: (context, snapshot) {
                            final myPosts = snapshot.data ?? [];

                            // Show skeleton loading while waiting for data
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                myPosts.isEmpty) {
                              return ListView.builder(
                                controller: scrollController,
                                itemCount: 3, // Show 3 skeleton cards
                                itemBuilder: (context, index) {
                                  return _buildSkeletonPostCard();
                                },
                              );
                            }

                            if (myPosts.isEmpty &&
                                snapshot.connectionState ==
                                    ConnectionState.done) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.post_add,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No posts yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Share your first post!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: scrollController,
                              itemCount: myPosts.length,
                              itemBuilder: (context, index) {
                                final feedWithUser = myPosts[index];
                                final feed = feedWithUser.feed;
                                final comments =
                                    provider.feedComments[feed.id] ?? [];
                                final likes = provider.feedLikes[feed.id] ?? [];

                                return FeedPostCard(
                                  feedWithUser: feedWithUser,
                                  comments: comments,
                                  likes: likes,
                                  isLiked:
                                      provider.likedPosts[feed.id] ?? false,
                                  onLikePressed: () => _handleLike(feed.id),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildSkeletonPostCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // User info skeleton
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Text content skeleton
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 16,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),

          // Stats row skeleton
          Row(
            children: [
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Spacer(),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

              // 📝 MY POSTS ICON - This shows the current user's posted feeds
              IconButton(
                icon: Icon(
                  Icons.person_outline,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => _showMyPosts(),
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.feed,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    // Small loading indicator for follow operations
                    Consumer<FeedProvider>(
                      builder: (context, feedProvider, child) {
                        if (feedProvider.isFollowOperationInProgress) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
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

              // 📝 CREATE POST ICON - This is the create post button in the app bar
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: isDark ? Colors.white : Colors.black,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreatePostPage()),
                  );
                },
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
              ), // Recent - users NOT being followed
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
                  ? 'No posts from unfollowed users'
                  : 'No posts from followed users',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              isRecentTab
                  ? 'Posts from users you don\'t follow will appear here'
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
        // Add caching and optimization for better performance
        cacheExtent: 1000, // Cache 1000 pixels ahead
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        addSemanticIndexes: true,
        itemBuilder: (context, index) {
          final feedWithUser = feeds[index];
          final feed = feedWithUser.feed;
          final comments = feedProvider.feedComments[feed.id] ?? [];
          final likes = feedProvider.feedLikes[feed.id] ?? [];

          return RepaintBoundary(
            key: ValueKey(feed.id), // Add key for better widget reuse
            child: FeedPostCard(
              feedWithUser: feedWithUser,
              comments: comments,
              likes: likes,
              isLiked: feedProvider.likedPosts[feed.id] ?? false,
              onLikePressed: () => _handleLike(feed.id),
            ),
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
  final List<FeedCommentWithUser> comments;
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

class _FeedPostCardState extends State<FeedPostCard>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _isExpanded = false;
  bool _isTranslated = false;
  bool _isFollowing = false;
  bool _isLoadingFollow = false;
  bool _isTranslating = false;
  String? _translatedText;
  String? _detectedLanguage;
  static const int _maxCaptionLength = 100;

  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  bool get wantKeepAlive => true; // Keep widget alive to prevent rebuilds

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _checkFollowStatus();
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkFollowStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);

    if (authProvider.currentUser?.id != null &&
        widget.feedWithUser.feed.learnerId != authProvider.currentUser!.id) {
      final isFollowing = await feedProvider.isFollowing(
        authProvider.currentUser!.id,
        widget.feedWithUser.feed.learnerId,
      );
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);

    if (authProvider.currentUser?.id == null) return;

    setState(() {
      _isLoadingFollow = true;
    });

    try {
      bool success;
      if (_isFollowing) {
        success = await feedProvider.unfollowUser(
          authProvider.currentUser!.id,
          widget.feedWithUser.feed.learnerId,
        );
      } else {
        success = await feedProvider.followUser(
          authProvider.currentUser!.id,
          widget.feedWithUser.feed.learnerId,
        );
      }

      if (success && mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
        });

        // The provider will automatically refresh both tabs for real-time updates
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
        });
      }
    }
  }

  Future<void> _translateText() async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final originalText = widget.feedWithUser.feed.contentText;

      if (_isTranslated && _translatedText != null) {
        // If already translated, toggle back to original
        setState(() {
          _isTranslated = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Showing original text'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Get user's native language from their profile instead of device locale
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      String targetLanguage = 'English'; // Default fallback

      // Debug: Print detailed user information
      print('FeedPage: Current user details:');
      print('  - User is null: ${currentUser == null}');
      print('  - User type: ${currentUser.runtimeType}');
      if (currentUser != null) {
        print('  - User ID: ${currentUser.id}');
        if (currentUser is Learner) {
          print('  - User email: ${currentUser.email}');
          print('  - Native language: ${currentUser.nativeLanguage}');
          print('  - Learning language: ${currentUser.learningLanguage}');
        }
      }

      if (currentUser != null && currentUser is Learner) {
        final nativeLang = currentUser.nativeLanguage;
        targetLanguage = _getProperLanguageName(nativeLang);
        print('FeedPage: User native language: $nativeLang -> $targetLanguage');
      } else {
        print(
          'FeedPage: User is null or not Learner type, using default English',
        );
      }

      // Detect source language if not already detected
      if (_detectedLanguage == null) {
        print(
          'FeedPage: Detecting language for text: ${originalText.substring(0, originalText.length > 50 ? 50 : originalText.length)}...',
        );
        _detectedLanguage = await AzureTranslatorService.detectLanguage(
          originalText,
        );
        print('FeedPage: Detected language: $_detectedLanguage');
      }

      final sourceLanguage = _detectedLanguage ?? 'Unknown';

      // Check if source and target languages are the same
      if (sourceLanguage.toLowerCase() == targetLanguage.toLowerCase()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Text is already in $targetLanguage'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Always translate - handles mixed language content and provides consistent experience
      print('FeedPage: Translating from $sourceLanguage to $targetLanguage');

      // Perform translation
      final translatedText = await AzureTranslatorService.translateText(
        text: originalText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      print(
        'FeedPage: Translation result: ${translatedText.substring(0, translatedText.length > 50 ? 50 : translatedText.length)}...',
      );

      if (mounted &&
          translatedText.isNotEmpty &&
          translatedText != originalText) {
        setState(() {
          _translatedText = translatedText;
          _isTranslated = true;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translated to $targetLanguage'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        // Translation failed or returned same text
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation not needed or failed'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('FeedPage: Translation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
      }
    }
  }

  // Convert language names to proper format for Azure Translator Service
  String _getProperLanguageName(String languageName) {
    switch (languageName.toLowerCase()) {
      case 'english':
        return 'English';
      case 'spanish':
        return 'Spanish';
      case 'french':
        return 'French';
      case 'german':
        return 'German';
      case 'italian':
        return 'Italian';
      case 'portuguese':
        return 'Portuguese';
      case 'russian':
        return 'Russian';
      case 'japanese':
        return 'Japanese';
      case 'korean':
        return 'Korean';
      case 'chinese':
        return 'Chinese';
      case 'arabic':
        return 'Arabic';
      case 'hindi':
        return 'Hindi';
      case 'bengali':
        return 'Bengali';
      case 'dutch':
        return 'Dutch';
      case 'swedish':
        return 'Swedish';
      case 'norwegian':
        return 'Norwegian';
      case 'danish':
        return 'Danish';
      case 'finnish':
        return 'Finnish';
      case 'turkish':
        return 'Turkish';
      case 'polish':
        return 'Polish';
      case 'czech':
        return 'Czech';
      case 'hungarian':
        return 'Hungarian';
      case 'romanian':
        return 'Romanian';
      case 'bulgarian':
        return 'Bulgarian';
      case 'croatian':
        return 'Croatian';
      case 'serbian':
        return 'Serbian';
      case 'slovak':
        return 'Slovak';
      case 'slovenian':
        return 'Slovenian';
      case 'greek':
        return 'Greek';
      case 'hebrew':
        return 'Hebrew';
      case 'thai':
        return 'Thai';
      case 'vietnamese':
        return 'Vietnamese';
      case 'indonesian':
        return 'Indonesian';
      case 'malay':
        return 'Malay';
      case 'filipino':
        return 'Filipino';
      case 'tagalog':
        return 'Filipino';
      default:
        // Capitalize first letter as fallback
        return languageName.isNotEmpty
            ? '${languageName[0].toUpperCase()}${languageName.substring(1).toLowerCase()}'
            : 'English';
    }
  }

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
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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
              GestureDetector(
                onTap: () {
                  // Only navigate if it's not the current user's post
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  if (widget.feedWithUser.feed.learnerId !=
                      authProvider.currentUser?.id) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OthersProfilePage(
                          userId: widget.feedWithUser.feed.learnerId,
                          name: widget.feedWithUser.userName,
                          avatar: widget.feedWithUser.userAvatarUrl ?? '',
                          nativeLanguage:
                              'EN', // Placeholder - would come from user data
                          learningLanguage:
                              'JP', // Placeholder - would come from user data
                        ),
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                  backgroundImage: widget.feedWithUser.userAvatarUrl != null
                      ? NetworkImage(widget.feedWithUser.userAvatarUrl!)
                      : null,
                  onBackgroundImageError:
                      widget.feedWithUser.userAvatarUrl != null
                      ? (error, stackTrace) {
                          // Handle avatar loading errors gracefully
                        }
                      : null,
                  child: widget.feedWithUser.userAvatarUrl == null
                      ? Text(
                          widget.feedWithUser.userName
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Only navigate if it's not the current user's post
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            if (widget.feedWithUser.feed.learnerId !=
                                authProvider.currentUser?.id) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OthersProfilePage(
                                    userId: widget.feedWithUser.feed.learnerId,
                                    name: widget.feedWithUser.userName,
                                    avatar:
                                        widget.feedWithUser.userAvatarUrl ?? '',
                                    nativeLanguage:
                                        'EN', // Placeholder - would come from user data
                                    learningLanguage:
                                        'JP', // Placeholder - would come from user data
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            widget.feedWithUser.userName,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
              // Follow button (only show if not own post)
              if (widget.feedWithUser.feed.learnerId !=
                  Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).currentUser?.id)
                GestureDetector(
                  onTap: _isLoadingFollow ? null : _toggleFollow,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isFollowing
                          ? (isDark
                                ? Colors.purple.shade800
                                : Colors.purple.shade600)
                          : (isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _isLoadingFollow
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          )
                        : Text(
                            _isFollowing
                                ? AppLocalizations.of(context)!.following
                                : AppLocalizations.of(context)!.follow,
                            style: TextStyle(
                              color: _isFollowing
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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
    final content = _isTranslated && _translatedText != null
        ? _translatedText!
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
                  _detectedLanguage != null
                      ? '${AppLocalizations.of(context)!.translated} from $_detectedLanguage'
                      : AppLocalizations.of(context)!.translated,
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
                      Image.network(
                        displayImages[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: const Color(0xFF7d54fb),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Icon(
                              Icons.broken_image,
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                              size: 32,
                            ),
                          );
                        },
                        cacheWidth:
                            400, // Limit image resolution to prevent memory issues
                        cacheHeight: 400,
                      ),
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

  void _handleLikeWithAnimation() {
    // Add haptic feedback for better user experience
    HapticFeedback.lightImpact();

    // Trigger animation
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    // Call the original like handler
    widget.onLikePressed();
  }

  Widget _buildStatsRow(Color? iconColor) {
    final feed = widget.feedWithUser.feed;

    return Row(
      children: [
        // Like button
        GestureDetector(
          onTap: _handleLikeWithAnimation,
          child: AnimatedBuilder(
            animation: _likeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _likeAnimation.value,
                child: Row(
                  children: [
                    Icon(
                      widget.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: widget.isLiked
                          ? const Color(0xFF7d54fb)
                          : iconColor,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${feed.likesCount}',
                      style: TextStyle(color: iconColor, fontSize: 14),
                    ),
                  ],
                ),
              );
            },
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
          onTap: _isTranslating ? null : _translateText,
          child: _isTranslating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF7d54fb),
                    ),
                  ),
                )
              : Icon(
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
                            '${comment.userName}: ', // Now using actual user name
                        style: const TextStyle(
                          color: Color(0xFF7d54fb),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: comment.comment.contentText,
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
