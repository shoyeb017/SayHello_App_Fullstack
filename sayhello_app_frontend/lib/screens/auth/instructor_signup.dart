import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InstructorSignupPage extends StatefulWidget {
  const InstructorSignupPage({super.key});

  @override
  State<InstructorSignupPage> createState() => _InstructorSignupPageState();
}

class _InstructorSignupPageState extends State<InstructorSignupPage> {
  final _formKey = GlobalKey<FormState>();
  int currentStep = 0;

  String name = '', bio = '', gender = '', country = '';
  DateTime? dateOfBirth;
  String nativeLanguage = '', learningLanguage = '';
  File? profileImage;

  final List<String> languageOptions = ['English', 'Arabic', 'Japanese', 'Bangla', 'Korean'];
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> countryOptions = ['Bangladesh', 'USA', 'UK', 'India', 'Japan', 'Others'];

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => profileImage = File(pickedFile.path));
    }
  }

  void nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() => currentStep++);
    }
  }

  void previousStep() {
    setState(() => currentStep--);
  }

  void submitForm() {
    _formKey.currentState!.save();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Instructor Registered Successfully!')),
    );
  }

  Widget buildStep1() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Step 1: Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                child: profileImage == null ? const Icon(Icons.person, size: 50) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.blue),
                  onPressed: pickImage,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        TextFormField(
          decoration: const InputDecoration(labelText: 'Full Name'),
          onSaved: (val) => name = val ?? '',
          validator: (val) => val!.isEmpty ? 'Required' : null,
        ),

        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Gender'),
          value: gender.isEmpty ? null : gender,
          items: genderOptions.map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
          onChanged: (val) => setState(() => gender = val ?? ''),
          validator: (val) => val == null ? 'Select gender' : null,
        ),

        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Country'),
          value: country.isEmpty ? null : country,
          items: countryOptions.map((country) => DropdownMenuItem(value: country, child: Text(country))).toList(),
          onChanged: (val) => setState(() => country = val ?? ''),
          validator: (val) => val == null ? 'Select country' : null,
        ),

        const SizedBox(height: 16),
        const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.w600)),
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text(dateOfBirth == null
              ? 'Choose DOB'
              : '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}'),
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

        const SizedBox(height: 24),
        ElevatedButton(onPressed: nextStep, child: const Text('Next')),
      ],
    );
  }

  Widget buildStep2() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Step 2: Language & Bio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Native Language'),
          value: nativeLanguage.isEmpty ? null : nativeLanguage,
          items: languageOptions.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
          onChanged: (val) => setState(() => nativeLanguage = val ?? ''),
          validator: (val) => val == null ? 'Select native language' : null,
        ),

        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Teaching Language'),
          value: learningLanguage.isEmpty ? null : learningLanguage,
          items: languageOptions.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
          onChanged: (val) => setState(() => learningLanguage = val ?? ''),
          validator: (val) => val == null ? 'Select teaching language' : null,
        ),

        const SizedBox(height: 16),
        TextFormField(
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Bio (Optional)',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          onSaved: (val) => bio = val ?? '',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instructor Sign Up')),
      body: Form(
        key: _formKey,
        child: IndexedStack(
          index: currentStep,
          children: [buildStep1(), buildStep2()],
        ),
      ),
    );
  }
}
