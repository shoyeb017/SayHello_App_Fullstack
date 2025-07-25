import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../Feed/feed_page.dart';
import '../../Chat/chat.dart';

class OthersProfilePage extends StatefulWidget {
  final String userId;
  final String name;
  final String avatar;
  final String nativeLanguage;
  final String learningLanguage;

  const OthersProfilePage({
    Key? key,
    required this.userId,
    required this.name,
    required this.avatar,
    required this.nativeLanguage,
    required this.learningLanguage,
  }) : super(key: key);

  @override
  State<OthersProfilePage> createState() => _OthersProfilePageState();
}

class _OthersProfilePageState extends State<OthersProfilePage>
    with TickerProviderStateMixin {
  bool isFollowing = false;
  bool isBioExpanded = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock user data
  final String bio =
      "Hello! I'm learning English and love anime, manga, and traveling. Let's practice languages together! 🌟 よろしくお願いします！I enjoy meeting new people from different cultures and sharing experiences.";
  final String location = "Japan";
  final String currentTime = "9:06 PM";
  final int age = 24;
  final String gender = "Female";
  final String username = "yukiko_san";
  final int joinedDays = 32;
  final int followingCount = 8;
  final int followersCount = 16;

  final List<String> sharedInterests = ["漫画", "Anime"];
  final List<String> interests = [
    "Travel",
    "旅行",
    "Music",
    "音楽",
    "Photography",
    "写真",
    "Cooking",
    "料理",
    "Reading",
    "読書",
    "Gaming",
    "ゲーム",
  ];

  // Mock feed posts for this user
  List<FeedPost> get userPosts => [
    FeedPost(
      feedId: 'user_feed_001',
      userId: widget.userId,
      userName: widget.name,
      userAvatar: widget.avatar,
      nativeLanguage: widget.nativeLanguage,
      learningLanguage: widget.learningLanguage,
      content:
          'Beautiful sunset in Tokyo today! 🌅 Learning English through photography captions.',
      images: ['https://picsum.photos/400/300?random=101'],
      likeCount: 15,
      commentCount: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isLiked: false,
      likedByAvatars: [
        'https://i.pravatar.cc/150?img=20',
        'https://i.pravatar.cc/150?img=21',
        'https://i.pravatar.cc/150?img=22',
      ],
    ),
    FeedPost(
      feedId: 'user_feed_002',
      userId: widget.userId,
      userName: widget.name,
      userAvatar: widget.avatar,
      nativeLanguage: widget.nativeLanguage,
      learningLanguage: widget.learningLanguage,
      content:
          'Just finished reading a great manga! Anyone have recommendations for English manga? 📚',
      images: [],
      likeCount: 8,
      commentCount: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isLiked: true,
      likedByAvatars: [
        'https://i.pravatar.cc/150?img=23',
        'https://i.pravatar.cc/150?img=24',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF7A54FF);

    return Scaffold(
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            clipBehavior: Clip.none,
            slivers: [
              // Cover image and profile content together
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Cover image section
                    Container(
                      width: double.infinity,
                      height: 200, // Reduced height
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [primaryColor.withOpacity(0.8), primaryColor],
                        ),
                        image: DecorationImage(
                          image: NetworkImage('https://picsum.photos/400/200'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            primaryColor.withOpacity(0.6),
                            BlendMode.overlay,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Back button positioned over cover image
                          Positioned(
                            top: 50,
                            left: 16,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),

                          // More button positioned over cover image
                          Positioned(
                            top: 50,
                            right: 16,
                            child: IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {},
                            ),
                          ),

                          // Location and time
                          Positioned(
                            top: 80, // Adjusted for smaller cover height
                            right: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.public,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "$location $currentTime",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Profile content with overlapping profile picture
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Content with minimal padding
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            10,
                            16,
                            100,
                          ), // Further reduced top padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Basic info
                              _buildBasicInfo(isDark, primaryColor),
                              SizedBox(height: 16),

                              // Bio section
                              _buildBioSection(isDark),
                              SizedBox(height: 20),

                              // Tabs
                              _buildTabSection(isDark, primaryColor),
                            ],
                          ),
                        ),

                        // Profile picture positioned to overlap with cover image
                        Positioned(
                          top: -45, // Move it up to overlap with cover image
                          left: 16,
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.white,
                            child: CircleAvatar(
                              radius: 42,
                              backgroundImage: NetworkImage(widget.avatar),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bottom sticky buttons
          _buildBottomButtons(isDark, primaryColor),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Follow button positioned above name
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isFollowing = !isFollowing;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isFollowing ? primaryColor : Colors.grey[400],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.thumb_up, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),

        // Name with gender/age beside it
        Row(
          children: [
            Text(
              widget.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFFEEDF7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    gender == "Female" ? Icons.female : Icons.male,
                    color: Color(0xFFD619A8),
                    size: 18,
                  ),
                  SizedBox(width: 2),
                  Text(
                    age.toString(),
                    style: TextStyle(
                      color: Color(0xFFD619A8),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 4),

        // Username
        Text(username, style: TextStyle(color: Colors.grey, fontSize: 14)),

        SizedBox(height: 12),

        // Language chips
        Row(
          children: [
            _buildLanguageChip(
              "🇯🇵",
              widget.nativeLanguage,
              Colors.green,
              isDark,
            ),
            SizedBox(width: 8),
            _buildLanguageChip(
              "🇺🇸",
              widget.learningLanguage,
              primaryColor,
              isDark,
            ),
          ],
        ),

        SizedBox(height: 16),

        // Stats row
        Row(
          children: [
            _buildStatItem(
              "${joinedDays}d",
              AppLocalizations.of(context)!.joined,
              isDark,
            ),
            _buildStatDivider(isDark),
            _buildStatItem(
              followingCount.toString(),
              AppLocalizations.of(context)!.following,
              isDark,
            ),
            _buildStatDivider(isDark),
            _buildStatItem(followersCount.toString(), "Followers", isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageChip(
    String flag,
    String language,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: TextStyle(fontSize: 14)),
          SizedBox(width: 4),
          Text(
            language,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      height: 20,
      width: 1,
      color: isDark ? Colors.grey[700] : Colors.grey[300],
      margin: EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildBioSection(bool isDark) {
    final maxLines = isBioExpanded ? null : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bio,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            height: 1.4,
          ),
          maxLines: maxLines,
          overflow: isBioExpanded ? null : TextOverflow.ellipsis,
        ),
        if (bio.length > 100)
          GestureDetector(
            onTap: () {
              setState(() {
                isBioExpanded = !isBioExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                isBioExpanded ? "Show less" : "more",
                style: TextStyle(
                  color: Color(0xFF7A54FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabSection(bool isDark, Color primaryColor) {
    return Column(
      children: [
        // Tab bar
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.profile),
              Tab(text: "Feed"),
            ],
          ),
        ),

        // Tab content without fixed height
        _tabController.index == 0
            ? _buildProfileTab(isDark, primaryColor)
            : _buildFeedTab(isDark),
      ],
    );
  }

  Widget _buildProfileTab(bool isDark, Color primaryColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shared Interests
          _buildSharedInterestsSection(isDark, primaryColor),
          SizedBox(height: 20),

          // Interests & Hobbies
          _buildInterestsSection(isDark),
        ],
      ),
    );
  }

  Widget _buildSharedInterestsSection(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Shared Interests",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sharedInterests.map((interest) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                interest,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Interests & Hobbies",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: interests.map((interest) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                interest,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeedTab(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: userPosts.map((post) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: FeedPostCard(
              post: post,
              comments: [], // Empty comments for profile view
              likes: [], // Empty likes for profile view
              onLikePressed: () {
                // Handle like functionality
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomButtons(bool isDark, Color primaryColor) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            // Follow button (now outlined style)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isFollowing = !isFollowing;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? primaryColor
                      : Color(0xFFEFECFF),
                  foregroundColor: isFollowing ? Colors.white : primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  isFollowing
                      ? AppLocalizations.of(context)!.following
                      : "Follow",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(width: 12),

            // Chat button (now solid style)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to chat page
                  final chatUser = ChatUser(
                    id: widget.userId,
                    name: widget.name,
                    avatarUrl: widget.avatar,
                    country: location,
                    flag: "🇯🇵",
                    age: age,
                    gender: gender,
                    isOnline: true,
                    lastSeen: DateTime.now().subtract(Duration(minutes: 5)),
                    interests: interests,
                    nativeLanguage: widget.nativeLanguage,
                    learningLanguage: widget.learningLanguage,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(user: chatUser),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.chat,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
