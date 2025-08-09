import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/learner.dart';
import '../../providers/learner_provider.dart';
import '../../providers/settings_provider.dart';

class LearnerSignupPage extends StatefulWidget {
  const LearnerSignupPage({super.key});

  @override
  State<LearnerSignupPage> createState() => _LearnerSignupPageState();
}

class _LearnerSignupPageState extends State<LearnerSignupPage> {
  int currentStep = 0;
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  String name = '', email = '', username = '', password = '';
  String nativeLanguage = '', learningLanguage = '', languageLevel = '';
  DateTime? dob;
  String gender = '', country = '', bio = '';
  List<String> interests = [];
  File? profileImage;

  final languageOptions = [
    'English',
    'Spanish',
    'Japanese',
    'Korean',
    'Bangla',
  ];

  List<String> get genderOptions => [
    AppLocalizations.of(context)!.male,
    AppLocalizations.of(context)!.female,
  ];

  List<String> get countryOptions => [
    AppLocalizations.of(context)!.usa,
    'Spain',
    AppLocalizations.of(context)!.japan,
    AppLocalizations.of(context)!.korea,
    AppLocalizations.of(context)!.bangladesh,
  ];

  final languageLevelOptions = [
    'Beginner',
    'Elementary',
    'Intermediate',
    'Advanced',
    'Proficient',
  ];
  List<String> get languageLevelOptionsLocalized => [
    AppLocalizations.of(context)!.beginner,
    'Elementary',
    AppLocalizations.of(context)!.intermediate,
    AppLocalizations.of(context)!.advanced,
    'Proficient',
  ];

  final allInterests = [
    'Art',
    'Music',
    'Reading',
    'Writing',
    'Sports',
    'Gaming',
    'Travel',
    'Cooking',
    'Fashion',
    'Photography',
    'Crafting',
    'Gardening',
    'Fitness',
    'Movies',
    'Technology',
    'Nature',
    'Animals',
    'Science',
    'Socializing',
  ];

  List<String> getLocalizedInterests() {
    return [
      AppLocalizations.of(context)!.art,
      AppLocalizations.of(context)!.music,
      'Reading',
      'Writing',
      'Sports',
      AppLocalizations.of(context)!.gaming,
      AppLocalizations.of(context)!.travel,
      AppLocalizations.of(context)!.cooking,
      'Fashion',
      AppLocalizations.of(context)!.photography,
      'Crafting',
      'Gardening',
      AppLocalizations.of(context)!.fitness,
      AppLocalizations.of(context)!.movies,
      'Technology',
      'Nature',
      'Animals',
      'Science',
      'Socializing',
    ];
  }

  final Color primaryColor = const Color(0xFF7A54FF);

