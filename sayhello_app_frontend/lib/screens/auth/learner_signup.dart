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
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];

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
  final allInterests = ['Music', 'Travel', 'Books', 'Gaming', 'Cooking', 'Movies', 'Photography', 'Fitness', 'Art', 'Others'];

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
      _formKeys.forEach((key) => key.currentState!.save());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Learner Registered Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7A54FF);
    const offWhite = Color(0xFFF5F5F5);
    const whiteBoxDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(12)),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
    );

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          children: [
            StepProgressIndicator(currentStep: currentStep, color: primaryColor),
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
                      decoration: whiteBoxDecoration,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          const Text('Step 1: Personal Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Center(
                            child: GestureDetector(
                              onTap: pickImage,
                              child: CircleAvatar(
                                radius: 40, // smaller radius
                                backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                                child: profileImage == null ? const Icon(Icons.camera_alt, size: 30, color: Colors.grey) : null,
                                backgroundColor: Colors.grey[200],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _inputField('Full Name', (val) => name = val!, Icons.person, fontSize: 14, paddingVertical: 8),
                          _inputField('Email', (val) => email = val!, Icons.email, inputType: TextInputType.emailAddress, fontSize: 14, paddingVertical: 8),
                          _inputField('Username (Unchangeable)', (val) => username = val!, Icons.account_circle, fontSize: 14, paddingVertical: 8),
                          _inputField('Password', (val) => password = val!, Icons.lock, isPassword: true, fontSize: 14, paddingVertical: 8),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: nextStep,
                            child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                      decoration: whiteBoxDecoration,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          const Text('Step 2: Language Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _dropdown('Native Language', nativeLanguage, languageOptions, (val) => setState(() => nativeLanguage = val), fontSize: 14),
                          _dropdown('Learning Language', learningLanguage, languageOptions, (val) => setState(() => learningLanguage = val), fontSize: 14),
                          const SizedBox(height: 12),
                          const Text('Skill Level', style: TextStyle(fontSize: 14)),
                          Slider(
                            value: skillLevel,
                            divisions: 4,
                            label: ['Beginner', 'Basic', 'Intermediate', 'Advanced', 'Fluent'][skillLevel.toInt()],
                            onChanged: (val) => setState(() => skillLevel = val),
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
                                  side: const BorderSide(color: primaryColor),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Back', style: TextStyle(fontSize: 14)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: nextStep,
                                child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                      decoration: whiteBoxDecoration,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          const Text('Step 3: Additional Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _dropdown('Gender', gender, genderOptions, (val) => setState(() => gender = val), fontSize: 14),
                          _dropdown('Country', country, countryOptions, (val) => setState(() => country = val), fontSize: 14),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Bio',
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            style: const TextStyle(fontSize: 14),
                            onSaved: (val) => bio = val ?? '',
                          ),
                          const SizedBox(height: 12),
                          const Text('Date of Birth', style: TextStyle(fontSize: 14)),
                          ElevatedButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) setState(() => dob = picked);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              dob == null
                                  ? 'Choose DOB'
                                  : '${dob!.day}/${dob!.month}/${dob!.year}',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('Select Interests', style: TextStyle(fontSize: 14)),
                          Wrap(
                            spacing: 8,
                            children: allInterests.map((interest) {
                              final selected = interests.contains(interest);
                              return FilterChip(
                                label: Text(interest, style: const TextStyle(fontSize: 13)),
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
                                  side: const BorderSide(color: primaryColor),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Back', style: TextStyle(fontSize: 14)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: submitForm,
                                child: const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16)),
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

  Widget _inputField(String label, FormFieldSetter<String> onSave, IconData icon,
      {bool isPassword = false,
      TextInputType inputType = TextInputType.text,
      double fontSize = 16,
      double paddingVertical = 12}) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingVertical),
      child: TextFormField(
        obscureText: isPassword,
        keyboardType: inputType,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: fontSize + 4),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
        onSaved: onSave,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items, Function(String) onChanged,
      {double fontSize = 16}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
        style: TextStyle(fontSize: fontSize, color: Colors.black87),
        value: value.isNotEmpty ? value : null,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (val) => onChanged(val ?? ''),
        validator: (val) => val == null ? 'Required' : null,
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final Color color;
  const StepProgressIndicator({super.key, required this.currentStep, required this.color});

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
