import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../providers/settings_provider.dart';
import '../../../../../providers/instructor_provider.dart';
import '../../../../../providers/auth_provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../services/supabase_config.dart';
import '../../instructor_main_tab.dart';

class InstructorProfilePage extends StatefulWidget {
  const InstructorProfilePage({super.key});

  @override
  State<InstructorProfilePage> createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  InstructorProvider? _instructorProvider;
  bool _initialized = false;
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _scaffoldMessenger = ScaffoldMessenger.of(context);
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    _instructorProvider = Provider.of<InstructorProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_instructorProvider?.currentInstructor == null &&
        authProvider.currentUser != null) {
      await _instructorProvider?.loadInstructorById(
        authProvider.currentUser.id,
      );
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final instructorProvider = Provider.of<InstructorProvider>(context);
    final instructor = instructorProvider.currentInstructor;

    if (instructorProvider.isLoading || instructor == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (instructorProvider.hasError) {
      return Scaffold(
        body: Center(
          child: Text(instructorProvider.error ?? 'Unknown error occurred'),
        ),
      );
    }

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
    final instructor = Provider.of<InstructorProvider>(
      context,
    ).currentInstructor!;

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
                  backgroundImage: instructor.profileImage != null
                      ? NetworkImage(instructor.profileImage!)
                      : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
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
                  onTap: () =>
                      _showEditDialog('Name', instructor.name, (value) async {
                        await _instructorProvider?.updateInstructor({
                          'name': value,
                        });
                      }, localizations),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          instructor.name,
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
                  '${localizations.instructorRole} • ${localizations.instructorYearsExp(instructor.yearsOfExperience)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  getCountryName(instructor.country),
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
    final instructorProvider = Provider.of<InstructorProvider>(context);
    final stats = instructorProvider.instructorStats;

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
                Text(
                  stats?['total_courses']?.toString() ?? '0',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                Text(
                  stats?['total_students']?.toString() ?? '0',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                Text(
                  (stats?['average_rating'] ?? 0.0).toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
    final instructor = Provider.of<InstructorProvider>(
      context,
    ).currentInstructor!;

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
            instructor.email,
            Icons.email,
            () => _showEditDialog(localizations.email, instructor.email, (
              value,
            ) async {
              await _instructorProvider?.updateInstructor({'email': value});
            }, localizations),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Password',
            '••••••••',
            Icons.lock,
            () => _showPasswordChangeDialog(),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            localizations.dateOfBirth,
            instructor.dateOfBirth.toString().split(' ')[0],
            Icons.cake,
            () => _showDatePicker(),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            localizations.gender,
            getGenderDisplayName(instructor.gender),
            Icons.person_outline,
            () => _showGenderDialog(),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            localizations.country,
            instructor.country,
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
    final instructor = Provider.of<InstructorProvider>(
      context,
    ).currentInstructor!;

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
            '${instructor.yearsOfExperience} years',
            Icons.timeline,
            () => _showExperienceDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageInfoCard(bool isDark, AppLocalizations localizations) {
    final instructor = Provider.of<InstructorProvider>(
      context,
    ).currentInstructor!;

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
          _buildInfoRowReadOnly(
            localizations.nativeLanguage,
            instructor.nativeLanguage,
            Icons.home,
          ),
          const SizedBox(height: 12),
          _buildInfoRowReadOnly(
            localizations.teachingLanguage,
            instructor.teachingLanguage,
            Icons.school,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(bool isDark, AppLocalizations localizations) {
    final instructor = Provider.of<InstructorProvider>(
      context,
    ).currentInstructor!;

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
                          instructor.bio ?? '',
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

  Widget _buildInfoRowReadOnly(String label, String value, IconData icon) {
    return Row(
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
      ],
    );
  }

  // Dialog methods
  void _showImageEditOptions(AppLocalizations localizations) {
    final instructor = Provider.of<InstructorProvider>(
      context,
      listen: false,
    ).currentInstructor!;

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
                _pickImageFromCamera();
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
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.link, color: const Color(0xFF7A54FF)),
              title: const Text('Enter Image URL'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(
                  'Profile Image URL',
                  instructor.profileImage ?? '',
                  (value) async {
                    await _instructorProvider?.updateInstructor({
                      'profile_image': value,
                    });
                  },
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
              if (!mounted) return;
              _showSnackBar(
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
    final instructor = Provider.of<InstructorProvider>(
      context,
      listen: false,
    ).currentInstructor!;
    final controller = TextEditingController(text: instructor.bio ?? '');

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
            onPressed: () async {
              await _instructorProvider?.updateInstructor({
                'bio': controller.text,
              });
              Navigator.pop(context);
              if (!mounted) return;
              _showSnackBar(
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
    final instructor = Provider.of<InstructorProvider>(
      context,
      listen: false,
    ).currentInstructor!;
    showDatePicker(
      context: context,
      initialDate: instructor.dateOfBirth,
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
    ).then((selectedDate) async {
      if (selectedDate != null) {
        await _instructorProvider?.updateInstructor({
          'date_of_birth': selectedDate.toIso8601String(),
        });
        if (!mounted) return;
        _showSnackBar(
          const SnackBar(content: Text('Date of birth updated successfully')),
        );
      }
    });
  }

  void _showGenderDialog() {
    final instructor = Provider.of<InstructorProvider>(
      context,
      listen: false,
    ).currentInstructor!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: genders
              .map(
                (g) => ListTile(
                  title: Text(getGenderDisplayName(g)),
                  trailing: instructor.gender.toLowerCase() == g.toLowerCase()
                      ? Icon(Icons.check, color: const Color(0xFF7A54FF))
                      : null,
                  onTap: () async {
                    await _instructorProvider?.updateInstructor({'gender': g});
                    Navigator.pop(context);
                    if (!mounted) return;
                    _showSnackBar(
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

  // Country code to display name mapping
  final Map<String, String> countryNames = {
    'usa': 'United States',
    'spain': 'Spain',
    'japan': 'Japan',
    'korea': 'South Korea',
    'bangladesh': 'Bangladesh',
  };

  String getCountryName(String code) {
    return countryNames[code.toLowerCase()] ?? code;
  }

  String getGenderDisplayName(String genderCode) {
    switch (genderCode.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return genderCode;
    }
  }

  void _showSnackBar(SnackBar snackBar) {
    if (!mounted || _scaffoldMessenger == null) return;
    _scaffoldMessenger!.showSnackBar(snackBar);
  }

  Future<bool> _safeUpdate(Map<String, dynamic> updates) async {
    if (_instructorProvider == null) return false;
    try {
      return await _instructorProvider!.updateInstructor(updates);
    } catch (e) {
      _showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  void _showCountryDialog() {
    final instructor = Provider.of<InstructorProvider>(
      context,
      listen: false,
    ).currentInstructor!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Country'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: countries
              .map(
                (code) => ListTile(
                  title: Text(getCountryName(code)),
                  trailing:
                      instructor.country.toLowerCase() == code.toLowerCase()
                      ? Icon(Icons.check, color: const Color(0xFF7A54FF))
                      : null,
                  onTap: () async {
                    Navigator.pop(context);
                    final success = await _safeUpdate({'country': code});
                    if (success) {
                      if (!mounted) return;
                      _showSnackBar(
                        const SnackBar(
                          content: Text('Country updated successfully'),
                        ),
                      );
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showPasswordChangeDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isCurrentPasswordVisible = false;
    bool isNewPasswordVisible = false;
    bool isConfirmPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: !isCurrentPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isCurrentPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isCurrentPasswordVisible = !isCurrentPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: !isNewPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isNewPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isNewPasswordVisible = !isNewPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: !isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isConfirmPasswordVisible = !isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  _showSnackBar(
                    const SnackBar(
                      content: Text('New passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (newPasswordController.text.isEmpty) {
                  _showSnackBar(
                    const SnackBar(
                      content: Text('Password cannot be empty'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Update password using instructor provider
                  final success = await _safeUpdate({
                    'password': newPasswordController.text,
                  });

                  if (success) {
                    Navigator.pop(context);
                    if (!mounted) return;
                    _showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  _showSnackBar(
                    SnackBar(
                      content: Text('Failed to update password: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                'Update',
                style: TextStyle(color: const Color(0xFF7A54FF)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadAndUpdateProfileImage(image);
      }
    } catch (e) {
      _showSnackBar(
        SnackBar(
          content: Text('Failed to take photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadAndUpdateProfileImage(image);
      }
    } catch (e) {
      _showSnackBar(
        SnackBar(
          content: Text('Failed to select image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadAndUpdateProfileImage(XFile imageFile) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final bytes = await File(imageFile.path).readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'profile_images/$fileName';

      // Upload to Supabase Storage
      await SupabaseConfig.client.storage
          .from('profile_pics')
          .uploadBinary(filePath, bytes);

      // Get public URL
      final imageUrl = SupabaseConfig.client.storage
          .from('profile_pics')
          .getPublicUrl(filePath);

      // Update instructor profile
      await _instructorProvider?.updateInstructor({'profile_image': imageUrl});

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      _showSnackBar(
        const SnackBar(
          content: Text('Profile image updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      _showSnackBar(
        SnackBar(
          content: Text('Failed to update profile image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showExperienceDialog() {
    final instructor = Provider.of<InstructorProvider>(
      context,
      listen: false,
    ).currentInstructor!;
    int selectedExperience = instructor.yearsOfExperience;

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
            onPressed: () async {
              Navigator.pop(context);
              final success = await _safeUpdate({
                'years_of_experience': selectedExperience,
              });
              if (success) {
                if (!mounted) return;
                _showSnackBar(
                  const SnackBar(
                    content: Text('Experience updated successfully'),
                  ),
                );
              }
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
            onPressed: () async {
              try {
                await SupabaseConfig.client.auth.signOut();
                _instructorProvider?.clear();

                if (mounted) {
                  Navigator.pop(context);
                  // Navigate to landing page and clear all previous routes
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  _showSnackBar(
                    SnackBar(content: Text('Error logging out: $e')),
                  );
                }
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
