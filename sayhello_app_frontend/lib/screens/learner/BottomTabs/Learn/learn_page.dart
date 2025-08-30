import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Enrolled/course_portal.dart';
import 'Unenrolled/unenrolled_course_details.dart';
import 'search_courses_page.dart';
import 'my_courses_page.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../providers/course_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/course.dart';
import '../../../../models/learner.dart';
import '../../Notifications/notifications.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  // User data
  String userName = "Loading...";
  final String userProfileImage = ""; // Add actual image URL

  // Categories
  final List<String> categories = ['Beginner', 'Intermediate', 'Advanced'];

  // Get all courses from the CourseProvider
  List<Course> get _allCourses {
    final courseProvider = Provider.of<CourseProvider>(context);
    return courseProvider.courses;
  }

  // Get enrolled courses (courses with progress > 0)
  List<Course> get _enrolledCourses {
    final courseProvider = Provider.of<CourseProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.currentUser == null) return [];

    return courseProvider.learnerEnrollments
        .map((enrollment) => enrollment.course)
        .toList();
  }

  // Get popular courses (not enrolled, high rating or students)
  List<Course> get _popularCourses {
    final enrolledCourseIds = _enrolledCourses.map((c) => c.id).toSet();

    return _allCourses
        .where(
          (course) =>
              !enrolledCourseIds.contains(course.id) &&
              (_getCourseStatus(course) == 'active' ||
                  _getCourseStatus(course) == 'upcoming'),
        )
        .toList();
  }

  // Get expired courses available for enrollment
  List<Course> get _expiredCourses {
    final enrolledCourseIds = _enrolledCourses.map((c) => c.id).toSet();

    return _allCourses
        .where(
          (course) =>
              !enrolledCourseIds.contains(course.id) &&
              _getCourseStatus(course) == 'expired',
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      // Load user name
      final learner = authProvider.currentUser as Learner?;
      if (learner != null && mounted) {
        setState(() {
          userName = learner.name;
        });
      }

      // Load all courses
      await courseProvider.loadCourses();

      // Load learner's enrollments
      await courseProvider.loadLearnerEnrollments(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to calculate course status based on dates
  String _getCourseStatus(Course course) {
    final now = DateTime.now();

    if (now.isBefore(course.startDate)) {
      return 'upcoming';
    } else if (now.isAfter(course.endDate)) {
      return 'expired';
    } else {
      return 'active';
    }
  }

  // Helper method to convert Course to Map for compatibility
  Map<String, dynamic> _courseToMap(Course course) {
    return {
      'id': course.id,
      'title': course.title,
      'description': course.description,
      'language': course.language,
      'level': course.level,
      'total_sessions': course.totalSessions,
      'price': course.price,
      'startDate': course.startDate.toIso8601String(),
      'endDate': course.endDate.toIso8601String(),
      'status': course.status,
      'instructor_id': course.instructorId,
      'thumbnail_url': course.thumbnailUrl ?? '',
      'enrolled_students': course.enrolledStudents,
      'sessions': course.totalSessions,
      'students': course.enrolledStudents,
      'rating': 4.5, // Default rating
      'progress': 0.0, // Will be updated based on enrollment
      'icon': _getIconForCourse(course),
    };
  }

  // Helper method to get icon based on course content
  IconData _getIconForCourse(Course course) {
    final title = course.title.toLowerCase();
    final language = course.language.toLowerCase();

    if (title.contains('japanese') || language.contains('japanese')) {
      return Icons.language;
    } else if (title.contains('spanish') || language.contains('spanish')) {
      return Icons.chat;
    } else if (title.contains('german') || language.contains('german')) {
      return Icons.book;
    } else if (title.contains('french') || language.contains('french')) {
      return Icons.book;
    } else if (title.contains('italian') || language.contains('italian')) {
      return Icons.flight_takeoff;
    } else if (title.contains('business') || title.contains('english')) {
      return Icons.business;
    } else if (title.contains('chinese') || title.contains('mandarin')) {
      return Icons.translate;
    } else if (title.contains('korean')) {
      return Icons.translate;
    } else if (title.contains('russian')) {
      return Icons.language;
    } else if (title.contains('portuguese')) {
      return Icons.business_center;
    } else {
      return Icons.school;
    }
  }

  String _getLocalizedCategory(String category, BuildContext context) {
    switch (category) {
      case 'Beginner':
        return AppLocalizations.of(context)!.beginner;
      case 'Intermediate':
        return AppLocalizations.of(context)!.intermediate;
      case 'Advanced':
        return AppLocalizations.of(context)!.advanced;
      default:
        return category;
    }
  }

  void _navigateToCourse(Map<String, dynamic> course) async {
    // Check if user is currently enrolled (has progress > 0)
    final isCurrentlyEnrolled =
        course['progress'] != null && course['progress'] > 0;

    if (isCurrentlyEnrolled) {
      // Navigate to course portal for enrolled courses
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CoursePortalPage(course: course)),
      );
    } else {
      // Navigate to course details for unenrolled courses (including completed/deadline-over courses)
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UnenrolledCourseDetailsPage(course: course),
        ),
      );

      // If enrollment was successful, refresh the courses and switch to "My Courses" tab
      if (result != null && result is Map && result['enrolled'] == true) {
        // Refresh course data
        final courseProvider = Provider.of<CourseProvider>(
          context,
          listen: false,
        );
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        await courseProvider.loadCourses();
        if (authProvider.currentUser != null) {
          await courseProvider.loadLearnerEnrollments(
            authProvider.currentUser.id,
          );
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully enrolled! Check "My Courses" tab.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<AuthProvider, CourseProvider>(
      builder: (context, authProvider, courseProvider, child) {
        // Show loading state
        if (courseProvider.isLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: AppBar(
                automaticallyImplyLeading: false,
                scrolledUnderElevation: 0,
                title: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () =>
                          SettingsProvider.showSettingsBottomSheet(context),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.learn,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationsPage(),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          right: 11,
                          top: 11,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7A54FF)),
              ),
            ),
          );
        }

        // Show error state if any
        if (courseProvider.hasError) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: AppBar(
                automaticallyImplyLeading: false,
                scrolledUnderElevation: 0,
                title: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () =>
                          SettingsProvider.showSettingsBottomSheet(context),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.learn,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationsPage(),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          right: 11,
                          top: 11,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading courses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    courseProvider.error ?? 'Unknown error',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7A54FF),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Main content
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: AppBar(
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0,
              title: Row(
                children: [
                  // 🔧 SETTINGS ICON - This is the settings button in the app bar
                  // Click this to open the settings bottom sheet with theme and language options
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () =>
                        SettingsProvider.showSettingsBottomSheet(context),
                  ),

                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.learn,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  // 🔔 NOTIFICATION ICON - This is the notification button in the app bar
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      // Red dot for unread notifications
                      Positioned(
                        right: 11,
                        top: 11,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '3', // Number of unread notifications
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(child: _buildMainContent(isDark)),
        );
      },
    );
  }

  Widget _buildMainContent(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingHeader(isDark),
          const SizedBox(height: 20),
          _buildSearchBar(isDark),
          const SizedBox(height: 30),
          _buildMyCoursesSection(isDark),
          const SizedBox(height: 30),
          _buildTopCategorySection(isDark),
          const SizedBox(height: 30),
          _buildPopularCoursesSection(isDark),
          const SizedBox(height: 30),
          _buildCompletedCoursesSection(isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.hello,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
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
            child: userProfileImage.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      userProfileImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF7A54FF).withOpacity(0.8),
                              Color(0xFF7A54FF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF7A54FF).withOpacity(0.8),
                          Color(0xFF7A54FF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    // Convert courses to maps for compatibility
    final allCourseMaps = _allCourses
        .map((course) => _courseToMap(course))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchCoursesPage(allCourses: allCourseMaps),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.searchYourCourseHere,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyCoursesSection(bool isDark) {
    final enrolledCourseMaps = _enrolledCourses
        .map((course) => _courseToMap(course))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.myCourses,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MyCoursesPage(courses: enrolledCourseMaps),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: TextStyle(
                    color: Color(0xFF7A54FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _enrolledCourses.isEmpty
                ? Center(
                    child: Text(
                      'No enrolled courses yet',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _enrolledCourses.length,
                    itemBuilder: (context, index) {
                      return _buildEnrolledCourseCard(
                        _courseToMap(_enrolledCourses[index]),
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrolledCourseCard(Map<String, dynamic> course, bool isDark) {
    final progress = course['progress']?.toDouble() ?? 0.0;

    // Calculate status from map data
    final now = DateTime.now();
    final startDate = DateTime.tryParse(course['startDate'] ?? '');
    final endDate = DateTime.tryParse(course['endDate'] ?? '');

    String status = 'active';
    if (startDate != null && endDate != null) {
      if (now.isBefore(startDate)) {
        status = 'upcoming';
      } else if (now.isAfter(endDate)) {
        status = 'expired';
      } else {
        status = 'active';
      }
    }

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToCourse(course),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Color(0xFF7A54FF).withOpacity(0.8),
                Color(0xFF7A54FF).withOpacity(0.9),
                Color(0xFF7A54FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background gradient - no thumbnail needed
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF7A54FF).withOpacity(0.8),
                        Color(0xFF7A54FF).withOpacity(0.9),
                        Color(0xFF7A54FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Content overlay
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course icon
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        course['icon'] ?? Icons.school,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    const Spacer(),

                    // Course title
                    Text(
                      course['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Sessions info
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.sessionsCount((course['sessions'] ?? 0).toString()),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Progress bar or status badge
                    if (status == 'expired') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'Expired',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else ...[
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 3,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.completedPercentage(
                          ((progress * 100).toInt()).toString(),
                        ),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
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

  Widget _buildTopCategorySection(bool isDark) {
    final allCourseMaps = _allCourses
        .map((course) => _courseToMap(course))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.levelCategory,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SearchCoursesPage(allCourses: allCourseMaps),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: TextStyle(
                    color: Color(0xFF7A54FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryChip(
                  categories[index],
                  isDark,
                  allCourseMaps,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    String category,
    bool isDark,
    List<Map<String, dynamic>> allCourses,
  ) {
    // Define icons for each category
    IconData getIconForCategory(String category) {
      switch (category) {
        case 'Beginner':
          return Icons.school_outlined;
        case 'Intermediate':
          return Icons.trending_up_outlined;
        case 'Advanced':
          return Icons.star_outline;
        default:
          return Icons.category_outlined;
      }
    }

    return Container(
      margin: const EdgeInsets.only(right: 12),
      // height: 20,
      // color: Colors.black,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchCoursesPage(
                allCourses: allCourses,
                initialFilter: category,
              ),
            ),
          );
        },

        child: Container(
          // height: 20,
          decoration: BoxDecoration(
            color: Color(0xFF7A54FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.08),
            //     blurRadius: 4,
            //     offset: const Offset(0, 2),
            //   ),
            // ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular icon with deeper purple background
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF7A54FF).withOpacity(0.8),
                ),
                child: Icon(
                  getIconForCategory(category),
                  size: 17,
                  color: Colors.white,
                ),
              ),
              // Purple text - minimal padding
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  _getLocalizedCategory(category, context),
                  style: TextStyle(
                    color: Color(0xFF7A54FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularCoursesSection(bool isDark) {
    // Show only first 3 popular courses
    final limitedCourses = _popularCourses.take(3).toList();
    final allCourseMaps = _allCourses
        .map((course) => _courseToMap(course))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.popularCourses,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchCoursesPage(
                        allCourses: allCourseMaps,
                        initialFilter: 'Popular',
                      ),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: TextStyle(
                    color: Color(0xFF7A54FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          limitedCourses.isEmpty
              ? Center(
                  child: Text(
                    'No popular courses available',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: limitedCourses.length,
                  itemBuilder: (context, index) {
                    return _buildPopularCourseCard(
                      _courseToMap(limitedCourses[index]),
                      isDark,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPopularCourseCard(Map<String, dynamic> course, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToCourse(course),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Course thumbnail/cover
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF7A54FF).withOpacity(0.8),
                      Color(0xFF7A54FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  course['icon'] ?? Icons.school,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Course details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    Text(
                      AppLocalizations.of(
                        context,
                      )!.byInstructor(course['instructor'] ?? ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${course['rating'] ?? 0}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.play_circle_outline,
                          size: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${course['sessions'] ?? 0}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
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

  Widget _buildCompletedCoursesSection(bool isDark) {
    final allCourseMaps = _allCourses
        .map((course) => _courseToMap(course))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.expiredCourses,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchCoursesPage(
                        allCourses: allCourseMaps,
                        initialFilter: 'Expired',
                      ),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: TextStyle(
                    color: Color(0xFF7A54FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _expiredCourses.isEmpty
                ? Center(
                    child: Text(
                      'No expired courses available',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _expiredCourses.length,
                    itemBuilder: (context, index) {
                      return _buildCompletedCourseCard(
                        _courseToMap(_expiredCourses[index]),
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCourseCard(Map<String, dynamic> course, bool isDark) {
    // final status = _getCourseStatus(course);

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToCourse(course),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.green.withOpacity(0.8),
                Colors.green.withOpacity(0.9),
                Colors.green,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.8),
                        Colors.green.withOpacity(0.9),
                        Colors.green,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Content overlay
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course icon with expired badge
                    Stack(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            course['icon'] ?? Icons.school,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: Colors.green,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Course title
                    Text(
                      course['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Sessions info
                    Text(
                      '${course['sessions'] ?? 0} Sessions',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Expired badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Expired',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Price badge
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${course['price']?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
