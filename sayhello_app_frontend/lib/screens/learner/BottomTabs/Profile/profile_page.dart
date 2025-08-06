import 'package:flutter/material.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../Notifications/notifications.dart';
import '../../../auth/landing_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock user data - all editable fields
  final String userName = "Alex Johnson";
  final String userBio =
      "Language enthusiast 📚 Love traveling and meeting new people from different cultures! 🌍✈️";
  final String userAvatar = "https://i.pravatar.cc/150?img=1";
  final String email = "alex.johnson@example.com";
  final String birthday = "March 15, 1999";
  final int age = 25;
  final String gender = "Male";
  final String country = "USA"; // Added country field
  final String nativeLanguage = "English";
  final String learningLanguage = "Japanese";
  final String languageLevel = "Intermediate";
  final int joinedDays = 45;

  final List<String> selectedInterests = [
    "Art",
    "Music",
    "Travel",
    "Photography",
  ];
  final List<String> availableInterests = [
    "Art",
    "Music",
    "Reading",
    "Writing",
    "Sports",
    "Gaming",
    "Travel",
    "Cooking",
    "Fashion",
    "Photography",
    "Crafting",
    "Gardening",
    "Fitness",
    "Movies",
    "Technology",
    "Nature",
    "Animals",
    "Science",
    "Socializing",
  ];

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
        return const NetworkImage('https://picsum.photos/400/200');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF7A54FF);

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
            _buildProfileBanner(context, isDark, primaryColor),

            const SizedBox(height: 16),

            // Country and joined info
            _buildCountrySection(context, isDark, primaryColor),

            const SizedBox(height: 16),

            // About Me Section
            _buildAboutMeSection(context, isDark, primaryColor),

            const SizedBox(height: 16),

            // Language Section
            _buildLanguageSection(context, isDark, primaryColor),

            const SizedBox(height: 16),

            // Interests Section
            _buildInterestsSection(context, isDark, primaryColor),

            const SizedBox(height: 16),

            // Personal Information Section
            _buildPersonalInfoSection(context, isDark, primaryColor),

            const SizedBox(height: 100), // Bottom padding for scroll
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBanner(
    BuildContext context,
    bool isDark,
    Color primaryColor,
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
                image: getMapImage(country),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  primaryColor.withOpacity(0.6),
                  BlendMode.overlay,
                ),
                onError: (exception, stackTrace) {
                  print('Error loading map image for $country: $exception');
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
                            country,
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
                  backgroundImage: NetworkImage(userAvatar),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _showImageEditOptions(context, primaryColor),
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

  Widget _buildCountrySection(
    BuildContext context,
    bool isDark,
    Color primaryColor,
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
                  country,
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
              "${joinedDays}d joined",
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
                    userName,
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
                  userName,
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
                    userBio.isEmpty
                        ? AppLocalizations.of(context)!.tellUsAboutYourself
                        : userBio,
                    style: TextStyle(
                      fontSize: 14,
                      color: userBio.isEmpty
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
            nativeLanguage,
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

          _buildLanguageItem(
            context,
            '',
            '$learningLanguage - $languageLevel',
            '🇯🇵',
            isDark,
            primaryColor,
            onTap: () => _showLearningLanguageDialog(context, primaryColor),
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
            selectedInterests.join(', '),
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
            email,
            Icons.email_outlined,
            isDark,
            primaryColor,
          ),

          const SizedBox(height: 12),

          // Gender
          _buildPersonalInfoItem(
            context,
            AppLocalizations.of(context)!.gender,
            gender,
            Icons.person_outline,
            isDark,
            primaryColor,
          ),

          const SizedBox(height: 12),

          // Age
          _buildPersonalInfoItem(
            context,
            AppLocalizations.of(context)!.age,
            age.toString(),
            Icons.cake_outlined,
            isDark,
            primaryColor,
          ),

          const SizedBox(height: 12),

          // Birthday
          _buildPersonalInfoItem(
            context,
            AppLocalizations.of(context)!.birthday,
            birthday,
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
  }) {
    return GestureDetector(
      onTap: () {
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

  // Image edit options
  void _showImageEditOptions(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.editImage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: primaryColor),
              title: Text(AppLocalizations.of(context)!.takePhoto),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.cameraFeatureComingSoon,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: primaryColor),
              title: Text(AppLocalizations.of(context)!.selectFromGallery),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.galleryFeatureComingSoon,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Bio edit dialog
  void _showBioEditDialog(BuildContext context, Color primaryColor) {
    final TextEditingController controller = TextEditingController(
      text: userBio,
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.bioUpdatedSuccessfully,
                  ),
                ),
              );
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
    List<String> tempSelected = List.from(selectedInterests);

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
                  title: Text(interest),
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
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.hobbiesUpdatedSuccessfully,
                    ),
                  ),
                );
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
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.genderUpdated(g),
                        ),
                      ),
                    );
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
    int selectedAge = age;

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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.ageUpdated(selectedAge),
                  ),
                ),
              );
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
    showDatePicker(
      context: context,
      initialDate: DateTime(1999, 3, 15),
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
    ).then((selectedDate) {
      if (selectedDate != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.birthdayUpdatedSuccessfully,
            ),
          ),
        );
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
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your $title',
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
            onPressed: () {
              // TODO: Save the edited value
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.fieldUpdated(title),
                  ),
                ),
              );
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
        title: Text('Select Country'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: countries
              .map(
                (c) => ListTile(
                  leading: Icon(Icons.public, color: primaryColor),
                  title: Text(c),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Country updated to $c')),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // Learning language and level dialog
  void _showLearningLanguageDialog(BuildContext context, Color primaryColor) {
    final languages = ['English', 'Spanish', 'Japanese', 'Korean', 'Bangla'];
    final levels = [
      'Beginner',
      'Elementary',
      'Intermediate',
      'Advanced',
      'Proficient',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Learning Language & Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Language'),
              value: learningLanguage,
              items: languages
                  .map(
                    (lang) => DropdownMenuItem(value: lang, child: Text(lang)),
                  )
                  .toList(),
              onChanged: (value) {},
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Level'),
              value: languageLevel,
              items: levels
                  .map(
                    (level) =>
                        DropdownMenuItem(value: level, child: Text(level)),
                  )
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language settings updated')),
              );
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

  // Logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
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
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
