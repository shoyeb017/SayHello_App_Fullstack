import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

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
  String nativeLanguage = '', learningLanguage = '';
  double skillLevel = 0.0;
  DateTime? dob;
  String gender = '', country = '', bio = '';
  List<String> interests = [];
  File? profileImage;

  final languageOptions = ['English', 'Arabic', 'Japanese', 'Bangla', 'Korean'];
  final genderOptions = ['Male', 'Female', 'Other'];
  final countryOptions = [
    'Bangladesh',
    'USA',
    'Japan',
    'Korea',
    'Saudi Arabia',
    'Other',
  ];
  final allInterests = [
    'Music',
    'Travel',
    'Books',
    'Gaming',
    'Cooking',
    'Movies',
    'Photography',
    'Fitness',
    'Art',
    'Others',
  ];

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

  void submitForm() {
    if (_formKeys[2].currentState!.validate()) {
      for (var key in _formKeys) {
        key.currentState!.save();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Learner Registered Successfully!')),
      );
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
                          const Text(
                            'Step 1: Personal Info',
                            style: TextStyle(
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
                            'Full Name',
                            (val) => name = val ?? '',
                            Icons.person,
                            fontSize: 14,
                            paddingVertical: 8,
                          ),
                          _inputField(
                            'Email',
                            (val) => email = val ?? '',
                            Icons.email,
                            inputType: TextInputType.emailAddress,
                            fontSize: 14,
                            paddingVertical: 8,
                          ),
                          _inputField(
                            'Username',
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
                            child: const Text(
                              'Next',
                              style: TextStyle(
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
                          const Text(
                            'Step 2: Language Info',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _dropdown(
                            'Native Language',
                            nativeLanguage,
                            languageOptions,
                            (val) => setState(() => nativeLanguage = val),
                            fontSize: 14,
                          ),
                          _dropdown(
                            'Learning Language',
                            learningLanguage,
                            languageOptions,
                            (val) => setState(() => learningLanguage = val),
                            fontSize: 14,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Skill Level',
                            style: TextStyle(fontSize: 14),
                          ),
                          Slider(
                            value: skillLevel,
                            divisions: 4,
                            label: [
                              'Beginner',
                              'Basic',
                              'Intermediate',
                              'Advanced',
                              'Fluent',
                            ][skillLevel.toInt()],
                            onChanged: (val) =>
                                setState(() => skillLevel = val),
                            min: 0,
                            max: 4,
                            activeColor: primaryColor,
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
                                child: const Text(
                                  'Back',
                                  style: TextStyle(fontSize: 14),
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
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
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
                          const Text(
                            'Step 3: Additional Info',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _dropdown(
                            'Gender',
                            gender,
                            genderOptions,
                            (val) => setState(() => gender = val),
                            fontSize: 14,
                          ),
                          _dropdown(
                            'Country',
                            country,
                            countryOptions,
                            (val) => setState(() => country = val),
                            fontSize: 14,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Bio',
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
                          const Text(
                            'Date of Birth',
                            style: TextStyle(fontSize: 14),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(
                              Icons.calendar_today,
                              color: primaryColor,
                              size: 18,
                            ),
                            label: Text(
                              dob == null
                                  ? 'Choose DOB'
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
                          const Text(
                            'Select Interests',
                            style: TextStyle(fontSize: 14),
                          ),
                          Wrap(
                            spacing: 8,
                            children: allInterests.map((interest) {
                              final selected = interests.contains(interest);
                              return FilterChip(
                                label: Text(
                                  interest,
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
                                child: const Text(
                                  'Back',
                                  style: TextStyle(fontSize: 14),
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
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
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
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
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
                labelText: 'Password',
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
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
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
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
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
