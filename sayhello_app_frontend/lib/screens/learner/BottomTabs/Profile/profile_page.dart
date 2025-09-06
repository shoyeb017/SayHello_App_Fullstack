import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../providers/settings_provider.dart';
import '../../../../providers/learner_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/follower_provider.dart';
import '../../../../providers/notification_provider.dart';
import '../../../../models/learner.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/supabase_config.dart';
import '../../Notifications/notifications.dart';
import '../../../auth/landing_page.dart';
import 'followers_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  LearnerProvider? _learnerProvider;
  bool _initialized = false;
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _scaffoldMessenger = ScaffoldMessenger.of(context);
      // Use post-frame callback to avoid calling notifyListeners during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeData();
      });
    }
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    _learnerProvider = Provider.of<LearnerProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final followerProvider = Provider.of<FollowerProvider>(
      context,
      listen: false,
    );

    if (_learnerProvider?.currentLearner == null &&
        authProvider.currentUser != null) {
      await _learnerProvider?.loadLearner(authProvider.currentUser.id);
    }

    // Load follower counts if user is available
    if (authProvider.currentUser != null) {
      await followerProvider.loadCounts(authProvider.currentUser.id);
    }
  }

  final List<String> languages = [
    'English',
    'Spanish',
    'Japanese',
    'Korean',
    'Bangla',
  ];
  final List<String> genders = ['male', 'female'];
  final List<String> countries = [
    'usa', // United States
    'spain', // Spain
    'japan', // Japan
    'korea', // Korea
    'bangladesh', // Bangladesh
  ];
  final List<String> levels = [
    'beginner',
    'elementary',
    'intermediate',
    'advanced',
    'proficient',
  ];

  // Helper method to get map image provider based on country
  ImageProvider getMapImage(String country) {
    final capitalizedCountry = _capitalizeFirst(country);
    switch (capitalizedCountry) {
      case 'Usa':
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
        return const NetworkImage('https://picsum.photos/400/200');
    }
  }

  // Helper method to calculate joined days
  int _calculateJoinedDays(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays;
  }

  // Helper method to calculate age from date of birth
  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Helper method to capitalize first letter
  String _capitalizeFirst(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  // Helper: map language name to a representative flag
  String _getLanguageFlagForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        // Use UK or US flag; pick US here for consistency with existing assets
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

  // Helper method to format country name for display
  String _formatCountryName(String country) {
    final capitalizedCountry = _capitalizeFirst(country);
    if (capitalizedCountry.toLowerCase() == 'usa') {
      return 'USA';
    }
    return capitalizedCountry;
  }

  // Pick and upload image method
  Future<void> _pickAndUploadImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      if (!mounted) return;

      final file = File(image.path);
      final fileName = 'learner_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload to Supabase Storage
      final response = await SupabaseConfig.client.storage
          .from('profile-images')
          .upload(fileName, file);

      if (response.isNotEmpty) {
        // Get the public URL
        final imageUrl = SupabaseConfig.client.storage
            .from('profile-images')
            .getPublicUrl(fileName);

        // Update learner profile with new image URL
        final learnerProvider = Provider.of<LearnerProvider>(
          context,
          listen: false,
        );
        await learnerProvider.updateLearner({'profile_image': imageUrl});

        if (mounted) {
          _scaffoldMessenger?.showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessenger?.showSnackBar(
          SnackBar(
            content: Text('Failed to update image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LearnerProvider, AuthProvider, FollowerProvider>(
      builder: (context, learnerProvider, authProvider, followerProvider, child) {
        final learner = learnerProvider.currentLearner;
        final isLoading = learnerProvider.isLoading;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = const Color(0xFF7A54FF);

        if (isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          );
        }

        if (learner == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load profile',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (authProvider.currentUser != null) {
                        learnerProvider.loadLearner(
                          authProvider.currentUser.id,
                        );
                      }
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(52),
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
                      AppLocalizations.of(context)!.profile,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  // 🔔 NOTIFICATION ICON - This is the notification button in the app bar
                  Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, child) {
                      final unreadCount = notificationProvider.unreadCount;
                      return Stack(
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
                          if (unreadCount > 0)
                            Positioned(
                              right: 11,
                              top: 11,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                child: Text(
                                  unreadCount > 99
                                      ? '99+'
                                      : unreadCount.toString(),
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
                      );
                    },
                  ),

                  // 🚪 LOGOUT ICON - This is the logout button in the app bar
                  IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Banner Section
                _buildProfileBanner(context, isDark, primaryColor, learner),

                const SizedBox(height: 16),

                // Stats Section (Followers, Following, Posts)
                _buildStatsSection(
                  context,
                  isDark,
                  primaryColor,
                  learner,
                  followerProvider,
                ),

                const SizedBox(height: 16),

                // Country and joined info
                _buildCountrySection(context, isDark, primaryColor, learner),

                const SizedBox(height: 16),

                // About Me Section
                _buildAboutMeSection(context, isDark, primaryColor, learner),

                const SizedBox(height: 16),

                // Language Section
                _buildLanguageSection(context, isDark, primaryColor, learner),

                const SizedBox(height: 16),

                // Interests Section
                _buildInterestsSection(context, isDark, primaryColor, learner),

                const SizedBox(height: 16),

                // Personal Information Section
                _buildPersonalInfoSection(
                  context,
                  isDark,
                  primaryColor,
                  learner,
                ),

                const SizedBox(height: 100), // Bottom padding for scroll
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileBanner(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Learner learner,
  ) {
    return Container(
      height: 220,
      child: Stack(
        children: [
          // Map background based on country
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primaryColor.withOpacity(0.8), primaryColor],
              ),
              image: DecorationImage(
                image: getMapImage(learner.country),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  primaryColor.withOpacity(0.6),
                  BlendMode.overlay,
                ),
                onError: (exception, stackTrace) {
                  print(
                    'Error loading map image for ${learner.country}: $exception',
                  );
                },
              ),
            ),
            child: Stack(
              children: [
                // Country info in top right
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () =>
                        _showCountrySelectionDialog(context, primaryColor),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            _formatCountryName(learner.country),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.edit, color: Colors.white, size: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Profile picture with camera icon
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  backgroundImage: learner.profileImage != null
                      ? NetworkImage(learner.profileImage!)
                      : null,
                  child: learner.profileImage == null
                      ? Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _pickAndUploadImage(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Learner learner,
    FollowerProvider followerProvider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Posts/Feed count
          _buildStatItem(
            context,
            'Posts',
            followerProvider.feedCount.toString(),
            Icons.article_outlined,
            primaryColor,
            isDark,
            onTap: () {
              // Could navigate to user's feed posts
              print('Navigate to user posts');
            },
          ),

          // Followers count
          _buildStatItem(
            context,
            'Followers',
            followerProvider.followersCount.toString(),
            Icons.people_outline,
            primaryColor,
            isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowersPage(
                    learnerId: learner.id,
                    learnerName: learner.name,
                    title: 'Followers',
                    isFollowers: true,
                  ),
                ),
              );
            },
          ),

          // Following count
          _buildStatItem(
            context,
            'Following',
            followerProvider.followingCount.toString(),
            Icons.person_add_outlined,
            primaryColor,
            isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowersPage(
                    learnerId: learner.id,
                    learnerName: learner.name,
                    title: 'Following',
                    isFollowers: false,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String count,
    IconData icon,
    Color primaryColor,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Learner learner,
  ) {
    final joinedDays = _calculateJoinedDays(learner.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.public, color: primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.country,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatCountryName(learner.country),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              "${joinedDays}d ${AppLocalizations.of(context)!.joinedShort}",
              style: TextStyle(
                color: primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMeSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Learner learner,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.aboutMe,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Name section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.name,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    learner.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showEditDialog(
                  context,
                  AppLocalizations.of(context)!.name,
                  learner.name,
                ),
                child: Text(
                  AppLocalizations.of(context)!.edit,
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Self-introduction section
          GestureDetector(
            onTap: () => _showBioEditDialog(context, primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selfIntroduction,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Icon(Icons.edit, color: primaryColor, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Text(
                    (learner.bio?.isEmpty ?? true)
                        ? AppLocalizations.of(context)!.tellUsAboutYourself
                        : learner.bio!,
                    style: TextStyle(
                      fontSize: 14,
                      color: (learner.bio?.isEmpty ?? true)
                          ? Colors.grey[500]
                          : (isDark ? Colors.white : Colors.black),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Learner learner,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.language,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Native language
          _buildLanguageItem(
            context,
            AppLocalizations.of(context)!.native,
            _capitalizeFirst(learner.nativeLanguage),
            '🇺🇸',
            isDark,
            primaryColor,
            isNative: true,
          ),

          const SizedBox(height: 12),

          // Learning language with level
          Text(
            AppLocalizations.of(context)!.learning,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Learning language (non-editable)
          _buildLanguageItem(
            context,
            '',
            _capitalizeFirst(learner.learningLanguage),
            _getLanguageFlagForLanguage(learner.learningLanguage),
            isDark,
            primaryColor,
            onTap: () => _showLearningLanguageDialog(context, primaryColor),
          ),

          const SizedBox(height: 8),

          // Learning level (editable)
          _buildLanguageItem(
            context,
            AppLocalizations.of(context)!.level,
            _capitalizeFirst(learner.languageLevel),
            '📈',
            isDark,
            primaryColor,
            onTap: () => _showLanguageLevelDialog(context, primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context,
    String label,
    String language,
    String flag,
    bool isDark,
    Color primaryColor, {
    bool isNative = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  Text(
                    language,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            if (isNative)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.native,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (onTap != null) Icon(Icons.edit, color: primaryColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Learner learner,
  ) {
    final interests = learner.interests.isNotEmpty
        ? learner.interests
              .map((interest) => _capitalizeFirst(interest))
              .join(', ')
        : 'No interests selected';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.interests,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Hobbies
          _buildInterestItem(
            context,
            AppLocalizations.of(context)!.addHobbies,
            interests,
            Icons.favorite_outline,
            isDark,
            primaryColor,
            hasRedDot: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInterestItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
    Color primaryColor, {
    bool hasRedDot = false,
  }) {
    return GestureDetector(
      onTap: () => _showHobbiesSelectionDialog(context, primaryColor),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      if (hasRedDot) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Learner learner,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.personalInformation,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Email
          _buildPersonalInfoItem(
            context,
            AppLocalizations.of(context)!.email,
            learner.email,
            Icons.email_outlined,
            isDark,
            primaryColor,
            onTap: () => _showEmailEditDialog(context, primaryColor),
          ),

          const SizedBox(height: 12),

          // Password
          _buildPersonalInfoItem(
            context,
            'Password',
            '••••••••',
            Icons.lock_outlined,
            isDark,
            primaryColor,
            onTap: () => _showPasswordChangeDialog(context, primaryColor),
          ),

          const SizedBox(height: 12),

          // Gender
          _buildPersonalInfoItem(
            context,
            AppLocalizations.of(context)!.gender,
            _capitalizeFirst(learner.gender),
            Icons.person_outline,
            isDark,
            primaryColor,
          ),

          const SizedBox(height: 12),

          // Age (calculated from dateOfBirth)
          _buildPersonalInfoItem(
            context,
            AppLocalizations.of(context)!.age,
            _calculateAge(learner.dateOfBirth).toString(),
            Icons.cake_outlined,
            isDark,
            primaryColor,
          ),

          const SizedBox(height: 12),

          // Birthday
          _buildPersonalInfoItem(
            context,
            AppLocalizations.of(context)!.birthday,
            '${learner.dateOfBirth.day}/${learner.dateOfBirth.month}/${learner.dateOfBirth.year}',
            Icons.calendar_today_outlined,
            isDark,
            primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    bool isDark,
    Color primaryColor, {
    bool hasRedDot = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            if (title == AppLocalizations.of(context)!.gender) {
              _showGenderSelectionDialog(context, primaryColor);
            } else if (title == AppLocalizations.of(context)!.age) {
              _showAgeSelectionDialog(context, primaryColor);
            } else if (title == AppLocalizations.of(context)!.birthday) {
              _showBirthdaySelectionDialog(context, primaryColor);
            } else {
              _showEditDialog(context, title, value);
            }
          },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      if (hasRedDot) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasRedDot ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  // Bio edit dialog
  void _showBioEditDialog(BuildContext context, Color primaryColor) {
    final learnerProvider = Provider.of<LearnerProvider>(
      context,
      listen: false,
    );
    final currentBio = learnerProvider.currentLearner?.bio ?? '';

    final TextEditingController controller = TextEditingController(
      text: currentBio,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editBio),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.tellUsAboutYourself,
            border: const OutlineInputBorder(),
          ),
          maxLines: 5,
          maxLength: 200,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await learnerProvider.updateLearner({
                  'bio': controller.text.trim(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.bioUpdatedSuccessfully,
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update bio: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              AppLocalizations.of(context)!.save,
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // Hobbies selection dialog
  void _showHobbiesSelectionDialog(BuildContext context, Color primaryColor) {
    final learnerProvider = Provider.of<LearnerProvider>(
      context,
      listen: false,
    );
    final currentInterests = learnerProvider.currentLearner?.interests ?? [];
    List<String> tempSelected = List.from(currentInterests);

    final availableInterests = [
      "art",
      "music",
      "reading",
      "writing",
      "sports",
      "gaming",
      "travel",
      "cooking",
      "fashion",
      "photography",
      "crafting",
      "gardening",
      "fitness",
      "movies",
      "technology",
      "nature",
      "animals",
      "science",
      "socializing",
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectHobbies),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableInterests.length,
              itemBuilder: (context, index) {
                final interest = availableInterests[index];
                final isSelected = tempSelected.contains(interest);

                return CheckboxListTile(
                  title: Text(_capitalizeFirst(interest)),
                  value: isSelected,
                  activeColor: primaryColor,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        tempSelected.add(interest);
                      } else {
                        tempSelected.remove(interest);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await learnerProvider.updateLearner({
                    'interests': tempSelected,
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          )!.hobbiesUpdatedSuccessfully,
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update interests: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                AppLocalizations.of(context)!.save,
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Gender selection dialog
  void _showGenderSelectionDialog(BuildContext context, Color primaryColor) {
    final genders = [
      AppLocalizations.of(context)!.male,
      AppLocalizations.of(context)!.female,
      AppLocalizations.of(context)!.other,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectGender),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: genders
              .map(
                (g) => ListTile(
                  leading: Icon(
                    g == AppLocalizations.of(context)!.male
                        ? Icons.male
                        : g == AppLocalizations.of(context)!.female
                        ? Icons.female
                        : Icons.person,
                    color: primaryColor,
                  ),
                  title: Text(g),
                  onTap: () async {
                    try {
                      final learnerProvider = Provider.of<LearnerProvider>(
                        context,
                        listen: false,
                      );
                      await learnerProvider.updateLearner({
                        'gender': g.toLowerCase(),
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.genderUpdated(g),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update gender: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // Age selection dialog
  void _showAgeSelectionDialog(BuildContext context, Color primaryColor) {
    final learnerProvider = Provider.of<LearnerProvider>(
      context,
      listen: false,
    );
    final currentAge = learnerProvider.currentLearner != null
        ? _calculateAge(learnerProvider.currentLearner!.dateOfBirth)
        : 25;
    int selectedAge = currentAge;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectAge),
        content: SizedBox(
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            physics: FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              selectedAge = index + 13; // Starting from age 13
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                return Center(
                  child: Text(
                    '${index + 13}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                );
              },
              childCount: 88, // Ages 13 to 100
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Calculate new date of birth based on selected age
                final now = DateTime.now();
                final newDateOfBirth = DateTime(
                  now.year - selectedAge,
                  now.month,
                  now.day,
                );

                await learnerProvider.updateLearner({
                  'date_of_birth': newDateOfBirth.toIso8601String(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.ageUpdated(selectedAge),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update age: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              AppLocalizations.of(context)!.save,
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // Birthday selection dialog
  void _showBirthdaySelectionDialog(BuildContext context, Color primaryColor) {
    final learnerProvider = Provider.of<LearnerProvider>(
      context,
      listen: false,
    );
    final currentBirthday =
        learnerProvider.currentLearner?.dateOfBirth ?? DateTime(1999, 3, 15);

    showDatePicker(
      context: context,
      initialDate: currentBirthday,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: primaryColor),
          ),
          child: child!,
        );
      },
    ).then((selectedDate) async {
      if (selectedDate != null) {
        try {
          await learnerProvider.updateLearner({
            'date_of_birth': selectedDate.toIso8601String(),
          });

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.birthdayUpdatedSuccessfully,
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update birthday: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String currentValue,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title == AppLocalizations.of(context)!.name
              ? AppLocalizations.of(context)!.editName
              : 'Edit $title',
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: title == AppLocalizations.of(context)!.name
                ? AppLocalizations.of(context)!.enterYourName
                : 'Enter your $title',
            border: const OutlineInputBorder(),
          ),
          maxLines: title == 'Bio' ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                final learnerProvider = Provider.of<LearnerProvider>(
                  context,
                  listen: false,
                );

                if (title == AppLocalizations.of(context)!.name) {
                  await learnerProvider.updateLearner({
                    'name': controller.text.trim(),
                  });
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.fieldUpdated(title),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update $title: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  // Country selection dialog
  void _showCountrySelectionDialog(BuildContext context, Color primaryColor) {
    final countries = ['USA', 'Spain', 'Japan', 'Korea', 'Bangladesh'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectCountry),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: countries
              .map(
                (c) => ListTile(
                  leading: Icon(Icons.public, color: primaryColor),
                  title: Text(c),
                  onTap: () async {
                    try {
                      final learnerProvider = Provider.of<LearnerProvider>(
                        context,
                        listen: false,
                      );
                      await learnerProvider.updateLearner({
                        'country': c.toLowerCase(),
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Country updated to $c'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update country: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // Language level selection dialog (separate from language)
  void _showLanguageLevelDialog(BuildContext context, Color primaryColor) {
    final learnerProvider = Provider.of<LearnerProvider>(
      context,
      listen: false,
    );
    final currentLearner = learnerProvider.currentLearner;

    final levels = [
      'Beginner',
      'Elementary',
      'Intermediate',
      'Advanced',
      'Proficient',
    ];

    // Capitalize the stored value to match dropdown items
    String selectedLevel = currentLearner?.languageLevel != null
        ? _capitalizeFirst(currentLearner!.languageLevel)
        : 'Intermediate';

    // Ensure the selected value exists in the dropdown options
    if (!levels.contains(selectedLevel)) {
      selectedLevel = 'Intermediate';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Select Language Level'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.level,
                ),
                value: selectedLevel,
                items: levels
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLevel = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                try {
                  print(
                    'Updating level: $selectedLevel -> ${selectedLevel.toLowerCase()}',
                  );

                  final updateData = {
                    'language_level': selectedLevel.toLowerCase(),
                  };
                  print('Update data: $updateData');

                  final success = await learnerProvider.updateLearner(
                    updateData,
                  );
                  print('Update success: $success');

                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language level updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update language level'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  print('Error updating language level: $e');
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update language level: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                AppLocalizations.of(context)!.save,
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Learning language selection dialog
  void _showLearningLanguageDialog(BuildContext context, Color primaryColor) {
    final learnerProvider = Provider.of<LearnerProvider>(
      context,
      listen: false,
    );
    final currentLearner = learnerProvider.currentLearner;

    // Use existing languages list defined at top of this state
    final available = languages;
    // Capitalize the stored value for matching in list UI
    String selected = currentLearner?.learningLanguage != null
        ? _capitalizeFirst(currentLearner!.learningLanguage)
        : available.first;
    if (!available.contains(selected)) {
      // Fallback if stored value not in list
      selected = available.first;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Select Learning Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selected,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.language,
                ),
                items: available
                    .map(
                      (lang) => DropdownMenuItem(
                        value: lang,
                        child: Row(
                          children: [
                            Text(
                              _getLanguageFlagForLanguage(lang),
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(lang),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selected = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                // Show confirmation dialog first
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirm Language Change'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Changing your learning language to $selected will log you out and you\'ll need to sign in again.',
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This is required to reload all content according to your new language preference.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Continue',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return;

                try {
                  final update = {'learning_language': selected.toLowerCase()};
                  final success = await learnerProvider.updateLearner(update);

                  if (context.mounted) {
                    Navigator.pop(
                      context,
                    ); // Close the language selection dialog

                    if (success) {
                      // Clear all providers/cache data
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final followerProvider = Provider.of<FollowerProvider>(
                        context,
                        listen: false,
                      );
                      final notificationProvider =
                          Provider.of<NotificationProvider>(
                            context,
                            listen: false,
                          );

                      // Clear provider data
                      followerProvider.clear();
                      learnerProvider.clear();
                      notificationProvider.clearNotifications();

                      // Sign out and redirect to landing page
                      await authProvider.signOut();

                      // Navigate to landing page and clear all routes
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LandingPage()),
                        (route) => false,
                      );

                      // Show success message on the landing page context
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Learning language updated to $selected. Please sign in again.',
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update learning language'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update learning language: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                AppLocalizations.of(context)!.save,
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.areYouSureLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              // Clear navigation stack and go to landing page
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LandingPage()),
                (route) => false,
              );
            },
            child: Text(
              AppLocalizations.of(context)!.logout,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Email edit dialog
  void _showEmailEditDialog(BuildContext context, Color primaryColor) {
    final learnerProvider = Provider.of<LearnerProvider>(
      context,
      listen: false,
    );
    final currentEmail = learnerProvider.currentLearner?.email ?? '';

    final TextEditingController controller = TextEditingController(
      text: currentEmail,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            Text(
              'Note: Changing your email will require verification',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              final newEmail = controller.text.trim();
              if (newEmail.isEmpty || !newEmail.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid email address'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await learnerProvider.updateLearner({'email': newEmail});

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update email: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              AppLocalizations.of(context)!.save,
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // Password change dialog
  void _showPasswordChangeDialog(BuildContext context, Color primaryColor) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current Password
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showCurrentPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          showCurrentPassword = !showCurrentPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: !showCurrentPassword,
                ),
                const SizedBox(height: 16),

                // New Password
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          showNewPassword = !showNewPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: !showNewPassword,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          showConfirmPassword = !showConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: !showConfirmPassword,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                final currentPassword = currentPasswordController.text.trim();
                final newPassword = newPasswordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();

                // Validation
                if (currentPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter your current password'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (newPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a new password'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('New passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final success = await authProvider.changePassword(
                    currentPassword,
                    newPassword,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Password changed successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            authProvider.error ?? 'Failed to change password',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to change password: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Change Password',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
