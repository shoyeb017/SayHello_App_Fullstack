import 'package:flutter/material.dart';

class LearnerSignupPage extends StatefulWidget {
  const LearnerSignupPage({super.key});

  @override
  State<LearnerSignupPage> createState() => _LearnerSignupPageState();
}

class _LearnerSignupPageState extends State<LearnerSignupPage> {
  int currentStep = 0;

  final _formKey = GlobalKey<FormState>();

  // Step 1
  String name = '', email = '', username = '', password = '';

  // Step 2
  String nativeLanguage = '', learningLanguage = '', skillLevel = '';

  // Step 3
  DateTime? dateOfBirth;
  String gender = '', country = '', bio = '';
  List<String> interests = [];
  final List<String> allInterests = [
    'Music', 'Travel', 'Books', 'Gaming', 'Cooking', 'Movies', 'Photography', 'Art', 'Fitness', 'Others'
  ];

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
    // Handle actual signup logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Learner Registered Successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Learner Sign Up')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IndexedStack(
            index: currentStep,
            children: [
              // Step 1: Personal Info
              ListView(
                children: [
                  const Text('Step 1: Personal Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    onSaved: (val) => name = val ?? '',
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (val) => email = val ?? '',
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Username (Unchangeable)'),
                    onSaved: (val) => username = val ?? '',
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    onSaved: (val) => password = val ?? '',
                    validator: (val) => val!.length < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: nextStep, child: const Text('Next')),
                ],
              ),

              // Step 2: Language Info
              ListView(
                children: [
                  const Text('Step 2: Language Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Native Language (Unchangeable)'),
                    onSaved: (val) => nativeLanguage = val ?? '',
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Learning Language (Unchangeable)'),
                    onSaved: (val) => learningLanguage = val ?? '',
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Skill Level (e.g. Beginner, Intermediate)'),
                    onSaved: (val) => skillLevel = val ?? '',
                    validator: (val) => val!.isEmpty ? 'Required' : null,
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

              // Step 3: More Info
              ListView(
                children: [
                  const Text('Step 3: Profile Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Bio'),
                    onSaved: (val) => bio = val ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Country'),
                    onSaved: (val) => country = val ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    onSaved: (val) => gender = val ?? '',
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
                      setState(() => dateOfBirth = picked);
                    },
                    child: Text(dateOfBirth == null
                        ? 'Choose DOB'
                        : '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Interests (multiple):'),
                  Wrap(
                    spacing: 8,
                    children: allInterests.map((interest) {
                      final selected = interests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: selected,
                        onSelected: (bool value) {
                          setState(() {
                            if (value) {
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
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
