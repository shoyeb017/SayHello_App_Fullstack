import 'package:flutter/material.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Learn Page'),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const InstructorApp());
// }

// class InstructorApp extends StatelessWidget {
//   const InstructorApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Language Instructor',
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//         fontFamily: 'Inter',
//         appBarTheme: const AppBarTheme(
//           elevation: 0,
//           centerTitle: true,
//           backgroundColor: Colors.white,
//           iconTheme: IconThemeData(color: Colors.black),
//           titleTextStyle: TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       home: const InstructorHomePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class InstructorHomePage extends StatefulWidget {
//   const InstructorHomePage({super.key});

//   @override
//   State<InstructorHomePage> createState() => _InstructorHomePageState();
// }

// class _InstructorHomePageState extends State<InstructorHomePage> {
//   int _selectedTab = 0;

//   final List<Map<String, dynamic>> activeCourses = [
//     {
//       'title': 'Spanish for Beginners',
//       'students': 24,
//       'sessions': 3,
//       'icon': Icons.language,
//       'progress': 0.6,
//     },
//     {
//       'title': 'Spanish Intermediate',
//       'students': 15,
//       'sessions': 2,
//       'icon': Icons.translate,
//       'progress': 0.3,
//     },
//   ];

//   final List<Map<String, dynamic>> pastCourses = [
//     {
//       'title': 'Spanish Basics',
//       'students': 32,
//       'icon': Icons.menu_book,
//       'completed': true,
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Instructor Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildWelcomeHeader(),
//             const SizedBox(height: 24),
//             _buildStatsRow(),
//             const SizedBox(height: 24),
//             _buildCreateCourseButton(),
//             const SizedBox(height: 24),
//             _buildSectionHeader('Active Courses', activeCourses.length),
//             const SizedBox(height: 12),
//             _buildCoursesList(activeCourses),
//             const SizedBox(height: 24),
//             _buildSectionHeader('Past Courses', pastCourses.length),
//             const SizedBox(height: 12),
//             _buildCoursesList(pastCourses, isPast: true),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedTab,
//         onTap: (index) => setState(() => _selectedTab = index),
//         selectedItemColor: Colors.indigo,
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Courses'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }

//   Widget _buildWelcomeHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Welcome back,', style: TextStyle(fontSize: 16, color: Colors.grey)),
//         const SizedBox(height: 4),
//         const Text('Professor Smith', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         Text('Today: ${DateTime.now().toString().split(' ')[0]}', style: const TextStyle(color: Colors.grey)),
//       ],
//     );
//   }

//   Widget _buildStatsRow() {
//     return Row(
//       children: [
//         _buildStatCard(icon: Icons.people_outline, value: '42', label: 'Students', color: Colors.blue[50]!, iconColor: Colors.blue),
//         const SizedBox(width: 12),
//         _buildStatCard(icon: Icons.calendar_today_outlined, value: '5', label: 'Upcoming', color: Colors.purple[50]!, iconColor: Colors.purple),
//         const SizedBox(width: 12),
//         _buildStatCard(icon: Icons.star_outline, value: '4.8', label: 'Rating', color: Colors.orange[50]!, iconColor: Colors.orange),
//       ],
//     );
//   }

//   Widget _buildStatCard({
//     required IconData icon,
//     required String value,
//     required String label,
//     required Color color,
//     required Color iconColor,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, size: 24, color: iconColor),
//             const SizedBox(height: 8),
//             Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCreateCourseButton() {
//     return InkWell(
//       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateCoursePage())),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.indigo[50],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.indigo[100],
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.add, color: Colors.indigo),
//             ),
//             const SizedBox(width: 12),
//             const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Create New Course', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 Text('Start teaching a new language', style: TextStyle(color: Colors.grey, fontSize: 12)),
//               ],
//             ),
//             const Spacer(),
//             const Icon(Icons.chevron_right, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, int count) {
//     return Row(
//       children: [
//         Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(width: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(count.toString(), style: const TextStyle(fontSize: 12)),
//         ),
//       ],
//     );
//   }

//   Widget _buildCoursesList(List<Map<String, dynamic>> courses, {bool isPast = false}) {
//     if (courses.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.grey[50],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Center(
//           child: Text(
//             isPast ? 'No past courses' : 'No active courses',
//             style: const TextStyle(color: Colors.grey),
//           ),
//         ),
//       );
//     }

//     return ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: courses.length,
//       separatorBuilder: (context, index) => const SizedBox(height: 12),
//       itemBuilder: (context, index) => _buildCourseCard(courses[index], isPast: isPast),
//     );
//   }

