import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class LearnerSignupPage extends StatefulWidget {
  const LearnerSignupPage({super.key});

  @override
  State<LearnerSignupPage> createState() => _LearnerSignupPageState();
}

class _LearnerSignupPageState extends State<LearnerSignupPage> {
  int currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Fields
  String name = '', email = '', username = '', password = '';
  String nativeLanguage = '', learningLanguage = '';
  double skillLevel = 0.0;
  DateTime? dob;
  String gender = '', country = '', bio = '';
  List<String> interests = [];
  File? profileImage;

  final languageOptions = ['English', 'Arabic', 'Japanese', 'Bangla', 'Korean'];
  final genderOptions = ['Male', 'Female', 'Other'];
  final countryOptions = ['Bangladesh', 'USA', 'Japan', 'Korea', 'Saudi Arabia', 'Other'];
  final allInterests = [
    'Music', 'Travel', 'Books', 'Gaming', 'Cooking', 'Movies', 'Photography', 'Fitness', 'Art', 'Others'
  ];

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  void nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() => currentStep++);
    }
  }

  void previousStep() => setState(() => currentStep--);

  void submitForm() {
    _formKey.currentState!.save();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Learner Registered Successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelStyle = TextStyle(color: isDark ? Colors.white70 : Colors.grey[800]);

    return Scaffold(
      appBar: AppBar(title: const Text('SayHello - Learner Sign Up')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              StepProgressIndicator(currentStep: currentStep),
              const SizedBox(height: 16),
              Expanded(
                child: IndexedStack(
                  index: currentStep,
                  children: [
                    // STEP 1: Personal Info
                    ListView(
                      children: [
                        const Text('Step 1: Personal Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                            child: profileImage == null
                                ? const Icon(Icons.camera_alt, size: 40)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Full Name', labelStyle: labelStyle),
                          onSaved: (val) => name = val ?? '',
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Email', labelStyle: labelStyle),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (val) => email = val ?? '',
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Username (Unchangeable)', labelStyle: labelStyle),
                          onSaved: (val) => username = val ?? '',
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(labelText: 'Password', labelStyle: labelStyle),
                          onSaved: (val) => password = val ?? '',
                          validator: (val) => val!.length < 6 ? 'Min 6 characters' : null,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(onPressed: nextStep, child: const Text('Next')),
                      ],
                    ),

                    // STEP 2: Language Info
                    ListView(
                      children: [
                        const Text('Step 2: Language Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Native Language (Unchangeable)'),
                          value: nativeLanguage.isNotEmpty ? nativeLanguage : null,
                          items: languageOptions
                              .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                              .toList(),
                          onChanged: (val) => setState(() => nativeLanguage = val ?? ''),
                          validator: (val) => val == null ? 'Required' : null,
                        ),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Learning Language (Unchangeable)'),
                          value: learningLanguage.isNotEmpty ? learningLanguage : null,
                          items: languageOptions
                              .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                              .toList(),
                          onChanged: (val) => setState(() => learningLanguage = val ?? ''),
                          validator: (val) => val == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        const Text('Skill Level'),
                        Slider(
                          value: skillLevel,
                          divisions: 4,
                          label: ['Beginner', 'Basic', 'Intermediate', 'Advanced', 'Fluent'][skillLevel.toInt()],
                          onChanged: (val) => setState(() => skillLevel = val),
                          min: 0,
                          max: 4,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(onPressed: previousStep, child: const Text('Back')),
                            ElevatedButton(onPressed: nextStep, child: const Text('Next')),
                          ],
                        )
                      ],
                    ),

                    // STEP 3: More Info
                    ListView(
                      children: [
                        const Text('Step 3: Additional Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Gender'),
                          value: gender.isNotEmpty ? gender : null,
                          items: genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (val) => setState(() => gender = val ?? ''),
                        ),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Country'),
                          value: country.isNotEmpty ? country : null,
                          items: countryOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) => setState(() => country = val ?? ''),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Bio'),
                          maxLines: 3,
                          onSaved: (val) => bio = val ?? '',
                        ),
                        const SizedBox(height: 16),
                        const Text('Date of Birth'),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                            );
                            setState(() => dob = picked);
                          },
                          child: Text(dob == null
                              ? 'Choose DOB'
                              : '${dob!.day}/${dob!.month}/${dob!.year}'),
                        ),
                        const SizedBox(height: 16),
                        const Text('Select Interests'),
                        Wrap(
                          spacing: 8,
                          children: allInterests.map((interest) {
                            final selected = interests.contains(interest);
                            return FilterChip(
                              label: Text(interest),
                              selected: selected,
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    interests.add(interest);
                                  } else {
                                    interests.remove(interest);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(onPressed: previousStep, child: const Text('Back')),
                            ElevatedButton(onPressed: submitForm, child: const Text('Submit')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------
// Progress Indicator Widget
// --------------------------
class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  const StepProgressIndicator({super.key, required this.currentStep});

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
            color: currentStep >= index ? Colors.purple : Colors.grey[400],
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}
