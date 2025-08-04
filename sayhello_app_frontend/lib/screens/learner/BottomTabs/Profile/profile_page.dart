import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock user data
  final String userName = "Alex Johnson";
  final String userBio =
      "Language enthusiast 📚 Love traveling and meeting new people from different cultures! 🌍✈️";
  final String userAvatar = "https://i.pravatar.cc/150?img=1";
  final String nativeLanguage = "English";
  final String learningLanguage = "Japanese - Intermediate";
  final List<String> selectedInterests = ["Movie", "Music", "Anime", "Cosplay"];
  final List<String> availableInterests = [
    "Movie",
    "Music",
    "Anime",
    "Cosplay",
    "Travel",
    "Photography",
    "Reading",
    "Gaming",
    "Cooking",
    "Sports",
    "Art",
    "Dancing",
  ];
  final String email = "alex.johnson@example.com";
  final String gender = "Male";
  final int age = 25;
  final String birthday = "March 15, 1999";

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final primaryColor = const Color(0xFF7A54FF);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 🔧 SETTINGS ICON - This is the settings button in the app bar
          // Click this to open the settings bottom sheet with theme and language options
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () =>
                _showSettingsBottomSheet(context, themeProvider, primaryColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Banner Section
            _buildProfileBanner(context, isDark, primaryColor),

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
      height: 220, // Reduced height since no completion progress
      child: Stack(
        children: [
          // World map background
          Container(
            height: 160, // Reduced height
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.8),
                  primaryColor.withOpacity(0.6),
                ],
              ),
            ),
            child: Stack(
              children: [
                // World map pattern overlay
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://picsum.photos/400/160?random=1',
                      ),
                      fit: BoxFit.cover,
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

          // Learning language
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
            learningLanguage,
            '🇯🇵',
            isDark,
            primaryColor,
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
  }) {
    return Container(
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
        ],
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

  // 🔧 SETTINGS BOTTOM SHEET - This function shows the settings menu when you tap the settings icon
  void _showSettingsBottomSheet(
    BuildContext context,
    ThemeProvider themeProvider,
    Color primaryColor,
  ) {
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Settings title
            Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // 🎨 THEME SETTING - This is the dark/light mode toggle in settings
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: primaryColor,
                ),
                title: Text(
                  AppLocalizations.of(context)!.colorMode,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  themeProvider.themeMode == ThemeMode.dark
                      ? AppLocalizations.of(context)!.darkMode
                      : AppLocalizations.of(context)!.lightMode,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
                onTap: () {
                  bool toDark = themeProvider.themeMode != ThemeMode.dark;
                  themeProvider.toggleTheme(toDark);
                },
              ),
            ),

            const SizedBox(height: 12),

            // 🌐 LANGUAGE SETTING - This is the language selection option in settings
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.language, color: primaryColor),
                title: Text(
                  AppLocalizations.of(context)!.language,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.changeAppLanguage,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                onTap: () {
                  Navigator.pop(context); // Close settings
                  _showLanguageSelector(context);
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🌐 ENHANCED LANGUAGE SELECTOR - Shows languages with flags and native text
  void _showLanguageSelector(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Enhanced language list with flags and native names
    final languages = [
      {
        'code': 'en',
        'name': 'English',
        'nativeName': 'English',
        'flag': '🇺🇸',
        'localized': AppLocalizations.of(context)!.english,
      },
      {
        'code': 'es',
        'name': 'Spanish',
        'nativeName': 'Español',
        'flag': '🇪🇸',
        'localized': AppLocalizations.of(context)!.spanish,
      },
      {
        'code': 'ja',
        'name': 'Japanese',
        'nativeName': '日本語',
        'flag': '🇯🇵',
        'localized': AppLocalizations.of(context)!.japanese,
      },
      {
        'code': 'ko',
        'name': 'Korean',
        'nativeName': '한국어',
        'flag': '🇰🇷',
        'localized': AppLocalizations.of(context)!.korean,
      },
      {
        'code': 'bn',
        'name': 'Bengali',
        'nativeName': 'বাংলা',
        'flag': '🇧🇩',
        'localized': AppLocalizations.of(context)!.bangla,
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          8,
        ), // Reduced padding
        titlePadding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          8,
        ), // Reduced padding
        actionsPadding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16,
        ), // Custom actions padding
        title: Row(
          children: [
            Icon(
              Icons.language,
              color: const Color(0xFF7A54FF),
              size: 22, // Reduced from 24 to 22
            ),
            const SizedBox(width: 6), // Reduced from 8 to 6
            Expanded(
              // Wrap the text in Expanded to prevent overflow
              child: Text(
                AppLocalizations.of(context)!.selectLanguage,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // Slightly reduced font size
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            // Add scroll view as backup
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.chooseYourPreferredLanguage,
                  style: TextStyle(
                    fontSize: 12, // Reduced from 13 to 12
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12), // Reduced from 16 to 12
                // Language selection list - All languages shown together without scrolling
                ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling
                  itemCount: languages.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? Colors.grey[700] : Colors.grey[200],
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final isSelected =
                        languageProvider.currentLocale.languageCode ==
                        language['code'];

                    return InkWell(
                      onTap: () {
                        // Set the new language
                        languageProvider.setLocale(Locale(language['code']!));
                        Navigator.pop(context);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Text(language['flag']!),
                                const SizedBox(width: 8),
                                Text(
                                  '${AppLocalizations.of(context)!.languageChangedTo} ${language['localized']}',
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical:
                              10, // Reduced from 12 to 10 for even more compact layout
                          horizontal: 12,
                        ),
                        child: Row(
                          children: [
                            // Flag
                            Text(
                              language['flag']!,
                              style: const TextStyle(
                                fontSize: 20,
                              ), // Reduced from 22 to 20
                            ),
                            const SizedBox(width: 10), // Reduced from 12 to 10
                            // Language names
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Localized name (in current app language)
                                  Text(
                                    language['localized']!,
                                    style: TextStyle(
                                      fontSize: 15, // Reduced from 16 to 15
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF7A54FF)
                                          : (isDark
                                                ? Colors.white
                                                : Colors.black),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // Native name (in the language itself)
                                  if (language['nativeName'] !=
                                      language['localized'])
                                    Text(
                                      language['nativeName']!,
                                      style: TextStyle(
                                        fontSize: 12, // Reduced from 13 to 12
                                        color: isSelected
                                            ? const Color(
                                                0xFF7A54FF,
                                              ).withOpacity(0.8)
                                            : Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),

                            // Selection indicator
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF7A54FF,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Color(0xFF7A54FF),
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.close,
              style: TextStyle(color: const Color(0xFF7A54FF)),
            ),
          ),
        ],
      ),
    );
  }
}