//   Widget _buildCourseCard(Map<String, dynamic> course, {bool isPast = false}) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey[200]!, width: 1),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => CoursePortalPage(course: course)),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   color: Colors.indigo.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   course['icon'] ?? Icons.school,
//                   size: 40,
//                   color: Colors.indigo,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       course['title'],
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         const Icon(Icons.people_outline, size: 14, color: Colors.grey),
//                         const SizedBox(width: 4),
//                         Text('${course['students']} students', style: const TextStyle(color: Colors.grey, fontSize: 12)),
//                         if (!isPast) ...[
//                           const SizedBox(width: 12),
//                           const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
//                           const SizedBox(width: 4),
//                           Text('${course['sessions']} sessions', style: const TextStyle(color: Colors.grey, fontSize: 12)),
//                         ],
//                       ],
//                     ),
//                     if (!isPast) ...[
//                       const SizedBox(height: 8),
//                       LinearProgressIndicator(
//                         value: course['progress'],
//                         backgroundColor: Colors.grey[200],
//                         color: Colors.indigo,
//                         minHeight: 6,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${(course['progress'] * 100).toInt()}% completed',
//                         style: const TextStyle(color: Colors.grey, fontSize: 12),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const Icon(Icons.chevron_right, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CreateCoursePage extends StatefulWidget {
//   const CreateCoursePage({super.key});

//   @override
//   State<CreateCoursePage> createState() => _CreateCoursePageState();
// }

// class _CreateCoursePageState extends State<CreateCoursePage> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _priceController = TextEditingController();
//   String _selectedLanguage = 'English';
//   String _selectedLevel = 'Beginner';
//   DateTime? _startDate;
//   DateTime? _endDate;
//   bool _isPublished = false;
//   IconData _selectedIcon = Icons.school;

//   final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Japanese', 'Chinese'];
//   final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
//   final List<IconData> _availableIcons = [
//     Icons.language,
//     Icons.translate,
//     Icons.menu_book,
//     Icons.school,
//     Icons.record_voice_over,

//   ];

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 2),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStartDate) {
//           _startDate = picked;
//         } else {
//           _endDate = picked;
//         }
//       });
//     }
//   }

//   void _selectIcon() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select Course Icon'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: GridView.builder(
//             shrinkWrap: true,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4,
//               mainAxisSpacing: 10,
//               crossAxisSpacing: 10,
//             ),
//             itemCount: _availableIcons.length,
//             itemBuilder: (context, index) => IconButton(
//               icon: Icon(_availableIcons[index]),
//               onPressed: () {
//                 setState(() => _selectedIcon = _availableIcons[index]);
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       final newCourse = {
//         'title': _titleController.text,
//         'description': _descriptionController.text,
//         'price': double.parse(_priceController.text),
//         'language': _selectedLanguage,
//         'level': _selectedLevel,
//         'startDate': _startDate,
//         'endDate': _endDate,
//         'isPublished': _isPublished,
//         'icon': _selectedIcon,
//       };

//       print('New course created: $newCourse');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Course created successfully!')),
//       );
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create New Course'),
//         actions: [
//           IconButton(icon: const Icon(Icons.save), onPressed: _submitForm),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: GestureDetector(
//                   onTap: _selectIcon,
//                   child: Container(
//                     width: 150,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       color: Colors.indigo.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.indigo),
//                     ),
//                     child: Icon(
//                       _selectedIcon,
//                       size: 60,
//                       color: Colors.indigo,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Course Title',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => value == null || value.isEmpty ? 'Please enter a course title' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//                 validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _priceController,
//                 decoration: const InputDecoration(
//                   labelText: 'Price (\$)',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Please enter a price';
//                   if (double.tryParse(value) == null) return 'Please enter a valid number';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedLanguage,
//                 decoration: const InputDecoration(
//                   labelText: 'Language',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: _languages.map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 onChanged: (newValue) => setState(() => _selectedLanguage = newValue!),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedLevel,
//                 decoration: const InputDecoration(
//                   labelText: 'Level',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: _levels.map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 onChanged: (newValue) => setState(() => _selectedLevel = newValue!),
//               ),
//               const SizedBox(height: 16),
//               ListTile(
//                 title: Text(_startDate == null
//                     ? 'Select Start Date'
//                     : 'Start Date: ${_startDate!.toLocal().toString().split(' ')[0]}'),
//                 trailing: const Icon(Icons.calendar_today),
//                 onTap: () => _selectDate(context, true),
//               ),
//               const SizedBox(height: 8),
//               ListTile(
//                 title: Text(_endDate == null
//                     ? 'Select End Date'
//                     : 'End Date: ${_endDate!.toLocal().toString().split(' ')[0]}'),
//                 trailing: const Icon(Icons.calendar_today),
//                 onTap: () => _selectDate(context, false),
//               ),
//               const SizedBox(height: 16),
//               SwitchListTile(
//                 title: const Text('Publish Course'),
//                 value: _isPublished,
//                 onChanged: (bool value) => setState(() => _isPublished = value),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _submitForm,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text('Create Course', style: TextStyle(fontSize: 16)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CoursePortalPage extends StatelessWidget {
//   final Map<String, dynamic> course;
//   const CoursePortalPage({super.key, required this.course});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(course['title'])),
//       body: Center(child: Text('Portal for ${course['title']}')),
//     );
//   }
