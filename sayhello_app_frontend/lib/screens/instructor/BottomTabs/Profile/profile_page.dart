import 'package:flutter/material.dart';
import '../../../../../providers/settings_provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../instructor_main_tab.dart';

class InstructorProfilePage extends StatefulWidget {
  const InstructorProfilePage({super.key});

  @override
  State<InstructorProfilePage> createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  // Instructor profile data
  String instructorName = "Dr. Sarah Johnson";
  String profileImageUrl = "https://i.pravatar.cc/150?img=5";
  String email = "sarah.johnson@university.edu";
  String dateOfBirth = "January 15, 1985";
  String gender = "Female";
  String country = "USA";
  String bio =
      "Passionate educator with extensive experience in programming and software development. I love helping students achieve their coding goals! 💻📚";
  String nativeLanguage = "English";
  String teachingLanguage = "English";
  int yearsOfExperience = 8;

  final List<String> languages = [
    'English',
    'Spanish',
    'Japanese',
    'Korean',
    'Bangla',
  ];
  final List<String> genders = ['Male', 'Female'];
  final List<String> countries = [
    'USA',
    'Spain',
    'Japan',
    'Korea',
    'Bangladesh',
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  // Navigate back to instructor main tab (homepage)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InstructorMainTab(),
                    ),
                  );
                },
              ),

              Expanded(
                child: Text(
                  localizations.instructorProfile,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
              ),

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

              // 🚪 LOGOUT ICON - This is the logout button in the app bar
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => _showLogoutDialog(),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header Card
            _buildProfileHeader(isDark, localizations),
            const SizedBox(height: 16),

            // Quick Stats
            _buildQuickStats(localizations),
            const SizedBox(height: 16),

            // Personal Information
            _buildPersonalInfoCard(isDark, localizations),
            const SizedBox(height: 16),

            // Professional Information
            _buildProfessionalInfoCard(isDark, localizations),
            const SizedBox(height: 16),

            // Language Information
            _buildLanguageInfoCard(isDark, localizations),
            const SizedBox(height: 16),

            // About Section
            _buildAboutSection(isDark, localizations),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7A54FF),
            const Color(0xFF7A54FF).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showImageEditOptions(localizations),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(profileImageUrl),
                  backgroundColor: Colors.white,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: const Color(0xFF7A54FF),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showEditDialog(
                    'Name',
                    instructorName,
                    (value) => setState(() => instructorName = value),
                    localizations,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          instructorName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(Icons.edit, color: Colors.white, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${localizations.instructorRole} • ${localizations.instructorYearsExp(yearsOfExperience)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  country,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7A54FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF7A54FF).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.school, color: const Color(0xFF7A54FF), size: 24),
                const SizedBox(height: 8),
                const Text(
                  '15',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  localizations.instructorStatsCourses,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7A54FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF7A54FF).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.people, color: const Color(0xFF7A54FF), size: 24),
                const SizedBox(height: 8),
                const Text(
                  '1,234',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  localizations.instructorStatsStudents,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7A54FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF7A54FF).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.star, color: const Color(0xFF7A54FF), size: 24),
                const SizedBox(height: 8),
                const Text(
                  '4.8',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  localizations.instructorStatsRating,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard(bool isDark, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: const Color(0xFF7A54FF), size: 20),
              const SizedBox(width: 8),
              Text(
                localizations.personalInformation,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            localizations.email,
            email,
            Icons.email,
            () => _showEditDialog(
              localizations.email,
              email,
              (value) => setState(() => email = value),
              localizations,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            localizations.dateOfBirth,
            dateOfBirth,
            Icons.cake,
            () => _showDatePicker(),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            localizations.gender,
            gender,
            Icons.person_outline,
            () => _showGenderDialog(),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            localizations.country,
            country,
            Icons.public,
            () => _showCountryDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoCard(
    bool isDark,
    AppLocalizations localizations,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work, color: const Color(0xFF7A54FF), size: 20),
              const SizedBox(width: 8),
              Text(
                localizations.instructorProfessionalInfo,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            localizations.instructorYearsOfExperience,
            '$yearsOfExperience years',
            Icons.timeline,
            () => _showExperienceDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageInfoCard(bool isDark, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: const Color(0xFF7A54FF), size: 20),
              const SizedBox(width: 8),
              Text(
                localizations.instructorLanguages,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            localizations.nativeLanguage,
            nativeLanguage,
            Icons.home,
            () => _showLanguageDialog('native'),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            localizations.teachingLanguage,
            teachingLanguage,
            Icons.school,
            () => _showLanguageDialog('teaching'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(bool isDark, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: const Color(0xFF7A54FF), size: 20),
              const SizedBox(width: 8),
              Text(
                localizations.aboutMe,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showBioEditDialog(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bio,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.edit,
                        color: const Color(0xFF7A54FF),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7A54FF), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit, color: Colors.grey[600], size: 16),
        ],
      ),
    );
  }

  // Dialog methods
  void _showImageEditOptions(AppLocalizations localizations) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Profile Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: const Color(0xFF7A54FF)),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Camera feature will be implemented'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: const Color(0xFF7A54FF),
              ),
              title: const Text('Select from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gallery feature will be implemented'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.link, color: const Color(0xFF7A54FF)),
              title: const Text('Enter Image URL'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(
                  'Profile Image URL',
                  profileImageUrl,
                  (value) => setState(() => profileImageUrl = value),
                  localizations,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    String title,
    String currentValue,
    Function(String) onSave,
    AppLocalizations localizations,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${localizations.edit} $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: localizations.instructorEnterField(title),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.instructorFieldUpdated(title)),
                ),
              );
            },
            child: Text(
              'Save',
              style: TextStyle(color: const Color(0xFF7A54FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBioEditDialog() {
    final controller = TextEditingController(text: bio);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bio'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Tell us about yourself...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          maxLength: 200,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => bio = controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bio updated successfully')),
              );
            },
            child: Text(
              'Save',
              style: TextStyle(color: const Color(0xFF7A54FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime(1985, 1, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF7A54FF)),
          ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          dateOfBirth =
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Date of birth updated successfully')),
        );
      }
    });
  }

  void _showGenderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: genders
              .map(
                (g) => ListTile(
                  title: Text(g),
                  onTap: () {
                    setState(() => gender = g);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gender updated successfully'),
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

  void _showCountryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Country'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: countries
              .map(
                (c) => ListTile(
                  title: Text(c),
                  onTap: () {
                    setState(() => country = c);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Country updated successfully'),
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

  void _showLanguageDialog(String type) {
    final currentLanguage = type == 'native'
        ? nativeLanguage
        : teachingLanguage;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select ${type == 'native' ? 'Native' : 'Teaching'} Language',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map(
                (lang) => ListTile(
                  title: Text(lang),
                  trailing: currentLanguage == lang
                      ? Icon(Icons.check, color: const Color(0xFF7A54FF))
                      : null,
                  onTap: () {
                    setState(() {
                      if (type == 'native') {
                        nativeLanguage = lang;
                      } else {
                        teachingLanguage = lang;
                      }
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${type == 'native' ? 'Native' : 'Teaching'} language updated successfully',
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

  void _showExperienceDialog() {
    int selectedExperience = yearsOfExperience;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Years of Experience'),
        content: SizedBox(
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) => selectedExperience = index,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) => Center(
                child: Text(
                  '$index years',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              childCount: 51, // 0 to 50 years
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => yearsOfExperience = selectedExperience);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Experience updated successfully'),
                ),
              );
            },
            child: Text(
              'Save',
              style: TextStyle(color: const Color(0xFF7A54FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to landing page and clear all previous routes
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
