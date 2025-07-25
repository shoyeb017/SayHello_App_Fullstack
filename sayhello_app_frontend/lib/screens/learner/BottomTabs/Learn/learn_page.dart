import 'package:flutter/material.dart';
import 'course_portal.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../l10n/app_localizations.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Simulated enrolled and other courses with more dynamic data
  final List<Map<String, dynamic>> enrolledCourses = [
    {
      'id': 'course_001',
      'title': 'Japanese for Beginners',
      'instructor': 'Hiro Tanaka',
      'rating': 4.6,
      'students': 120,
      'progress': 0.4,
      'icon': Icons.language,
      'thumbnail': null, // Will show placeholder
      'description':
          'Learn Japanese from basics including Hiragana, Katakana, and essential vocabulary for everyday conversations.',
      'price': 59.99,
      'duration': '6 weeks',
      'level': 'Beginner',
      'category': 'Language',
      'enrolledDate': '2025-06-15',
      'nextSession': '2025-07-25 10:00 AM',
      'totalSessions': 24,
      'completedSessions': 10,
      'totalLessons': 48,
      'completedLessons': 19,
      'status': 'active',
    },
    {
      'id': 'course_002',
      'title': 'Conversational Spanish',
      'instructor': 'Maria Gomez',
      'rating': 4.9,
      'students': 95,
      'progress': 0.75,
      'icon': Icons.chat,
      'thumbnail': null, // Will show placeholder
      'description':
          'Master Spanish conversation skills through interactive sessions and real-world scenarios.',
      'price': 49.99,
      'duration': '8 weeks',
      'level': 'Intermediate',
      'category': 'Language',
      'enrolledDate': '2025-05-20',
      'nextSession': '2025-07-26 02:00 PM',
      'totalSessions': 32,
      'completedSessions': 24,
      'totalLessons': 64,
      'completedLessons': 48,
      'status': 'active',
    },
    {
      'id': 'course_003',
      'title': 'German Advanced Grammar',
      'instructor': 'Klaus Schmidt',
      'rating': 4.5,
      'students': 42,
      'progress': 1.0,
      'icon': Icons.book,
      'thumbnail': null, // Will show placeholder
      'description':
          'Advanced German grammar concepts for fluent communication and professional writing.',
      'price': 79.99,
      'duration': '10 weeks',
      'level': 'Advanced',
      'category': 'Language',
      'enrolledDate': '2025-04-10',
      'nextSession': null, // Course completed
      'totalSessions': 20,
      'completedSessions': 20,
      'totalLessons': 40,
      'completedLessons': 40,
      'status': 'completed',
    },
  ];

  final List<Map<String, dynamic>> otherCourses = [
    {
      'id': 'course_004',
      'title': 'French Grammar Essentials',
      'instructor': 'Jean Dupont',
      'rating': 4.2,
      'students': 60,
      'progress': 0.0,
      'icon': Icons.book,
      'thumbnail': null, // Will show placeholder
      'description':
          'Essential French grammar rules and structures for building a strong foundation in the language.',
      'price': 39.99,
      'duration': '5 weeks',
      'level': 'Beginner',
      'category': 'Language',
      'totalSessions': 15,
      'totalLessons': 30,
      'status': 'available',
    },
    {
      'id': 'course_005',
      'title': 'Italian for Travelers',
      'instructor': 'Luca Bianchi',
      'rating': 4.5,
      'students': 55,
      'progress': 0.0,
      'icon': Icons.flight_takeoff,
      'thumbnail': null, // Will show placeholder
      'description':
          'Learn essential Italian phrases and cultural insights for your next trip to Italy.',
      'price': 29.99,
      'duration': '4 weeks',
      'level': 'Beginner',
      'category': 'Language',
      'totalSessions': 12,
      'totalLessons': 24,
      'status': 'available',
    },
    {
      'id': 'course_006',
      'title': 'Business English Communication',
      'instructor': 'Sarah Johnson',
      'rating': 4.7,
      'students': 180,
      'progress': 0.0,
      'icon': Icons.business,
      'thumbnail': null, // Will show placeholder
      'description':
          'Professional English communication skills for workplace success and career advancement.',
      'price': 69.99,
      'duration': '8 weeks',
      'level': 'Intermediate',
      'category': 'Language',
      'totalSessions': 24,
      'totalLessons': 48,
      'status': 'available',
    },
    {
      'id': 'course_007',
      'title': 'Mandarin Chinese Basics',
      'instructor': 'Li Wei',
      'rating': 4.4,
      'students': 75,
      'progress': 0.0,
      'icon': Icons.translate,
      'thumbnail': null, // Will show placeholder
      'description':
          'Start your Mandarin journey with pronunciation, basic characters, and essential phrases.',
      'price': 55.99,
      'duration': '7 weeks',
      'level': 'Beginner',
      'category': 'Language',
      'totalSessions': 21,
      'totalLessons': 42,
      'status': 'available',
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

  // Widget for a course card with thumbnail and enhanced design
  Widget _courseCard(Map<String, dynamic> course, bool isDark) {
    final isEnrolled = course['progress'] != null && course['progress'] > 0;
    final isCompleted = course['status'] == 'completed';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CoursePortalPage(course: course)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey[200]!,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Thumbnail
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: course['thumbnail'] != null
                    ? DecorationImage(
                        image: NetworkImage(course['thumbnail']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: course['thumbnail'] == null
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.withOpacity(0.8),
                            Colors.purple.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  course['icon'] ?? Icons.school,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  course['category'] ?? 'Course',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status Badge
                          if (isEnrolled) ...[
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Colors.green.withOpacity(0.9)
                                      : Colors.orange.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isCompleted
                                      ? AppLocalizations.of(context)!.completed
                                      : AppLocalizations.of(
                                          context,
                                        )!.inProgress,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          // Level Badge
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                course['level'] ?? 'Beginner',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        // Overlay for better text visibility
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Status and Level badges
                        if (isEnrolled) ...[
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? Colors.green.withOpacity(0.9)
                                    : Colors.orange.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isCompleted
                                    ? AppLocalizations.of(context)!.completed
                                    : AppLocalizations.of(context)!.inProgress,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course['level'] ?? 'Beginner',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            // Course Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isEnrolled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '\$${course['price']?.toStringAsFixed(0) ?? '0'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${course['instructor']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course['description'] ?? 'Course description...',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Course Stats
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${course['rating']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.people,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course['students']} ${AppLocalizations.of(context)!.students}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course['duration'] ?? '4 weeks',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // Progress bar for enrolled courses
                  if (isEnrolled && !isCompleted) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: course['progress']?.toDouble() ?? 0.0,
                      backgroundColor: isDark
                          ? Colors.grey[700]
                          : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? Colors.green : Colors.indigo,
                      ),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${((course['progress'] ?? 0) * 100).toInt()}% ${AppLocalizations.of(context)!.completedLowercase}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        if (course['nextSession'] != null)
                          Text(
                            'Next: ${course['nextSession']?.substring(0, 10) ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.indigo,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],

                  if (isCompleted) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)!.courseCompleted,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(
    List<Map<String, dynamic>> courses,
    bool isDark, {
    int previewCount = 2,
    required VoidCallback onViewAll,
  }) {
    final previewCourses = courses.length > previewCount
        ? courses.sublist(0, previewCount)
        : courses;

    return Column(
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: previewCourses.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 0), // No extra spacing needed
          itemBuilder: (context, index) {
            return _courseCard(previewCourses[index], isDark);
          },
        ),
        if (courses.length > previewCount)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.visibility, size: 18),
                label: Text(
                  '${AppLocalizations.of(context)!.viewAll} ${courses.length} ${AppLocalizations.of(context)!.courses}',
                ),
                onPressed: onViewAll,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.indigo.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
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
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.languageLearn,
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
            unselectedLabelColor: isDark
                ? Colors.grey.shade400
                : Colors.grey.shade600,
            indicatorColor: Colors.purple,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.enrolled),
              Tab(text: AppLocalizations.of(context)!.otherCourses),
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
                              title: AppLocalizations.of(
                                context,
                              )!.allEnrolledCourses,
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
                              title: AppLocalizations.of(
                                context,
                              )!.allOtherCourses,
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
          MaterialPageRoute(builder: (_) => CoursePortalPage(course: course)),
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
                    '${AppLocalizations.of(context)!.instructor}: ${course['instructor']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
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
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (course['progress'] != null && course['progress'] > 0) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: course['progress'],
                      backgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.indigo,
                      ),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(course['progress'] * 100).toInt()}% completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
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
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchCourses,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredCourses.isEmpty
                ? Center(
                    child: Text(AppLocalizations.of(context)!.noCoursesFound),
                  )
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
