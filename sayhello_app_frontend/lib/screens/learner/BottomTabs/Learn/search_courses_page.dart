import 'package:flutter/material.dart';
import 'Enrolled/course_portal.dart';
import 'Unenrolled/unenrolled_course_details.dart';

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
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Popular',
  ];

  @override
  void initState() {
    super.initState();
    _filteredCourses = widget.allCourses;
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
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

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = widget.allCourses.where((course) {
        // Search filter
        bool matchesSearch = true;
        if (query.isNotEmpty) {
          final title = (course['title'] ?? '').toString().toLowerCase();
          final instructor = (course['instructor'] ?? '')
              .toString()
              .toLowerCase();
          final category = (course['category'] ?? '').toString().toLowerCase();
          matchesSearch =
              title.contains(query) ||
              instructor.contains(query) ||
              category.contains(query);
        }

        // Category filter
        bool matchesCategory = true;
        if (_selectedFilter != 'All') {
          if (_selectedFilter == 'Popular') {
            // Assuming popular courses have rating >= 4.5 or high student count
            matchesCategory =
                (course['rating'] ?? 0) >= 4.5 ||
                (course['students'] ?? 0) >= 100;
          } else {
            matchesCategory = course['level'] == _selectedFilter;
          }
        }

        return matchesSearch && matchesCategory;
      }).toList();
    });
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
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.grey[50],
        title: Text(
          'Search Courses',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
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
      body: Column(
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
                  hintText: 'Search courses...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 16,
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
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _applyFilter();
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.purple
                            : (isDark ? Colors.grey[800] : Colors.white),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? Colors.purple
                              : (isDark
                                    ? Colors.grey[600]!
                                    : Colors.grey[300]!),
                          width: 1,
                        ),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filteredCourses.length} course${_filteredCourses.length != 1 ? 's' : ''} found',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Courses list
          Expanded(
            child: _filteredCourses.isEmpty
                ? Center(
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
                          'No courses found',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      return _buildCourseCard(_filteredCourses[index], isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, bool isDark) {
    final isEnrolled = course['progress'] != null && course['progress'] > 0;

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
                      course['instructor'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isEnrolled) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${((course['progress'] ?? 0) * 100).toInt()}% completed',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
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
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Enrolled',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
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