  Color get grayBackground => Theme.of(context).brightness == Brightness.dark
      ? Colors.grey[800]!
      : const Color(0xFFF0F0F0);

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => profileImage = File(picked.path));
  }

  void nextStep() {
    if (_formKeys[currentStep].currentState!.validate()) {
      if (currentStep < 2) setState(() => currentStep++);
    }
  }

  void previousStep() => setState(() => currentStep--);

  void submitForm() async {
    if (_formKeys[2].currentState!.validate()) {
      for (var key in _formKeys) {
        key.currentState!.save();
      }
      // Prepare Learner data
      final learner = Learner(
        id: '', // Supabase will generate
        profileImage:
            'https://wallpapers.com/images/hd/anime-pictures-bj226rrdwe326upu.jpg', // Always use dummy link
        name: name,
        email: email,
        username: username,
        password: password,
        dateOfBirth: dob ?? DateTime(2000, 1, 1),
        gender: gender.toLowerCase(), // Convert to lowercase for database
        country: country.toLowerCase(), // Convert to lowercase for database
        bio: bio.isNotEmpty ? bio : null,
        nativeLanguage: nativeLanguage
            .toLowerCase(), // Convert to lowercase for database
        learningLanguage: learningLanguage
            .toLowerCase(), // Convert to lowercase for database
        languageLevel: languageLevel
            .toLowerCase(), // Convert to lowercase for database
        interests: interests,
        createdAt: DateTime.now(),
      );
      // Insert into Supabase via Provider
      final learnerProvider = Provider.of<LearnerProvider>(
        context,
        listen: false,
      );

      try {
        print('Attempting to create learner with data:');
        print('Name: $name');
        print('Email: $email');
        print('Username: $username');
        print('Gender: $gender');
        print('Country: $country');
        print('Native Language: $nativeLanguage');
        print('Learning Language: $learningLanguage');
        print('Language Level: $languageLevel');

        final success = await learnerProvider.createLearner(learner);
        print('Provider createLearner result: $success');
        print('Provider error state: ${learnerProvider.error}');

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.learnerRegisteredSuccessfully,
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          final error = learnerProvider.error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to register learner'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          print('Registration failed. Provider error: $error');
        }
      } catch (e) {
        print('Exception during registration: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : const Color(0xFFF5F5F5);
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final BoxDecoration cardDecoration = BoxDecoration(
      color: cardColor,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black26 : Colors.black12,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            onPressed: () => SettingsProvider.showSettingsBottomSheet(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          children: [
            StepProgressIndicator(
              currentStep: currentStep,
              color: primaryColor,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: IndexedStack(
                index: currentStep,
                children: [
                  // PHASE 1
                  Form(
                    key: _formKeys[0],
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: cardDecoration,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.step1PersonalInfo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: GestureDetector(
                              onTap: pickImage,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: profileImage != null
                                    ? FileImage(profileImage!)
                                    : null,
                                child: profileImage == null
                                    ? const Icon(
                                        Icons.camera_alt,
                                        size: 30,
                                        color: Colors.grey,
                                      )
                                    : null,
                                backgroundColor: Colors.grey[200],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _inputField(
                            AppLocalizations.of(context)!.name,
                            (val) => name = val ?? '',
                            Icons.person,
                            fontSize: 14,
                            paddingVertical: 8,
                          ),
                          _inputField(
                            AppLocalizations.of(context)!.email,
                            (val) => email = val ?? '',
                            Icons.email,
                            inputType: TextInputType.emailAddress,
                            fontSize: 14,
                            paddingVertical: 8,
                          ),
                          _inputField(
                            AppLocalizations.of(context)!.username,
                            (val) => username = val ?? '',
                            Icons.account_circle,
                            fontSize: 14,
                            paddingVertical: 8,
                          ),
                          _passwordField(),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: nextStep,
                            child: Text(
                              AppLocalizations.of(context)!.next,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // PHASE 2
                  Form(
                    key: _formKeys[1],
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: cardDecoration,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.step2LanguageInfo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _dropdown(
                            AppLocalizations.of(context)!.nativeLanguageShort,
                            nativeLanguage,
                            languageOptions,
                            (val) => setState(() => nativeLanguage = val),
                            fontSize: 14,
                          ),
                          _dropdown(
                            AppLocalizations.of(context)!.learningLanguageShort,
                            learningLanguage,
                            languageOptions,
                            (val) => setState(() => learningLanguage = val),
                            fontSize: 14,
                          ),
                          _dropdown(
                            'Language Level',
                            languageLevel,
                            languageLevelOptionsLocalized,
                            (val) => setState(() => languageLevel = val),
                            fontSize: 14,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton(
                                onPressed: previousStep,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: BorderSide(color: primaryColor),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.back,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: nextStep,
                                child: Text(
                                  AppLocalizations.of(context)!.next,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // PHASE 3
                  Form(
                    key: _formKeys[2],
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: cardDecoration,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.step3AdditionalInfo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _dropdown(
                            AppLocalizations.of(context)!.gender,
                            gender,
                            genderOptions,
                            (val) => setState(() => gender = val),
                            fontSize: 14,
                          ),
                          _dropdown(
                            AppLocalizations.of(context)!.country,
                            country,
                            countryOptions,
                            (val) => setState(() => country = val),
                            fontSize: 14,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.bio,
                              filled: true,
                              fillColor: grayBackground,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            maxLines: 3,
                            style: const TextStyle(fontSize: 14),
                            onSaved: (val) => bio = val ?? '',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.dateOfBirth,
                            style: const TextStyle(fontSize: 14),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(
                              Icons.calendar_today,
                              color: primaryColor,
                              size: 18,
                            ),
                            label: Text(
                              dob == null
                                  ? AppLocalizations.of(context)!.chooseDOB
                                  : '${dob!.day}/${dob!.month}/${dob!.year}',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: grayBackground,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) setState(() => dob = picked);
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.selectInterests,
                            style: const TextStyle(fontSize: 14),
                          ),
                          Wrap(
                            spacing: 8,
                            children: allInterests.asMap().entries.map((entry) {
                              final index = entry.key;
                              final interest = entry.value;
                              final localizedInterest =
                                  getLocalizedInterests()[index];
                              final selected = interests.contains(interest);
                              return FilterChip(
                                label: Text(
                                  localizedInterest,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                selected: selected,
                                selectedColor: primaryColor.withOpacity(0.2),
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      interests.add(interest);
                                    } else {
                                      interests.remove(interest);
                                    }
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton(
                                onPressed: previousStep,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: BorderSide(color: primaryColor),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.back,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: submitForm,
                                child: Text(
                                  AppLocalizations.of(context)!.submit,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    FormFieldSetter<String> onSave,
    IconData icon, {
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    double fontSize = 16,
    double paddingVertical = 12,
    String? initialValue,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: paddingVertical),
      child: Container(
        decoration: BoxDecoration(
          color: grayBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextFormField(
          initialValue: initialValue,
          obscureText: isPassword,
          keyboardType: inputType,
          style: TextStyle(
            fontSize: fontSize,
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
            prefixIcon: Icon(icon, size: fontSize + 4, color: primaryColor),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
          ),
          onSaved: onSave,
          validator: (val) => val == null || val.isEmpty
              ? AppLocalizations.of(context)!.required
              : null,
        ),
      ),
    );
  }

  Widget _passwordField() {
    return StatefulBuilder(
      builder: (context, setStateSB) {
        bool _obscure = true;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: grayBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextFormField(
              obscureText: _obscure,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password,
                prefixIcon: Icon(Icons.lock, color: primaryColor, size: 18),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: primaryColor,
                  ),
                  onPressed: () => setStateSB(() => _obscure = !_obscure),
                ),
              ),
              onSaved: (val) => password = val ?? '',
              validator: (val) => val == null || val.isEmpty
                  ? AppLocalizations.of(context)!.required
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged, {
    double fontSize = 16,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
          filled: true,
          fillColor: grayBackground,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(
          fontSize: fontSize,
          color: isDark ? Colors.white : Colors.black87,
        ),
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        value: value.isNotEmpty ? value : null,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (val) => onChanged(val ?? ''),
        validator: (val) => val == null || val.isEmpty
            ? AppLocalizations.of(context)!.required
            : null,
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final Color color;
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const totalSteps = 3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentStep == index ? 30 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: currentStep >= index ? color : Colors.grey[400],
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}
