import 'package:flutter/material.dart';
import 'Enrolled/course_portal.dart';
import 'Unenrolled/unenrolled_course_details.dart';
import 'search_courses_page.dart';
import 'my_courses_page.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../Notifications/notifications.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  // User data
  final String userName = "Zeeshan Hamayoun";
  final String userProfileImage = ""; // Add actual image URL

  // Categories
  final List<String> categories = ['Beginner', 'Intermediate', 'Advanced'];

  // My enrolled courses (horizontal scroll)
  final List<Map<String, dynamic>> enrolledCourses = [
    {
      'id': 'course_001',
      'title': 'Japanese for Beginners',
      'instructor': 'Hiro Tanaka',
      'rating': 4.6,
      'students': 120,
      'progress': 0.4,
      'sessions': 24,
      'completedLectures': 10,
      'icon': Icons.language,
      'thumbnail': '',
      'description':
          'Learn Japanese from basics including Hiragana, Katakana, and essential vocabulary.',
      'price': 59.99,
      'duration': '6 weeks',
      'level': 'Beginner',
      'category': 'Language',
      'startDate': '2025-08-01',
      'endDate': '2025-09-15',
    },
    {
      'id': 'course_002',
      'title': 'Conversational Spanish',
      'instructor': 'Maria Gomez',
      'rating': 4.9,
      'students': 95,
      'progress': 0.75,
      'sessions': 32,
      'completedLectures': 24,
      'icon': Icons.chat,
      'thumbnail': '',
      'description':
          'Master Spanish conversation skills through interactive sessions.',
      'price': 49.99,
      'duration': '8 weeks',
      'level': 'Intermediate',
      'category': 'Language',
      'startDate': '2025-07-15',
      'endDate': '2025-09-10',
    },
    {
      'id': 'course_003',
      'title': 'German Advanced Grammar',
      'instructor': 'Klaus Schmidt',
      'rating': 4.5,
      'students': 42,
      'progress': 1.0,
      'sessions': 20,
      'completedLectures': 20,
      'icon': Icons.book,
      'thumbnail': '',
      'description':
          'Advanced German grammar concepts for fluent communication.',
      'price': 79.99,
      'duration': '10 weeks',
      'level': 'Advanced',
      'category': 'Language',
      'startDate': '2025-06-01',
      'endDate': '2025-08-10',
    },
  ];

  // Popular courses (vertical list)
  final List<Map<String, dynamic>> popularCourses = [
    {
      'id': 'course_004',
      'title': 'French Grammar Essentials',
      'instructor': 'Jean Dupont',
      'rating': 4.2,
      'students': 60,
      'progress': 0.0,
      'sessions': 15,
      'icon': Icons.book,
      'thumbnail': '',
      'description':
          'Essential French grammar rules and structures for building a strong foundation.',
      'price': 39.99,
      'duration': '5 weeks',
      'level': 'Beginner',
      'category': 'Language',
      'startDate': '2025-08-15',
      'endDate': '2025-09-20',
    },
    {
      'id': 'course_005',
      'title': 'Italian for Travelers',
      'instructor': 'Luca Bianchi',
      'rating': 4.5,
      'students': 55,
      'progress': 0.0,
      'sessions': 12,
      'icon': Icons.flight_takeoff,
      'thumbnail': '',
      'description':
          'Learn essential Italian phrases and cultural insights for your next trip.',
      'price': 29.99,
      'duration': '4 weeks',
      'level': 'Beginner',
      'category': 'Language',
      'startDate': '2025-08-01',
      'endDate': '2025-09-01',
    },
    {
      'id': 'course_006',
      'title': 'Business English Communication',
      'instructor': 'Sarah Johnson',
      'rating': 4.7,
      'students': 180,
      'progress': 0.0,
      'sessions': 24,
      'icon': Icons.business,
      'thumbnail': '',
      'description':
          'Professional English communication skills for workplace success.',
      'price': 69.99,
      'duration': '8 weeks',
      'level': 'Intermediate',
      'category': 'Business',
      'startDate': '2025-08-10',
      'endDate': '2025-10-05',
    },
    {
      'id': 'course_007',
      'title': 'Mandarin Chinese Basics',
      'instructor': 'Li Wei',
      'rating': 4.4,
      'students': 75,
      'progress': 0.0,
      'sessions': 21,
      'icon': Icons.translate,
      'thumbnail': '',
      'description':
          'Start your Mandarin journey with pronunciation, basic characters, and essential phrases.',
      'price': 55.99,
      'duration': '7 weeks',
      'level': 'Beginner',
      'category': 'Language',
      'startDate': '2025-08-20',
      'endDate': '2025-10-10',
    },
  ];

  // Completed courses (horizontal scroll) - These are deadline-over courses available for enrollment
  final List<Map<String, dynamic>> completedCourses = [
    {
      'id': 'course_008',
      'title': 'Russian Language Fundamentals',
      'instructor': 'Dmitri Volkov',
      'rating': 4.3,
      'students': 85,
      'progress': 0.0, // User not enrolled yet
      'sessions': 18,
      'icon': Icons.language,
      'thumbnail': '',
      'description':
          'Complete Russian language course covering basics to intermediate level.',
      'price': 65.99,
      'duration': '6 weeks',
      'level': 'Beginner',
      'category': 'Language',
      'startDate': '2024-01-01',
      'endDate': '2024-01-15',
    },
    {
      'id': 'course_009',
      'title': 'Portuguese for Business',
      'instructor': 'Ana Santos',
      'rating': 4.6,
      'students': 67,
      'progress': 0.0, // User not enrolled yet
      'sessions': 22,
      'icon': Icons.business_center,
      'thumbnail': '',
      'description':
          'Professional Portuguese for international business communication.',
      'price': 79.99,
      'duration': '8 weeks',
      'level': 'Intermediate',
      'category': 'Business',
      'startDate': '2024-02-01',
      'endDate': '2024-02-20',
    },
    {
      'id': 'course_010',
      'title': 'Korean Language Basics',
      'instructor': 'Kim Min-jun',
      'rating': 4.4,
      'students': 92,
      'progress': 0.0, // User not enrolled yet
      'sessions': 20,
      'icon': Icons.translate,
      'thumbnail': '',
      'description':
          'Learn Korean alphabet, basic grammar, and essential vocabulary.',
      'price': 54.99,
      'duration': '7 weeks',
      'level': 'Beginner',
      'category': 'Language',
      'startDate': '2024-03-01',
      'endDate': '2024-03-10',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  void _navigateToCourse(Map<String, dynamic> course) {
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UnenrolledCourseDetailsPage(course: course),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
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
                      constraints: BoxConstraints(minWidth: 12, minHeight: 12),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchCoursesPage(
                allCourses: [
                  ...enrolledCourses,
                  ...popularCourses,
                  ...completedCourses,
                ],
              ),
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
                      builder: (_) => MyCoursesPage(courses: enrolledCourses),
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: enrolledCourses.length,
              itemBuilder: (context, index) {
                return _buildEnrolledCourseCard(enrolledCourses[index], isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrolledCourseCard(Map<String, dynamic> course, bool isDark) {
    final progress = course['progress']?.toDouble() ?? 0.0;
    final status = _getCourseStatus(course);

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
                      builder: (_) => SearchCoursesPage(
                        allCourses: [
                          ...enrolledCourses,
                          ...popularCourses,
                          ...completedCourses,
                        ],
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
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryChip(categories[index], isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isDark) {
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
                allCourses: [
                  ...enrolledCourses,
                  ...popularCourses,
                  ...completedCourses,
                ],
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
    final limitedCourses = popularCourses.take(3).toList();

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
                        allCourses: [
                          ...enrolledCourses,
                          ...popularCourses,
                          ...completedCourses,
                        ],
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: limitedCourses.length,
            itemBuilder: (context, index) {
              return _buildPopularCourseCard(limitedCourses[index], isDark);
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
                        allCourses: [
                          ...enrolledCourses,
                          ...popularCourses,
                          ...completedCourses,
                        ],
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: completedCourses.length,
              itemBuilder: (context, index) {
                return _buildCompletedCourseCard(
                  completedCourses[index],
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