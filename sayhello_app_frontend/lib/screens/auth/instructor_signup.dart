import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  final List<String> languageOptions = ['English', 'Arabic', 'Japanese', 'Bangla', 'Korean'];
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> countryOptions = ['Bangladesh', 'USA', 'UK', 'India', 'Japan', 'Others'];

  final Color primaryColor = const Color(0xFF7A54FF);
  final Color offWhite = const Color(0xFFF5F5F5);
  final Color inputFieldColor = const Color(0xFFF0F0F0);

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
        const SnackBar(content: Text('Instructor Registered Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: IndexedStack(
        index: currentStep,
        children: [
          _buildStep1(),
          _buildStep2(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Form(
        key: _formKeyStep1,
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text("Step 1: Personal Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                    child: profileImage == null ? const Icon(Icons.person, size: 40) : null,
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

            _inputField('Full Name', (val) => name = val ?? ''),
            const SizedBox(height: 12),

            _dropdown('Gender', gender, genderOptions, (val) => setState(() => gender = val)),
            const SizedBox(height: 12),

            _dropdown('Country', country, countryOptions, (val) => setState(() => country = val)),
            const SizedBox(height: 12),

            const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: inputFieldColor,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              icon: Icon(Icons.calendar_today, size: 18, color: primaryColor),
              label: Text(
                dateOfBirth == null
                    ? 'Choose DOB'
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: nextStep,
              child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Form(
        key: _formKeyStep2,
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text("Step 2: Language & Bio", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _dropdown('Native Language', nativeLanguage, languageOptions, (val) => setState(() => nativeLanguage = val)),
            const SizedBox(height: 12),

            _dropdown('Teaching Language', learningLanguage, languageOptions, (val) => setState(() => learningLanguage = val)),
            const SizedBox(height: 12),

            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Bio (Optional)',
                alignLabelWithHint: true,
                fillColor: inputFieldColor,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: const TextStyle(fontSize: 14),
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
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Back', style: TextStyle(fontSize: 14)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: submitForm,
                  child: const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, FormFieldSetter<String> onSave) {
    return TextFormField(
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: inputFieldColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      onSaved: onSave,
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  Widget _dropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: inputFieldColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      value: value.isNotEmpty ? value : null,
      icon: const Icon(Icons.arrow_drop_down),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (val) => onChanged(val ?? ''),
      validator: (val) => val == null ? 'Required' : null,
    );
  }
}
