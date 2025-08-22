import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../Chat/chat.dart';
import '../../../../providers/learner_provider.dart';
import '../../../../providers/auth_provider.dart';
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
      final learnerProvider = Provider.of<LearnerProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null && _learnerData != null) {
        final currentUser = authProvider.currentUser as Learner;
        final following = await learnerProvider.isFollowing(
          currentUser.id,
          _learnerData!.id,
        );
        setState(() {
          isFollowing = following;
        });
      }
    } catch (e) {
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
      final learnerProvider = Provider.of<LearnerProvider>(
        context,
        listen: false,
      );

      if (_learnerData != null) {
        final currentUser = authProvider.currentUser as Learner;
        print('Debug: Current user ID: ${currentUser.id}');
        print('Debug: Target user ID: ${_learnerData!.id}');
        print('Debug: Current following status: $isFollowing');

        bool success = false;
        if (isFollowing) {
          print('Debug: Attempting to unfollow...');
          success = await learnerProvider.unfollowLearner(
            currentUser.id,
            _learnerData!.id,
          );
          print('Debug: Unfollow result: $success');
          if (success) {
            setState(() {
              isFollowing = false;
              _followerCount = _followerCount > 0 ? _followerCount - 1 : 0;
            });
          }
        } else {
          print('Debug: Attempting to follow...');
          success = await learnerProvider.followLearner(
            currentUser.id,
            _learnerData!.id,
          );
          print('Debug: Follow result: $success');
          if (success) {
            setState(() {
              isFollowing = true;
              _followerCount = _followerCount + 1;
            });
          }
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

  // Get shared interests with current user
  List<String> get sharedInterests {
    if (_learnerData == null) return [];

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return [];

    final currentUser = authProvider.currentUser as Learner;
    final currentUserInterests = currentUser.interests;
    final otherUserInterests = _learnerData!.interests;

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
    final screenSize = MediaQuery.of(context).size;

    // Show loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // Custom app bar for loading state
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: primaryColor),
                      SizedBox(height: 16),
                      Text(
                        'Loading profile...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error state
    if (_error != null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // Custom app bar for error state
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Error loading profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadLearnerData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Try Again',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show profile not found state
    if (_learnerData == null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // Custom app bar for not found state
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_off_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Profile not found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'This user profile could not be found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            slivers: [
              // Cover image section
              SliverToBoxAdapter(
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor.withOpacity(0.8),
                        primaryColor,
                      ],
                    ),
                    image: DecorationImage(
                      image: getMapImage(country),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        primaryColor.withOpacity(0.6),
                        BlendMode.overlay,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        // Back button
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        
                        // Location and time
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.public, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  "$location ${getCurrentTimeForCountry(country)}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
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
                ),
              ),
              
              // Profile content
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: Offset(0, -60),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile picture and basic info
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: Column(
                            children: [
                              // Profile picture
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(widget.avatar),
                                ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Follow button (compact)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: _isFollowLoading ? null : _toggleFollow,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isFollowing ? primaryColor : primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: primaryColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: _isFollowLoading
                                          ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  isFollowing ? Colors.white : primaryColor,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              isFollowing ? Icons.favorite : Icons.favorite_border,
                                              color: isFollowing ? Colors.white : primaryColor,
                                              size: 18,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 12),
                              
                              // Name and gender/age
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.name,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFEEDF7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          gender == "female" ? Icons.female : Icons.male,
                                          color: Color(0xFFD619A8),
                                          size: 16,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          age.toString(),
                                          style: TextStyle(
                                            color: Color(0xFFD619A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 6),
                              
                              // Username
                              Text(
                                '@$username',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Language chips
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLanguageChip(
                                    _getLanguageFlag(_learnerData!.nativeLanguage),
                                    _learnerData!.nativeLanguage,
                                    Colors.green,
                                    isDark,
                                  ),
                                  SizedBox(width: 12),
                                  Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                                  SizedBox(width: 12),
                                  _buildLanguageChip(
                                    _getLanguageFlag(_learnerData!.learningLanguage),
                                    _learnerData!.learningLanguage,
                                    primaryColor,
                                    isDark,
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 20),
                              
                              // Stats row
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                              ),
                            ],
                          ),
                        ),
                        
                        // Bio section
                        if (bio.isNotEmpty && bio != "No bio available")
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: _buildBioSection(isDark),
                          ),
                        
                        // Tabs section
                        _buildTabSection(isDark, primaryColor),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Extra space for bottom buttons
              SliverToBoxAdapter(
                child: SizedBox(height: 120),
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
              onTap: _isFollowLoading ? null : _toggleFollow,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isFollowing ? primaryColor : Colors.grey[300],
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
                        isFollowing ? Icons.favorite : Icons.favorite_border,
                        color: isFollowing ? Colors.white : Colors.grey[600],
                        size: 20,
                      ),
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
                isBioExpanded
                    ? AppLocalizations.of(context)!.showLess
                    : AppLocalizations.of(context)!.showMore,
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
          AppLocalizations.of(context)!.sharedInterests,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 12),
        sharedInterests.isEmpty
            ? Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'No shared interests found',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              )
            : Wrap(
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
          AppLocalizations.of(context)!.interestsAndHobbies,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feed loading state
          if (_isFeedLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          // Feed error state
          else if (_feedError != null)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 12),
                  Text(
                    'Error loading posts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _feedError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 12),
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
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.article_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No Posts Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.name} hasn\'t shared any posts yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
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
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_userFeeds.length} post${_userFeeds.length == 1 ? '' : 's'}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: _loadUserFeeds,
                        child: Icon(
                          Icons.refresh,
                          color: const Color(0xFF7A54FF),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),

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
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feed header with user info and time
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
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      feed.timeAgo,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Feed content
          Text(
            feed.content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
              height: 1.4,
            ),
          ),

          // Feed image if available
          if (feed.hasImage) ...[
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                feed.imageUrl!,
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          SizedBox(height: 12),

          // Feed stats and actions
          Row(
            children: [
              // Like count
              Icon(Icons.favorite, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                feed.likesCount.toString(),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              SizedBox(width: 16),

              // Comment count
              Icon(Icons.comment, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                feed.commentsCount.toString(),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              Spacer(),

              // Language tag if available
              if (feed.language != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A54FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feed.language!,
                    style: TextStyle(
                      color: const Color(0xFF7A54FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
            // Follow button
            Expanded(
              child: ElevatedButton(
                onPressed: _isFollowLoading ? null : _toggleFollow,
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
                child: _isFollowLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFollowing ? Colors.white : primaryColor,
                          ),
                        ),
                      )
                    : Text(
                        isFollowing
                            ? AppLocalizations.of(context)!.following
                            : AppLocalizations.of(context)!.follow,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            SizedBox(width: 12),

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
