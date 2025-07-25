import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class InstructorSignupPage extends StatefulWidget {
  const InstructorSignupPage({super.key});

  @override
  State<InstructorSignupPage> createState() => _InstructorSignupPageState();
}

class _InstructorSignupPageState extends State<InstructorSignupPage> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  int currentStep = 0;

  String name = '', bio = '', gender = '', country = '';
  DateTime? dateOfBirth;
  String nativeLanguage = '', learningLanguage = '';
  File? profileImage;

  List<String> get languageOptions => [
    AppLocalizations.of(context)!.english,
    AppLocalizations.of(context)!.arabic,
    AppLocalizations.of(context)!.japanese,
    AppLocalizations.of(context)!.bangla,
    AppLocalizations.of(context)!.korean,
  ];

  List<String> get genderOptions => [
    AppLocalizations.of(context)!.male,
    AppLocalizations.of(context)!.female,
    AppLocalizations.of(context)!.other,
  ];

  List<String> get countryOptions => [
    AppLocalizations.of(context)!.bangladesh,
    AppLocalizations.of(context)!.usa,
    AppLocalizations.of(context)!.uk,
    AppLocalizations.of(context)!.india,
    AppLocalizations.of(context)!.japan,
    AppLocalizations.of(context)!.others,
  ];

  final Color primaryColor = const Color(0xFF7A54FF);
  final Color offWhite = const Color(0xFFF5F5F5);

  Color get inputFieldColor => Theme.of(context).brightness == Brightness.dark
      ? Colors.grey[800]!
      : const Color(0xFFF0F0F0);

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => profileImage = File(pickedFile.path));
    }
  }

  void nextStep() {
    if (_formKeyStep1.currentState!.validate()) {
      _formKeyStep1.currentState!.save();
      setState(() => currentStep++);
    }
  }

  void previousStep() {
    setState(() => currentStep--);
  }

  void submitForm() {
    if (_formKeyStep2.currentState!.validate()) {
      _formKeyStep2.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.instructorRegisteredSuccessfully,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              bool toDark = themeProvider.themeMode != ThemeMode.dark;
              themeProvider.toggleTheme(toDark);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: currentStep,
        children: [_buildStep1(), _buildStep2()],
      ),
    );
  }

  Widget _buildStep1() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKeyStep1,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              AppLocalizations.of(context)!.step1PersonalInfo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : null,
                    child: profileImage == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: primaryColor),
                      onPressed: pickImage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _inputField(
              AppLocalizations.of(context)!.fullName,
              (val) => name = val ?? '',
            ),
            const SizedBox(height: 12),

            _dropdown(
              AppLocalizations.of(context)!.gender,
              gender,
              genderOptions,
              (val) => setState(() => gender = val),
            ),
            const SizedBox(height: 12),

            _dropdown(
              AppLocalizations.of(context)!.country,
              country,
              countryOptions,
              (val) => setState(() => country = val),
            ),
            const SizedBox(height: 12),

            Text(
              AppLocalizations.of(context)!.dateOfBirth,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: inputFieldColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.calendar_today, size: 18, color: primaryColor),
              label: Text(
                dateOfBirth == null
                    ? AppLocalizations.of(context)!.chooseDOB
                    : '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}',
                style: TextStyle(color: primaryColor, fontSize: 14),
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => dateOfBirth = picked);
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: nextStep,
              child: Text(
                AppLocalizations.of(context)!.next,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKeyStep2,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              AppLocalizations.of(context)!.step2LanguageBio,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _dropdown(
              AppLocalizations.of(context)!.nativeLanguage,
              nativeLanguage,
              languageOptions,
              (val) => setState(() => nativeLanguage = val),
            ),
            const SizedBox(height: 12),

            _dropdown(
              AppLocalizations.of(context)!.teachingLanguage,
              learningLanguage,
              languageOptions,
              (val) => setState(() => learningLanguage = val),
            ),
            const SizedBox(height: 12),

            TextFormField(
              maxLines: 4,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.bioOptional,
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
                alignLabelWithHint: true,
                fillColor: inputFieldColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onSaved: (val) => bio = val ?? '',
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
                      borderRadius: BorderRadius.circular(24),
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
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: submitForm,
                  child: Text(
                    AppLocalizations.of(context)!.submit,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, FormFieldSetter<String> onSave) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[700],
        ),
        filled: true,
        fillColor: inputFieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      onSaved: onSave,
      validator: (val) => val == null || val.isEmpty
          ? AppLocalizations.of(context)!.required
          : null,
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[700],
        ),
        filled: true,
        fillColor: inputFieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      dropdownColor: isDark ? Colors.grey[800] : Colors.white,
      value: value.isNotEmpty ? value : null,
      icon: Icon(
        Icons.arrow_drop_down,
        color: isDark ? Colors.grey[400] : Colors.grey[700],
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          )
          .toList(),
      onChanged: (val) => onChanged(val ?? ''),
      validator: (val) =>
          val == null ? AppLocalizations.of(context)!.required : null,
    );
  }
}
