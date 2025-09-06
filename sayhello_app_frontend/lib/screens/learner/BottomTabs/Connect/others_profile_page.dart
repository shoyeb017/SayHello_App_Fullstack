import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../Chat/chat.dart';
import '../../../../providers/learner_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/follower_provider.dart';
import '../../../../models/learner.dart';
import '../../../../models/feed.dart';
import '../../../../data/feed_data.dart';

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

  // Backend state
  Learner? _learnerData;
  bool _isLoading = false;
  bool _isFollowLoading = false;
  String? _error;
  int _followerCount = 0;
  int _followingCount = 0;

  // Feed state
  List<Feed> _userFeeds = [];
  bool _isFeedLoading = false;
  String? _feedError;
  final FeedRepository _feedRepository = FeedRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadLearnerData(); // This will call _loadFollowStatus after data is loaded
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load learner data from backend
  Future<void> _loadLearnerData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final learnerProvider = Provider.of<LearnerProvider>(
        context,
        listen: false,
      );

      // Try to get learner by ID first (widget.userId should be the database ID)
      Learner? learner = await learnerProvider.getLearnerByIdSilent(
        widget.userId,
      );

      // If that fails, try by email/username as fallback
      if (learner == null) {
        learner = await learnerProvider.getLearnerByEmailSilent(widget.userId);
      }
      if (learner == null) {
        learner = await learnerProvider.getLearnerByUsernameSilent(
          widget.userId,
        );
      }

      if (learner != null) {
        _learnerData = learner;

        // Load follow counts
        _followerCount = await learnerProvider.getFollowerCount(learner.id);
        _followingCount = await learnerProvider.getFollowingCount(learner.id);

        // Load follow status after setting _learnerData
        await _loadFollowStatus();

        // Load user's feed posts
        await _loadUserFeeds();
      } else {
        throw Exception('User not found with ID: ${widget.userId}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load follow status from backend
  Future<void> _loadFollowStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final followerProvider = Provider.of<FollowerProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null && _learnerData != null) {
        final currentUser = authProvider.currentUser as Learner;

        // Force refresh follow status to ensure we have the latest data
        await followerProvider.forceRefreshFollowStatus(
          currentUser.id,
          _learnerData!.id,
        );

        // Debug: Check for any inconsistencies
        await followerProvider.debugFollowStatus(
          currentUser.id,
          _learnerData!.id,
        );

        setState(() {
          isFollowing = followerProvider.isFollowingUser(_learnerData!.id);
        });

        print(
          'OthersProfilePage: Follow status for ${_learnerData!.name}: $isFollowing',
        );
      }
    } catch (e) {
      print('Error loading follow status: $e');
      // Silent fail for follow status loading
    }
  }

  /// Load user's feed posts
  Future<void> _loadUserFeeds() async {
    if (_learnerData == null) return;

    setState(() {
      _isFeedLoading = true;
      _feedError = null;
    });

    try {
      final feeds = await _feedRepository.getFeedPostsByUser(_learnerData!.id);
      setState(() {
        _userFeeds = feeds;
      });
    } catch (e) {
      setState(() {
        _feedError = e.toString();
      });
    } finally {
      setState(() {
        _isFeedLoading = false;
      });
    }
  }

  /// Toggle follow status with backend
  Future<void> _toggleFollow() async {
    // Check if user is authenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to follow users'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if trying to follow self
    if (authProvider.currentUser!.id == _learnerData?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot follow yourself'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isFollowLoading = true;
    });

    try {
      final followerProvider = Provider.of<FollowerProvider>(
        context,
        listen: false,
      );

      if (_learnerData != null) {
        final currentUser = authProvider.currentUser as Learner;
        print('Debug: Current user ID: ${currentUser.id}');
        print('Debug: Target user ID: ${_learnerData!.id}');
        print('Debug: Current following status: $isFollowing');

        // Use FollowerProvider to toggle follow status
        bool success = await followerProvider.toggleFollow(
          currentUser.id,
          _learnerData!.id,
        );

        print('Debug: Toggle result: $success');
        if (success) {
          setState(() {
            isFollowing = followerProvider.isFollowingUser(_learnerData!.id);
            if (isFollowing) {
              _followerCount = _followerCount + 1;
            } else {
              _followerCount = _followerCount > 0 ? _followerCount - 1 : 0;
            }
          });
        }

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFollowing ? 'Now following!' : 'Unfollowed'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update follow status. Please try again.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Debug: Error in _toggleFollow: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isFollowLoading = false;
      });
    }
  }

  // Computed properties from backend data
  String get bio => _learnerData?.bio ?? "No bio available";
  String get location => _learnerData?.country ?? "Unknown";
  String get country => _learnerData?.country ?? "Unknown";
  int get age {
    if (_learnerData == null) return 0;
    return DateTime.now().difference(_learnerData!.dateOfBirth).inDays ~/ 365;
  }

  String get gender => _learnerData?.gender ?? "Unknown";
  String get username => _learnerData?.username ?? "unknown";
  int get joinedDays {
    if (_learnerData == null) return 0;
    return DateTime.now().difference(_learnerData!.createdAt).inDays;
  }

  int get followingCount => _followingCount;
  int get followersCount => _followerCount;
  List<String> get interests => _learnerData?.interests ?? [];

  // Get shared interests with current user (case-insensitive comparison)
  List<String> get sharedInterests {
    if (_learnerData == null) return [];

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return [];

    final currentUser = authProvider.currentUser as Learner;
    final currentUserInterests = currentUser.interests
        .map((e) => e.toLowerCase())
        .toList();
    final otherUserInterests = _learnerData!.interests
        .map((e) => e.toLowerCase())
        .toList();

    return otherUserInterests
        .where((interest) => currentUserInterests.contains(interest))
        .toList();
  }

  // Helper method to get language flag
  String _getLanguageFlag(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return '🇺🇸';
      case 'spanish':
        return '🇪🇸';
      case 'japanese':
        return '🇯🇵';
      case 'korean':
        return '🇰🇷';
      case 'bangla':
      case 'bengali':
        return '🇧🇩';
      default:
        return '🌐';
    }
  }

  // Helper method to get map image provider based on country
  ImageProvider getMapImage(String country) {
    switch (country) {
      case 'USA':
        return const AssetImage('lib/image/Map/USA.jpeg');
      case 'Spain':
        return const AssetImage('lib/image/Map/Spain.jpeg');
      case 'Japan':
        return const AssetImage('lib/image/Map/Japan.jpeg');
      case 'Korea':
        return const AssetImage('lib/image/Map/Korea.jpeg');
      case 'Bangladesh':
        return const AssetImage('lib/image/Map/Bangladesh.jpeg');
      default:
        return const NetworkImage(
          'https://picsum.photos/400/200',
        ); // fallback to random image
    }
  }

  // Helper method to capitalize first letter
  String _capitalizeFirst(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  // Helper method to get current time for the country
  String getCurrentTimeForCountry(String country) {
    final now = DateTime.now();

    // Time zone offsets from UTC
    const Map<String, int> timeZoneOffsets = {
      'USA': -5, // EST (Eastern Standard Time)
      'Spain': 1, // CET (Central European Time)
      'Japan': 9, // JST (Japan Standard Time)
      'Korea': 9, // KST (Korea Standard Time)
      'Bangladesh': 6, // BST (Bangladesh Standard Time)
    };

    final offset = timeZoneOffsets[country] ?? 0;
    final countryTime = now.toUtc().add(Duration(hours: offset));

    // Format time as 12-hour format with AM/PM
    final hour = countryTime.hour;
    final minute = countryTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF7A54FF);

    // Show loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadLearnerData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Show profile not found state
    if (_learnerData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Profile not found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

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
                          image: getMapImage(country),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            primaryColor.withOpacity(0.6),
                            BlendMode.overlay,
                          ),
                          onError: (exception, stackTrace) {
                            print(
                              'Error loading map image for $country: $exception',
                            );
                          },
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

                          // Location and time
                          Positioned(
                            top: 80, // Adjusted for smaller cover height
                            right: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              constraints: BoxConstraints(maxWidth: 150),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.public,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      "$location ${getCurrentTimeForCountry(country)}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
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
                        // Main content container
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(16, 40, 16, 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Space for profile picture
                              SizedBox(height: 35),

                              // Basic info
                              _buildBasicInfo(isDark, primaryColor),
                              SizedBox(height: 16),

                              // Bio section
                              _buildBioSection(isDark),
                              SizedBox(height: 16),

                              // Tabs
                              _buildTabSection(isDark, primaryColor),
                            ],
                          ),
                        ),

                        // Profile picture positioned to overlap with cover image
                        Positioned(
                          top: -40, // Move it up to overlap with cover image
                          left: 16,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.white,
                            child: CircleAvatar(
                              radius: 37,
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
        // Name with gender/age and follow button row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with gender/age in one line with better flow control
                  Row(
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFFEEDF7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    gender == "Female"
                                        ? Icons.female
                                        : Icons.male,
                                    color: Color(0xFFD619A8),
                                    size: 16,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    age.toString(),
                                    style: TextStyle(
                                      color: Color(0xFFD619A8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),

                  // Username in another line
                  Text(
                    username,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  SizedBox(height: 8),

                  // Language chips in another line
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildLanguageChip(
                          _getLanguageFlag(_learnerData!.nativeLanguage),
                          _learnerData!.nativeLanguage,
                          Colors.green,
                          isDark,
                        ),
                        SizedBox(width: 8),
                        _buildLanguageChip(
                          _getLanguageFlag(_learnerData!.learningLanguage),
                          _learnerData!.learningLanguage,
                          primaryColor,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right side - Follow button
            Consumer<FollowerProvider>(
              builder: (context, followerProvider, child) {
                final currentIsFollowing = _learnerData != null
                    ? followerProvider.isFollowingUser(_learnerData!.id)
                    : isFollowing;

                return GestureDetector(
                  onTap: _isFollowLoading ? null : _toggleFollow,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: currentIsFollowing
                          ? primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _isFollowLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            currentIsFollowing
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: currentIsFollowing
                                ? Colors.white
                                : Colors.grey[600],
                            size: 20,
                          ),
                  ),
                );
              },
            ),
          ],
        ),

        SizedBox(height: 12),

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
            _buildStatItem(
              followersCount.toString(),
              AppLocalizations.of(context)!.followers,
              isDark,
            ),
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: TextStyle(fontSize: 12)),
          SizedBox(width: 3),
          Flexible(
            child: Text(
              language,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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
        Container(
          constraints: BoxConstraints(
            maxHeight: isBioExpanded ? double.infinity : 60,
          ),
          child: Text(
            bio,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.3,
            ),
            maxLines: maxLines,
            overflow: isBioExpanded ? null : TextOverflow.ellipsis,
          ),
        ),
        if (bio.length > 80)
          GestureDetector(
            onTap: () {
              setState(() {
                isBioExpanded = !isBioExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                isBioExpanded
                    ? AppLocalizations.of(context)!.showLess
                    : AppLocalizations.of(context)!.showMore,
                style: TextStyle(
                  color: Color(0xFF7A54FF),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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
              Tab(text: AppLocalizations.of(context)!.feed),
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
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shared Interests
          _buildSharedInterestsSection(isDark, primaryColor),
          SizedBox(height: 16),

          // Interests & Hobbies
          _buildInterestsSection(isDark),
        ],
      ),
    );
  }

  Widget _buildSharedInterestsSection(bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.sharedInterests,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8),
          sharedInterests.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'No shared interests found',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: sharedInterests.map((interest) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _capitalizeFirst(interest),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(bool isDark) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.interestsAndHobbies,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: interests.map((interest) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _capitalizeFirst(interest),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedTab(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feed loading state
          if (_isFeedLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          // Feed error state
          else if (_feedError != null)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 40, color: Colors.red),
                  SizedBox(height: 8),
                  Text(
                    'Error loading posts',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    _feedError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadUserFeeds,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          // Feed content
          else if (_userFeeds.isEmpty)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(Icons.article_outlined, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No Posts Yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '${widget.name} hasn\'t shared any posts yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            )
          // Display feed posts
          else
            Column(
              children: [
                // Pull to refresh indicator/button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${_userFeeds.length} post${_userFeeds.length == 1 ? '' : 's'}',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _loadUserFeeds,
                        child: Icon(
                          Icons.refresh,
                          color: const Color(0xFF7A54FF),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),

                // Feed posts
                ...(_userFeeds
                    .map((feed) => _buildFeedPost(feed, isDark))
                    .toList()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeedPost(Feed feed, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row (matches feed page design)
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.avatar),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Text(
                          feed.timeAgo,
                          style: TextStyle(color: iconColor, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              _learnerData!.nativeLanguage,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.sync_alt,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.purple,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              _learnerData!.learningLanguage,
                              style: TextStyle(
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
            ],
          ),
          SizedBox(height: 12),

          // Feed content
          Text(
            feed.contentText,
            style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),

          // Feed images if available
          if (feed.hasImages) ...[
            SizedBox(height: 8),
            _buildImageGrid(feed.imageUrls, isDark),
          ],

          SizedBox(height: 12),

          // Feed stats and actions (matches feed page style)
          Row(
            children: [
              // Like button
              Icon(Icons.favorite_border, size: 20, color: iconColor),
              SizedBox(width: 6),
              Text(
                feed.likesCount.toString(),
                style: TextStyle(color: iconColor, fontSize: 12),
              ),

              SizedBox(width: 20),

              // Comment button
              Icon(Icons.chat_bubble_outline, size: 20, color: iconColor),
              SizedBox(width: 6),
              Text(
                feed.commentsCount.toString(),
                style: TextStyle(color: iconColor, fontSize: 12),
              ),

              Spacer(),

              // Share button
              Icon(Icons.share_outlined, size: 20, color: iconColor),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build image grid like feed page
  Widget _buildImageGrid(List<String> imageUrls, bool isDark) {
    if (imageUrls.isEmpty) return SizedBox.shrink();

    if (imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrls[0],
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 32,
                ),
              ),
            );
          },
        ),
      );
    } else if (imageUrls.length == 2) {
      return Row(
        children: imageUrls.map((url) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: url == imageUrls.last ? 0 : 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      // For 3+ images, show grid layout
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: imageUrls.length > 4 ? 4 : imageUrls.length,
        itemBuilder: (context, index) {
          final isLastItem = index == 3 && imageUrls.length > 4;
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
                if (isLastItem)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        '+${imageUrls.length - 3}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildBottomButtons(bool isDark, Color primaryColor) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Follow button
            Expanded(
              child: Consumer<FollowerProvider>(
                builder: (context, followerProvider, child) {
                  final currentIsFollowing = _learnerData != null
                      ? followerProvider.isFollowingUser(_learnerData!.id)
                      : isFollowing;

                  return ElevatedButton(
                    onPressed: _isFollowLoading ? null : _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentIsFollowing
                          ? primaryColor
                          : Color(0xFFEFECFF),
                      foregroundColor: currentIsFollowing
                          ? Colors.white
                          : primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isFollowLoading
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                currentIsFollowing
                                    ? Colors.white
                                    : primaryColor,
                              ),
                            ),
                          )
                        : Text(
                            currentIsFollowing
                                ? AppLocalizations.of(context)!.following
                                : AppLocalizations.of(context)!.follow,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                  );
                },
              ),
            ),

            SizedBox(width: 10),

            // Chat button (now solid style)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to chat page with real user data
                  final chatUser = ChatUser(
                    id: _learnerData!.id,
                    name: _learnerData!.name,
                    avatarUrl: _learnerData!.profileImage ?? '',
                    country: _learnerData!.country,
                    flag: _getLanguageFlag(_learnerData!.nativeLanguage),
                    age: age,
                    gender: _learnerData!.gender,
                    isOnline: true, // TODO: Implement real online status
                    lastSeen: DateTime.now().subtract(
                      Duration(minutes: 5),
                    ), // TODO: Implement real last seen
                    interests: _learnerData!.interests,
                    nativeLanguage: _learnerData!.nativeLanguage,
                    learningLanguage: _learnerData!.learningLanguage,
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
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.chat,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
