import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import 'instructor_course_portal.dart';
import '../Revenue/revenue_page.dart';
import '../../../../../providers/settings_provider.dart';

class InstructorHomePage extends StatefulWidget {
  const InstructorHomePage({super.key});

  @override
  State<InstructorHomePage> createState() => _InstructorHomePageState();
}

class _InstructorHomePageState extends State<InstructorHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'All';

  // Instructor name and profile data
  final String instructorName = "John Doe";
  final String instructorProfileImage = "";

  // Status filter options - will be initialized with localized values
  List<String> _statusFilters = [];

  // Dynamic course data with dates for status calculation
  final List<Map<String, dynamic>> _allCourses = [
    {
      'id': 'course_001',
      'title': 'Flutter Development Masterclass',
      'description':
          'Complete Flutter development course for beginners to advanced',
      'enrolledStudents': 45,
      'totalSessions': 20,
      'completedSessions': 12,
      'rating': 4.8,
      'price': 299.99,
      'icon': Icons.flutter_dash,
      'thumbnail': '',
      'category': 'Programming',
      'level': 'Intermediate',
      'startDate': '2025-07-15',
      'endDate': '2025-09-15',
      'duration': '8 weeks',
    },
    {
      'id': 'course_002',
      'title': 'React Native Mobile Apps',
      'description': 'Build cross-platform mobile apps with React Native',
      'enrolledStudents': 32,
      'totalSessions': 15,
      'completedSessions': 8,
      'rating': 4.6,
      'price': 249.99,
      'icon': Icons.phone_android,
      'thumbnail': '',
      'category': 'Programming',
      'level': 'Beginner',
      'startDate': '2025-08-10',
      'endDate': '2025-10-05',
      'duration': '6 weeks',
    },
    {
      'id': 'course_003',
      'title': 'Advanced JavaScript',
      'description': 'Deep dive into modern JavaScript and ES6+ features',
      'enrolledStudents': 78,
      'totalSessions': 12,
      'completedSessions': 12,
      'rating': 4.9,
      'price': 199.99,
      'icon': Icons.code,
      'thumbnail': '',
      'category': 'Programming',
      'level': 'Advanced',
      'startDate': '2025-04-01',
      'endDate': '2025-06-15',
      'duration': '10 weeks',
    },
    {
      'id': 'course_005',
      'title': 'Advanced JavaScript 1',
      'description': 'Deep dive into modern JavaScript and ES6+ features',
      'enrolledStudents': 78,
      'totalSessions': 12,
      'completedSessions': 12,
      'rating': 4.9,
      'price': 199.99,
      'icon': Icons.code,
      'thumbnail': '',
      'category': 'Programming',
      'level': 'Advanced',
      'startDate': '2025-04-01',
      'endDate': '2025-06-15',
      'duration': '10 weeks',
    },
    {
      'id': 'course_006',
      'title': 'Advanced JavaScript 2',
      'description': 'Deep dive into modern JavaScript and ES6+ features',
      'enrolledStudents': 78,
      'totalSessions': 12,
      'completedSessions': 12,
      'rating': 4.9,
      'price': 199.99,
      'icon': Icons.code,
      'thumbnail': '',
      'category': 'Programming',
      'level': 'Advanced',
      'startDate': '2025-04-01',
      'endDate': '2025-06-15',
      'duration': '10 weeks',
    },
    {
      'id': 'course_004',
      'title': 'UI/UX Design Fundamentals',
      'description':
          'Learn the principles of user interface and experience design',
      'enrolledStudents': 25,
      'totalSessions': 18,
      'completedSessions': 5,
      'rating': 4.7,
      'price': 179.99,
      'icon': Icons.design_services,
      'thumbnail': '',
      'category': 'Design',
      'level': 'Beginner',
      'startDate': '2025-08-20',
      'endDate': '2025-10-20',
      'duration': '9 weeks',
    },
    {
      'id': 'course_005',
      'title': 'Python Data Science',
      'description':
          'Complete data science course with Python and machine learning',
      'enrolledStudents': 0,
      'totalSessions': 24,
      'completedSessions': 0,
      'rating': 0.0,
      'price': 349.99,
      'icon': Icons.analytics,
      'thumbnail': '',
      'category': 'Data Science',
      'level': 'Intermediate',
      'startDate': '2025-09-01',
      'endDate': '2025-11-15',
      'duration': '12 weeks',
    },
  ];

  // Method to calculate course status based on dates
  String _getCourseStatus(Map<String, dynamic> course) {
    final now = DateTime.now();
    final startDate = DateTime.tryParse(course['startDate'] ?? '');
    final endDate = DateTime.tryParse(course['endDate'] ?? '');

    if (startDate == null || endDate == null) {
      return 'active'; // Default status if dates are missing
    }

    if (now.isBefore(startDate)) {
      return 'upcoming';
    } else if (now.isAfter(endDate)) {
      return 'expired';
    } else {
      return 'active';
    }
  }

  // Get courses by status for sections
  List<Map<String, dynamic>> get _upcomingCourses {
    final localizations = AppLocalizations.of(context)!;
    if (_selectedStatusFilter == localizations.all ||
        _selectedStatusFilter == localizations.upcoming) {
      List<Map<String, dynamic>> courses = _allCourses
          .where((course) => _getCourseStatus(course) == 'upcoming')
          .toList();
      return _applySearchFilter(courses);
    }
    return [];
  }

  List<Map<String, dynamic>> get _activeCourses {
    final localizations = AppLocalizations.of(context)!;
    if (_selectedStatusFilter == localizations.all ||
        _selectedStatusFilter == localizations.active) {
      List<Map<String, dynamic>> courses = _allCourses
          .where((course) => _getCourseStatus(course) == 'active')
          .toList();
      return _applySearchFilter(courses);
    }
    return [];
  }

  List<Map<String, dynamic>> get _expiredCourses {
    final localizations = AppLocalizations.of(context)!;
    if (_selectedStatusFilter == localizations.all ||
        _selectedStatusFilter == localizations.expired) {
      List<Map<String, dynamic>> courses = _allCourses
          .where((course) => _getCourseStatus(course) == 'expired')
          .toList();
      return _applySearchFilter(courses);
    }
    return [];
  }

  // Get all filtered courses for when a specific status is selected
  List<Map<String, dynamic>> get _filteredCourses {
    final localizations = AppLocalizations.of(context)!;
    List<Map<String, dynamic>> courses = _allCourses;

    // Apply status filter
    if (_selectedStatusFilter != localizations.all) {
      courses = courses.where((course) {
        final status = _getCourseStatus(course);
        if (_selectedStatusFilter == localizations.upcoming) {
          return status == 'upcoming';
        } else if (_selectedStatusFilter == localizations.active) {
          return status == 'active';
        } else if (_selectedStatusFilter == localizations.expired) {
          return status == 'expired';
        }
        return false;
      }).toList();
    }

    // Apply search filter
    return _applySearchFilter(courses);
  }

  // Apply search filter to course list
  List<Map<String, dynamic>> _applySearchFilter(
    List<Map<String, dynamic>> courses,
  ) {
    if (_searchQuery.isEmpty) return courses;

    return courses.where((course) {
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
    int activeCourses = 0;
    int upcomingCourses = 0;
    int expiredCourses = 0;

    for (var course in _allCourses) {
      totalStudents += course['enrolledStudents'] as int;
      final status = _getCourseStatus(course);
      if (status == 'active') activeCourses++;
      if (status == 'upcoming') upcomingCourses++;
      if (status == 'expired') expiredCourses++;
    }

    return {
      'totalStudents': totalStudents,
      'activeCourses': activeCourses,
      'upcomingCourses': upcomingCourses,
      'expiredCourses': expiredCourses,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    // Initialize status filters with localized values
    if (_statusFilters.isEmpty) {
      _statusFilters = [
        localizations.all,
        localizations.upcoming,
        localizations.active,
        localizations.expired,
      ];
      _selectedStatusFilter = localizations.all;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              // Revenue/Analytics Icon
              IconButton(
                icon: const Icon(Icons.analytics),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InstructorRevenuePage(),
                    ),
                  );
                },
                tooltip: localizations.analytics,
              ),

              Expanded(
                child: Text(
                  localizations.myCourses,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),

              // Settings Icon
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () =>
                    SettingsProvider.showSettingsBottomSheet(context),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: _buildMainContent(isDark)),
    );
  }

  Widget _buildMainContent(bool isDark) {
    final localizations = AppLocalizations.of(context)!;

    // If a specific status filter is selected, show only those courses
    if (_selectedStatusFilter != localizations.all) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingHeader(isDark),
            const SizedBox(height: 20),
            _buildSearchAndFilter(isDark),
            const SizedBox(height: 24),
            _buildQuickStats(isDark),
            const SizedBox(height: 30),
            _buildFilteredCoursesSection(isDark),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    // Show all sections when 'All' filter is selected
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingHeader(isDark),
          const SizedBox(height: 20),
          _buildSearchAndFilter(isDark),
          const SizedBox(height: 24),
          _buildQuickStats(isDark),
          const SizedBox(height: 30),
          _buildUpcomingCoursesSection(isDark),
          const SizedBox(height: 30),
          _buildActiveCoursesSection(isDark),
          const SizedBox(height: 30),
          _buildExpiredCoursesSection(isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader(bool isDark) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.welcomeBack,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  instructorName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: instructorProfileImage.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      instructorProfileImage,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF7A54FF).withOpacity(0.8),
                          const Color(0xFF7A54FF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isDark) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localizations.searchYourCourses,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Status Filter
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final filter = _statusFilters[index];
                final isSelected = _selectedStatusFilter == filter;

                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatusFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF7A54FF)
                            : (isDark ? Colors.grey[800] : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.grey[300] : Colors.grey[700]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    final stats = _quickStats;
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              localizations.totalStudents,
              stats['totalStudents']!,
              Icons.people,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              localizations.activeCourses,
              stats['activeCourses']!,
              Icons.school,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              localizations.totalCourses,
              stats['totalCourses']!,
              Icons.library_books,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF7A54FF), size: 20),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCoursesSection(bool isDark) {
    final upcomingCourses = _upcomingCourses;
    if (upcomingCourses.isEmpty) return const SizedBox.shrink();

    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.upcomingCourses,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              if (upcomingCourses.length > 2)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatusFilter = localizations.upcoming;
                    });
                  },
                  child: Text(
                    localizations.seeAll,
                    style: const TextStyle(
                      color: Color(0xFF7A54FF),
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180, // Increased height from 160 to 180
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: upcomingCourses.length > 3
                  ? 3
                  : upcomingCourses.length,
              itemBuilder: (context, index) {
                return _buildCourseCard(
                  upcomingCourses[index],
                  isDark,
                  isHorizontal: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCoursesSection(bool isDark) {
    final activeCourses = _activeCourses;
    if (activeCourses.isEmpty) return const SizedBox.shrink();

    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.activeCourses,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              if (activeCourses.length > 3)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatusFilter = localizations.active;
                    });
                  },
                  child: Text(
                    localizations.seeAll,
                    style: const TextStyle(
                      color: Color(0xFF7A54FF),
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeCourses.length > 3 ? 3 : activeCourses.length,
            itemBuilder: (context, index) {
              return _buildCourseCard(activeCourses[index], isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredCoursesSection(bool isDark) {
    final expiredCourses = _expiredCourses;
    if (expiredCourses.isEmpty) return const SizedBox.shrink();

    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.completedCourses,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              if (expiredCourses.length > 2)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatusFilter = localizations.expired;
                    });
                  },
                  child: Text(
                    localizations.seeAll,
                    style: const TextStyle(
                      color: Color(0xFF7A54FF),
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180, // Increased height from 160 to 180
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: expiredCourses.length > 3 ? 3 : expiredCourses.length,
              itemBuilder: (context, index) {
                return _buildCourseCard(
                  expiredCourses[index],
                  isDark,
                  isHorizontal: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredCoursesSection(bool isDark) {
    final filteredCourses = _filteredCourses;
    final localizations = AppLocalizations.of(context)!;
    final statusTitle = _selectedStatusFilter == localizations.expired
        ? localizations.completed
        : _selectedStatusFilter;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$statusTitle Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatusFilter = localizations.all;
                  });
                },
                child: Text(
                  localizations.showAllSections,
                  style: const TextStyle(
                    color: Color(0xFF7A54FF),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (filteredCourses.isEmpty)
            Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.noCoursesFound,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      Text(
                        localizations.tryAdjustingSearch,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                return _buildCourseCard(filteredCourses[index], isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(
    Map<String, dynamic> course,
    bool isDark, {
    bool isHorizontal = false,
  }) {
    final status = _getCourseStatus(course);
    final progress = course['completedSessions'] / course['totalSessions'];
    final localizations = AppLocalizations.of(context)!;

    if (isHorizontal) {
      return Container(
        width: 220, // Increased width to prevent overflow
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _navigateToCourse(course),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header with Icon
              Container(
                height: 85, // Increased height from 80 to 85
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7A54FF).withOpacity(0.8),
                      const Color(0xFF7A54FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        course['icon'] ?? Icons.school,
                        color: Colors.white,
                        size: 28, // Reduced icon size from 32 to 28
                      ),
                    ),
                    Positioned(
                      top: 6, // Adjusted position
                      right: 6, // Adjusted position
                      child: _buildStatusBadge(status),
                    ),
                  ],
                ),
              ),

              // Course Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(
                    10,
                  ), // Reduced padding from 12 to 10
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'],
                        style: TextStyle(
                          fontSize: 13, // Slightly smaller font
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3), // Reduced spacing
                      Text(
                        '${course['enrolledStudents']} ${localizations.students}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '\$${course['price'].toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7A54FF),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (course['rating'] > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  course['rating'].toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
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
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _navigateToCourse(course),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10), // Reduced padding from 12 to 10
            child: Row(
              children: [
                // Course Icon
                Container(
                  width: 48, // Slightly smaller
                  height: 48, // Slightly smaller
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7A54FF).withOpacity(0.8),
                        const Color(0xFF7A54FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    course['icon'] ?? Icons.school,
                    color: Colors.white,
                    size: 22, // Reduced icon size
                  ),
                ),

                const SizedBox(width: 10), // Reduced spacing
                // Course Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course['title'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 3), // Reduced spacing
                      Text(
                        course['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6), // Reduced spacing
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${course['enrolledStudents']} ${localizations.students}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (course['rating'] > 0) ...[
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              course['rating'].toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          const Spacer(),
                          Text(
                            '\$${course['price'].toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7A54FF),
                            ),
                          ),
                        ],
                      ),
                      if (status == 'active' && progress > 0) ...[
                        const SizedBox(height: 6), // Reduced spacing
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: isDark
                              ? Colors.grey[700]
                              : Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF7A54FF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${localizations.progress}: ${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 9, // Reduced font size
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
        ),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    final localizations = AppLocalizations.of(context)!;
    Color badgeColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'upcoming':
        badgeColor = Colors.orange;
        displayText = localizations.upcoming;
        break;
      case 'active':
        badgeColor = Colors.blue;
        displayText = localizations.active;
        break;
      case 'expired':
        badgeColor = Colors.green;
        displayText = localizations.completed;
        break;
      default:
        badgeColor = Colors.grey;
        displayText = localizations.unknown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  void _navigateToCourse(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstructorCoursePortalPage(course: course),
      ),
    );
  }
}
