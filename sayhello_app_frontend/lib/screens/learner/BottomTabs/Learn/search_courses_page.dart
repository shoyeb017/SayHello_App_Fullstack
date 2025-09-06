import 'package:flutter/material.dart';
import 'Enrolled/course_portal.dart';
import 'Unenrolled/unenrolled_course_details.dart';
import '../../../../../l10n/app_localizations.dart';

class SearchCoursesPage extends StatefulWidget {
  final List<Map<String, dynamic>> allCourses;
  final String?
  initialFilter; // 'Beginner', 'Intermediate', 'Advanced', 'Popular'

  const SearchCoursesPage({
    super.key,
    required this.allCourses,
    this.initialFilter,
  });

  @override
  State<SearchCoursesPage> createState() => _SearchCoursesPageState();
}

class _SearchCoursesPageState extends State<SearchCoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCourses = [];
  String _selectedLevelFilter = 'All';
  String _selectedStatusFilter = 'All';
  bool _showPopularOnly = false;

  final List<String> _levelFilters = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  final List<String> _statusFilters = ['All', 'Upcoming', 'Active', 'Expired'];

  String _getLocalizedLevel(String level, BuildContext context) {
    switch (level) {
      case 'All':
        return AppLocalizations.of(context)!.all;
      case 'Beginner':
        return AppLocalizations.of(context)!.beginner;
      case 'Intermediate':
        return AppLocalizations.of(context)!.intermediate;
      case 'Advanced':
        return AppLocalizations.of(context)!.advanced;
      default:
        return level;
    }
  }

  String _getLocalizedStatus(String status, BuildContext context) {
    switch (status) {
      case 'All':
        return AppLocalizations.of(context)!.all;
      case 'Upcoming':
        return AppLocalizations.of(context)!.upcoming;
      case 'Active':
        return AppLocalizations.of(context)!.active;
      case 'Expired':
        return AppLocalizations.of(context)!.expired;
      default:
        return status;
    }
  }

  @override
  void initState() {
    super.initState();
    _filteredCourses = widget.allCourses;
    if (widget.initialFilter != null) {
      // Handle initial filter mapping
      switch (widget.initialFilter!) {
        case 'Beginner':
        case 'Intermediate':
        case 'Advanced':
          _selectedLevelFilter = widget.initialFilter!;
          break;
        case 'Popular':
          _showPopularOnly = true;
          break;
        case 'Expired':
          _selectedStatusFilter = 'Expired';
          break;
        case 'Active':
          _selectedStatusFilter = 'Active';
          break;
        case 'Upcoming':
          _selectedStatusFilter = 'Upcoming';
          break;
      }
      _applyFilter();
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilter();
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

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredCourses = widget.allCourses.where((course) {
        // Search filter - enhanced search functionality
        bool matchesSearch = true;
        if (query.isNotEmpty) {
          final title = (course['title'] ?? '').toString().toLowerCase();
          final instructor = (course['instructor'] ?? '')
              .toString()
              .toLowerCase();
          final category = (course['category'] ?? '').toString().toLowerCase();
          final description = (course['description'] ?? '')
              .toString()
              .toLowerCase();

          // Search in multiple fields
          matchesSearch =
              title.contains(query) ||
              instructor.contains(query) ||
              category.contains(query) ||
              description.contains(query);
        }

        // Level filter - Fixed case sensitivity and comparison
        bool matchesLevel = true;
        if (_selectedLevelFilter != 'All') {
          final courseLevel = (course['level'] ?? '').toString();
          matchesLevel =
              courseLevel.toLowerCase() == _selectedLevelFilter.toLowerCase();
        }

        // Status filter
        bool matchesStatus = true;
        if (_selectedStatusFilter != 'All') {
          final calculatedStatus = _getCourseStatus(course);
          matchesStatus =
              calculatedStatus == _selectedStatusFilter.toLowerCase();
        }

        // Popular filter - Made criteria more flexible
        bool matchesPopular = true;
        if (_showPopularOnly) {
          final rating = course['rating'] ?? 0;
          final students = course['students'] ?? 0;
          final isPopular = course['isPopular'] ?? false;

          // A course is popular if:
          // 1. It has high rating (4.0+) OR
          // 2. It has many students (50+) OR
          // 3. It's explicitly marked as popular
          matchesPopular = rating >= 4.0 || students >= 50 || isPopular == true;
        }

        return matchesSearch && matchesLevel && matchesStatus && matchesPopular;
      }).toList();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedLevelFilter = 'All';
      _selectedStatusFilter = 'All';
      _showPopularOnly = false;
      _searchController.clear();
    });
    _applyFilter();
  }

  void _navigateToCourse(Map<String, dynamic> course) {
    final isEnrolled = course['progress'] != null && course['progress'] > 0;

    if (isEnrolled) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CoursePortalPage(course: course)),
      );
    } else {
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          AppLocalizations.of(context)!.searchCourses,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Container(
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
                    hintText: AppLocalizations.of(context)!.searchCoursesByName,
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
            ),

            // Filter chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level filter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.level,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _levelFilters.length,
                          itemBuilder: (context, index) {
                            final filter = _levelFilters[index];
                            final isSelected = _selectedLevelFilter == filter;

                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedLevelFilter = filter;
                                  });
                                  _applyFilter();
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Color(0xFF7A54FF)
                                        : (isDark
                                              ? Colors.grey[800]
                                              : Colors.white),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Color(0xFF7A54FF)
                                          : (isDark
                                                ? Colors.grey[600]!
                                                : Colors.grey[300]!),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _getLocalizedLevel(filter, context),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.white
                                                : Colors.black),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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

                  const SizedBox(height: 16),

                  // Status filter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _statusFilters.length,
                          itemBuilder: (context, index) {
                            final filter = _statusFilters[index];
                            final isSelected = _selectedStatusFilter == filter;

                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedStatusFilter = filter;
                                  });
                                  _applyFilter();
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Color(0xFF7A54FF)
                                        : (isDark
                                              ? Colors.grey[800]
                                              : Colors.white),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Color(0xFF7A54FF)
                                          : (isDark
                                                ? Colors.grey[600]!
                                                : Colors.grey[300]!),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _getLocalizedStatus(filter, context),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.white
                                                : Colors.black),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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

                  const SizedBox(height: 16),

                  // Popular filter toggle
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showPopularOnly = !_showPopularOnly;
                          });
                          _applyFilter();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _showPopularOnly
                                ? Color(0xFF7A54FF)
                                : (isDark ? Colors.grey[800] : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _showPopularOnly
                                  ? Color(0xFF7A54FF)
                                  : (isDark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: _showPopularOnly
                                    ? Colors.white
                                    : Color(0xFF7A54FF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.showPopularOnly,
                                style: TextStyle(
                                  color: _showPopularOnly
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Results count and clear filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.coursesFound(
                      _filteredCourses.length.toString(),
                      _filteredCourses.length != 1 ? 's' : '',
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  // Clear filters button
                  if (_selectedLevelFilter != 'All' ||
                      _selectedStatusFilter != 'All' ||
                      _showPopularOnly ||
                      _searchController.text.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearAllFilters,
                      icon: Icon(
                        Icons.clear_all,
                        size: 16,
                        color: Color(0xFF7A54FF),
                      ),
                      label: Text(
                        'Clear Filters',
                        style: TextStyle(
                          color: Color(0xFF7A54FF),
                          fontSize: 12,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size(0, 0),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Courses list
            _filteredCourses.isEmpty
                ? Container(
                    height: 300,
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
                            AppLocalizations.of(context)!.noCoursesFound,
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      return _buildCourseCard(_filteredCourses[index], isDark);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, bool isDark) {
    final isEnrolled = course['progress'] != null && course['progress'] > 0;

    // Debug course data
    final courseLevel = course['level']?.toString() ?? 'Unknown';
    final courseRating = course['rating'] ?? 0;
    final courseStudents = course['students'] ?? 0;
    final isPopularCourse = course['isPopular'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
              // Course image/thumbnail
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      isEnrolled
                          ? Colors.purple.withOpacity(0.8)
                          : Colors.blue.withOpacity(0.8),
                      isEnrolled
                          ? Colors.purple.shade600
                          : Colors.blue.shade600,
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
                    // Title and level badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course['title'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (courseLevel.toLowerCase() != 'unknown')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF7A54FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Color(0xFF7A54FF).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              courseLevel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7A54FF),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Instructor and rating/students
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course['instructor'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (courseRating > 0)
                          Row(
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.amber),
                              SizedBox(width: 2),
                              Text(
                                courseRating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        if (courseStudents > 0) ...[
                          SizedBox(width: 8),
                          Text(
                            '${courseStudents}+',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (isEnrolled) ...[
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.completedPercentage(
                          (((course['progress'] ?? 0) * 100).toInt())
                              .toString(),
                        ),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF7A54FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStatusBadge(_getCourseStatus(course)),
                          if (isPopularCourse ||
                              courseRating >= 4.0 ||
                              courseStudents >= 50) ...[
                            SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '⭐ Popular',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Price or enrolled indicator
              if (!isEnrolled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '\$${course['price']?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.enrolled,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A54FF),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'upcoming':
        badgeColor = Colors.orange;
        displayText = AppLocalizations.of(context)!.upcoming;
        break;
      case 'active':
        badgeColor = Colors.blue;
        displayText = AppLocalizations.of(context)!.active;
        break;
      case 'expired':
        badgeColor = Colors.green;
        displayText = AppLocalizations.of(context)!.expired;
        break;
      default:
        badgeColor = Colors.grey;
        displayText = AppLocalizations.of(context)!.unknown;
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
}
