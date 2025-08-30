import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/models.dart';
import '../../../../providers/feed_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/azure_translator_service.dart';

class FeedDetailPage extends StatefulWidget {
  final FeedWithUser feedWithUser;
  final List<FeedCommentWithUser> comments;
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
                                    commentWithUser: currentComments[index],
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

class _DetailedPostCardState extends State<DetailedPostCard>
    with TickerProviderStateMixin {
  bool _isTranslated = false;
  bool _isTranslating = false;
  String? _translatedText;
  String? _detectedLanguage;

  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

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
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLikeWithAnimation() {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Trigger animation
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    // Call the original like handler
    widget.onLikePressed();
  }

  Future<void> _translatePost() async {
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
        return;
      }

      // Get user's native language from their profile
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      String targetLanguage = 'English'; // Default fallback

      if (currentUser != null && currentUser is Learner) {
        final nativeLang = currentUser.nativeLanguage;
        targetLanguage = _getProperLanguageName(nativeLang);
      }

      // Detect source language if not already detected
      if (_detectedLanguage == null) {
        _detectedLanguage = await AzureTranslatorService.detectLanguage(
          originalText,
        );
      }

      final sourceLanguage = _detectedLanguage ?? 'Unknown';

      // Check if source and target languages are the same
      if (sourceLanguage.toLowerCase() == targetLanguage.toLowerCase()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Post is already in $targetLanguage'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Perform translation
      final translatedText = await AzureTranslatorService.translateText(
        text: originalText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
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
            content: Text('Post translated to $targetLanguage'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('DetailedPostCard: Translation error: $e');
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

  // Helper methods to get user information
  Future<String?> _getUserAvatar(String userId) async {
    try {
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      final userInfo = await feedProvider.getUserInfo(userId);
      return userInfo?['profile_image'];
    } catch (e) {
      print('Error fetching user avatar: $e');
      return null;
    }
  }

  Future<String> _getUserName(String userId) async {
    try {
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      final userInfo = await feedProvider.getUserInfo(userId);
      return userInfo?['name'] ?? 'Unknown User';
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Unknown User';
    }
  }

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
    final content = _isTranslated && _translatedText != null
        ? _translatedText!
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
                  _detectedLanguage != null
                      ? 'Translated from $_detectedLanguage'
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
          onTap: _isTranslating ? null : _translatePost,
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

  Widget _buildLikedUsersRow(Color? iconColor) {
    final feed = widget.feedWithUser.feed;

    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        // Load likes if not already loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          feedProvider.loadFeedLikes(feed.id);
        });

        // Get the most up-to-date likes from the provider
        final currentLikes = feedProvider.feedLikes[feed.id] ?? widget.likes;
        final likesData = currentLikes.take(3).toList();

        // Debug information
        print('🔍 LikedUsersRow: Feed ID: ${feed.id}');
        print('🔍 LikedUsersRow: Current likes count: ${currentLikes.length}');
        print(
          '🔍 LikedUsersRow: Likes data: ${likesData.map((like) => 'User: ${like.learnerId}, ID: ${like.id}, Created: ${like.createdAt}').join('\n')}',
        );

        return Row(
          children: [
            // Liked users avatars - show up to 3 with real user data
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
                    // First user avatar
                    if (likesData.isNotEmpty)
                      FutureBuilder<String?>(
                        future: _getUserAvatar(likesData[0].learnerId),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print(
                              '❌ Avatar error for ${likesData[0].learnerId}: ${snapshot.error}',
                            );
                          }
                          return CircleAvatar(
                            radius: 12,
                            backgroundImage: snapshot.data != null
                                ? NetworkImage(snapshot.data!)
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: snapshot.data == null
                                ? FutureBuilder<String>(
                                    future: _getUserName(
                                      likesData[0].learnerId,
                                    ),
                                    builder: (context, nameSnapshot) {
                                      if (nameSnapshot.hasError) {
                                        print(
                                          '❌ Name error for ${likesData[0].learnerId}: ${nameSnapshot.error}',
                                        );
                                      }
                                      final name = nameSnapshot.data ?? 'U';
                                      print(
                                        '✅ User name fetched: $name for ${likesData[0].learnerId}',
                                      );
                                      return Text(
                                        name.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    },
                                  )
                                : null,
                          );
                        },
                      ),
                    // Second user avatar
                    if (likesData.length > 1)
                      Positioned(
                        left: 16,
                        child: FutureBuilder<String?>(
                          future: _getUserAvatar(likesData[1].learnerId),
                          builder: (context, snapshot) {
                            return CircleAvatar(
                              radius: 12,
                              backgroundImage: snapshot.data != null
                                  ? NetworkImage(snapshot.data!)
                                  : null,
                              backgroundColor: Colors.grey[300],
                              child: snapshot.data == null
                                  ? FutureBuilder<String>(
                                      future: _getUserName(
                                        likesData[1].learnerId,
                                      ),
                                      builder: (context, nameSnapshot) {
                                        final name = nameSnapshot.data ?? 'U';
                                        return Text(
                                          name.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        );
                                      },
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                    // Third user avatar
                    if (likesData.length > 2)
                      Positioned(
                        left: 32,
                        child: FutureBuilder<String?>(
                          future: _getUserAvatar(likesData[2].learnerId),
                          builder: (context, snapshot) {
                            return CircleAvatar(
                              radius: 12,
                              backgroundImage: snapshot.data != null
                                  ? NetworkImage(snapshot.data!)
                                  : null,
                              backgroundColor: Colors.grey[300],
                              child: snapshot.data == null
                                  ? FutureBuilder<String>(
                                      future: _getUserName(
                                        likesData[2].learnerId,
                                      ),
                                      builder: (context, nameSnapshot) {
                                        final name = nameSnapshot.data ?? 'U';
                                        return Text(
                                          name.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        );
                                      },
                                    )
                                  : null,
                            );
                          },
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
      },
    );
  }

  void _showLikedUsersList() {
    // Get current likes from provider or widget
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final currentLikes =
        feedProvider.feedLikes[widget.feedWithUser.feed.id] ?? widget.likes;

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
            // Real likes list with user information
            if (currentLikes.isEmpty)
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(AppLocalizations.of(context)!.noLikesYet),
              )
            else
              ...currentLikes
                  .map(
                    (like) => FutureBuilder<Map<String, dynamic>?>(
                      future: _getUserInfo(like.learnerId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            title: Text('Loading...'),
                            trailing: Text(_formatTimeAgo(like.createdAt)),
                          );
                        }

                        final userInfo = snapshot.data;
                        final userName = userInfo?['name'] ?? 'Unknown User';
                        final userAvatar = userInfo?['profile_image'];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: userAvatar != null
                                ? NetworkImage(userAvatar)
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: userAvatar == null
                                ? Text(
                                    userName.substring(0, 1).toUpperCase(),
                                    style: TextStyle(color: Colors.grey[600]),
                                  )
                                : null,
                          ),
                          title: Text(userName),
                          trailing: Text(_formatTimeAgo(like.createdAt)),
                        );
                      },
                    ),
                  )
                  .toList(),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _getUserInfo(String userId) async {
    try {
      print('🔍 _getUserInfo: Fetching user info for ID: $userId');
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      final result = await feedProvider.getUserInfo(userId);
      print('✅ _getUserInfo: Result for $userId: $result');
      return result;
    } catch (e) {
      print('❌ _getUserInfo: Error fetching user info for $userId: $e');
      return null;
    }
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
  final FeedCommentWithUser commentWithUser;
  final int index;

  const CommentCard({
    super.key,
    required this.commentWithUser,
    required this.index,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _isTranslated = false;
  bool _isTranslating = false;
  String? _translatedText;
  String? _detectedLanguage;

  Future<void> _translateComment() async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final originalText = widget.commentWithUser.comment.contentText;

      if (_isTranslated && _translatedText != null) {
        // If already translated, toggle back to original
        setState(() {
          _isTranslated = false;
        });
        return;
      }

      // Get user's native language from their profile
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      String targetLanguage = 'English'; // Default fallback

      if (currentUser != null && currentUser is Learner) {
        final nativeLang = currentUser.nativeLanguage;
        targetLanguage = _getProperLanguageName(nativeLang);
      }

      // Detect source language if not already detected
      if (_detectedLanguage == null) {
        _detectedLanguage = await AzureTranslatorService.detectLanguage(
          originalText,
        );
      }

      final sourceLanguage = _detectedLanguage ?? 'Unknown';

      // Check if source and target languages are the same
      if (sourceLanguage.toLowerCase() == targetLanguage.toLowerCase()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Comment is already in $targetLanguage'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Perform translation
      final translatedText = await AzureTranslatorService.translateText(
        text: originalText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
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
            content: Text('Comment translated to $targetLanguage'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('CommentCard: Translation error: $e');
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
            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
            backgroundImage: widget.commentWithUser.userAvatarUrl != null
                ? NetworkImage(widget.commentWithUser.userAvatarUrl!)
                : null,
            child: widget.commentWithUser.userAvatarUrl == null
                ? Text(
                    widget.commentWithUser.userName
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
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
                      widget
                          .commentWithUser
                          .userName, // Now showing real username
                      style: const TextStyle(
                        color: Color(0xFF7d54fb),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(widget.commentWithUser.comment.createdAt),
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
                      _isTranslated && _translatedText != null
                          ? _translatedText!
                          : widget.commentWithUser.comment.contentText,
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
                      onTap: _isTranslating ? null : _translateComment,
                      child: _isTranslating
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF7d54fb),
                                ),
                              ),
                            )
                          : Icon(
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
