import 'package:flutter/material.dart';
import 'course_portal.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Simulated enrolled and other courses separately
  final List<Map<String, dynamic>> enrolledCourses = [
    {
      'title': 'Japanese for Beginners',
      'instructor': 'Hiro Tanaka',
      'rating': 4.6,
      'students': 120,
      'progress': 0.4,
      'icon': Icons.language,
    },
    {
      'title': 'Conversational Spanish',
      'instructor': 'Maria Gomez',
      'rating': 4.9,
      'students': 95,
      'progress': 0.75,
      'icon': Icons.chat,
    },
  ];

  final List<Map<String, dynamic>> otherCourses = [
    {
      'title': 'French Grammar Essentials',
      'instructor': 'Jean Dupont',
      'rating': 4.2,
      'students': 60,
      'progress': 0.0,
      'icon': Icons.book,
    },
    {
      'title': 'German Basics',
      'instructor': 'Klaus Schmidt',
      'rating': 4.3,
      'students': 80,
      'progress': 0.0,
      'icon': Icons.translate,
    },
    {
      'title': 'Italian for Travelers',
      'instructor': 'Luca Bianchi',
      'rating': 4.5,
      'students': 55,
      'progress': 0.0,
      'icon': Icons.flight_takeoff,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Widget for a small course preview card (used in lists)
  Widget _courseCard(Map<String, dynamic> course, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CoursePortalPage(course: course),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.indigo.shade900 : Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(course['icon'], color: Colors.indigo, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Instructor: ${course['instructor']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${course['rating']}  •  ${course['students']} students',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (course['progress'] != null && course['progress'] > 0) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: course['progress'],
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(course['progress'] * 100).toInt()}% completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(List<Map<String, dynamic>> courses, bool isDark, {int previewCount = 2, required VoidCallback onViewAll}) {
    final previewCourses = courses.length > previewCount ? courses.sublist(0, previewCount) : courses;

    return Column(
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: previewCourses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _courseCard(previewCourses[index], isDark);
          },
        ),
        if (courses.length > previewCount)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: onViewAll,
              child: const Text('View All'),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  bool toDark = themeProvider.themeMode != ThemeMode.dark;
                  themeProvider.toggleTheme(toDark);
                },
              ),
              const Expanded(
                child: Text(
                  'Language Learn',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
              ),
              IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.purple,
            unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            indicatorColor: Colors.purple,
            tabs: const [
              Tab(text: 'Enrolled'),
              Tab(text: 'Other Courses'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Enrolled Courses Tab
                ListView(
                  children: [
                    const SizedBox(height: 12),
                    _buildCourseList(
                      enrolledCourses,
                      isDark,
                      previewCount: 2,
                      onViewAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllCoursesPage(
                              courses: enrolledCourses,
                              title: 'All Enrolled Courses',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

                // Other Courses Tab
                ListView(
                  children: [
                    const SizedBox(height: 12),
                    _buildCourseList(
                      otherCourses,
                      isDark,
                      previewCount: 2,
                      onViewAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllCoursesPage(
                              courses: otherCourses,
                              title: 'All Other Courses',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AllCoursesPage extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  final String title;
  const AllCoursesPage({super.key, required this.courses, required this.title});

  @override
  State<AllCoursesPage> createState() => _AllCoursesPageState();
}

class _AllCoursesPageState extends State<AllCoursesPage> {
  late List<Map<String, dynamic>> filteredCourses;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCourses = widget.courses;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCourses = widget.courses.where((course) {
        final title = (course['title'] ?? '').toString().toLowerCase();
        return title.contains(query);
      }).toList();
    });
  }

  Widget _courseCard(Map<String, dynamic> course, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CoursePortalPage(course: course),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.indigo.shade900 : Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(course['icon'], color: Colors.indigo, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Instructor: ${course['instructor']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${course['rating']}  •  ${course['students']} students',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (course['progress'] != null && course['progress'] > 0) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: course['progress'],
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(course['progress'] * 100).toInt()}% completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: filteredCourses.isEmpty
                ? Center(child: Text('No courses found'))
                : ListView.builder(
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      return _courseCard(filteredCourses[index], isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
