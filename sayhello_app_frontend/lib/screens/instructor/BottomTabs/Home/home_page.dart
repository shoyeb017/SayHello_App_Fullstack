import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/theme_provider.dart';
import 'instructor_course_portal.dart';
import '../Revenue/revenue_page.dart';

class InstructorHomePage extends StatefulWidget {
  const InstructorHomePage({super.key});

  @override
  State<InstructorHomePage> createState() => _InstructorHomePageState();
}

class _InstructorHomePageState extends State<InstructorHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Dynamic course data - replace with backend API later
  final List<Map<String, dynamic>> _allCourses = [
    {
      'id': 'course_001',
      'title': 'Flutter Development Masterclass',
      'description':
          'Complete Flutter development course for beginners to advanced',
      'status': 'active',
      'enrolledStudents': 45,
      'totalSessions': 20,
      'completedSessions': 12,
      'upcomingSessions': 3,
      'rating': 4.8,
      'price': 299.99,
      'thumbnail': 'https://picsum.photos/300/200?random=1',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      'category': 'Programming',
      'difficulty': 'Intermediate',
    },
    {
      'id': 'course_002',
      'title': 'React Native for Mobile Apps',
      'description': 'Build cross-platform mobile apps with React Native',
      'status': 'active',
      'enrolledStudents': 32,
      'totalSessions': 15,
      'completedSessions': 8,
      'upcomingSessions': 2,
      'rating': 4.6,
      'price': 249.99,
      'thumbnail': 'https://picsum.photos/300/200?random=2',
      'createdAt': DateTime.now().subtract(const Duration(days: 60)),
      'category': 'Programming',
      'difficulty': 'Beginner',
    },
    {
      'id': 'course_003',
      'title': 'Advanced JavaScript Concepts',
      'description': 'Deep dive into modern JavaScript and ES6+ features',
      'status': 'completed',
      'enrolledStudents': 78,
      'totalSessions': 12,
      'completedSessions': 12,
      'upcomingSessions': 0,
      'rating': 4.9,
      'price': 199.99,
      'thumbnail': 'https://picsum.photos/300/200?random=3',
      'createdAt': DateTime.now().subtract(const Duration(days: 120)),
      'category': 'Programming',
      'difficulty': 'Advanced',
    },
    {
      'id': 'course_004',
      'title': 'UI/UX Design Fundamentals',
      'description':
          'Learn the principles of user interface and experience design',
      'status': 'draft',
      'enrolledStudents': 0,
      'totalSessions': 18,
      'completedSessions': 0,
      'upcomingSessions': 0,
      'rating': 0.0,
      'price': 179.99,
      'thumbnail': 'https://picsum.photos/300/200?random=4',
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      'category': 'Design',
      'difficulty': 'Beginner',
    },
  ];

  List<Map<String, dynamic>> get _filteredCourses {
    if (_searchQuery.isEmpty) return _allCourses;

    return _allCourses.where((course) {
      final title = course['title'].toString().toLowerCase();
      final description = course['description'].toString().toLowerCase();
      final category = course['category'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          category.contains(query);
    }).toList();
  }

  // Get quick stats
  Map<String, int> get _quickStats {
    int totalStudents = 0;
    int upcomingSessions = 0;
    int activeCourses = 0;

    for (var course in _allCourses) {
      totalStudents += course['enrolledStudents'] as int;
      upcomingSessions += course['upcomingSessions'] as int;
      if (course['status'] == 'active') activeCourses++;
    }

    return {
      'totalStudents': totalStudents,
      'upcomingSessions': upcomingSessions,
      'activeCourses': activeCourses,
      'totalCourses': _allCourses.length,
    };
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = _quickStats;
    final courses = _filteredCourses;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Instructor Dashboard',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.monetization_on),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InstructorRevenuePage(),
                  ),
                );
              },
              tooltip: 'Revenue Dashboard',
            ),
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
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddCourseDialog();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Search courses...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Quick Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Courses',
                    stats['activeCourses']!,
                    Icons.school,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Students',
                    stats['totalStudents']!,
                    Icons.people,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Upcoming Sessions',
                    stats['upcomingSessions']!,
                    Icons.schedule,
                    isDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Course List
          Expanded(
            child: courses.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      return _buildCourseCard(courses[index], isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey[200]!,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF7A54FF), size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, bool isDark) {
    final status = course['status'] as String;
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey[200]!,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to course portal - will create this file
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InstructorCoursePortalPage(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Thumbnail
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: course['thumbnail'] != null
                    ? DecorationImage(
                        image: NetworkImage(course['thumbnail']),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: course['thumbnail'] == null
                    ? const Color(0xFF7A54FF).withOpacity(0.1)
                    : null,
              ),
              child: course['thumbnail'] == null
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7A54FF).withOpacity(0.8),
                            const Color(0xFF7A54FF).withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Course Preview',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status Badge
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
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
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
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
                        // Status Badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
                  Text(
                    course['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course['enrolledStudents']} students',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (course['rating'] > 0) ...[
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          course['rating'].toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '\$${course['price'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7A54FF),
                        ),
                      ),
                    ],
                  ),
                  if (status == 'active') ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value:
                          course['completedSessions'] / course['totalSessions'],
                      backgroundColor: isDark
                          ? Colors.grey[700]
                          : Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF7A54FF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Progress: ${course['completedSessions']}/${course['totalSessions']} sessions',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No courses yet'
                : 'No courses found for "$_searchQuery"',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Create your first course to get started'
                : 'Try different search terms',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: _showAddCourseDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create Course',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'draft':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showAddCourseDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            'Create New Course',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            'Course creation feature coming soon!\n\nThis will include:\n• Course title and description\n• Pricing and duration\n• Session scheduling\n• Content upload',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF7A54FF)),
              ),
            ),
          ],
        );
      },
    );
  }
}
