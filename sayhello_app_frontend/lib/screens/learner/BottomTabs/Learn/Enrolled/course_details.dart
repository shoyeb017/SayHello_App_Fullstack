import 'package:flutter/material.dart';

class CourseDetails extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetails({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Extract all course data with fallback values
    final title = course['title'] ?? 'Course Title';
    final description =
        course['description'] ??
        'This is a comprehensive course designed to help you master the language.';
    final language = course['language'] ?? 'English';
    final level = course['level'] ?? 'Beginner';
    final instructor = course['instructor'] ?? 'John Doe';
    final startDate = course['startDate'] ?? '2025-07-15';
    final endDate = course['endDate'] ?? '2025-09-15';
    final duration = course['duration'] ?? '4 weeks';
    final status = course['status'] ?? 'active';
    final rating = course['rating'] ?? 4.7;
    final enrolledStudents = course['students'] ?? 42;
    final price =
        double.tryParse(course['price']?.toString() ?? '49.99') ?? 49.99;
    final thumbnail = course['thumbnail'] ?? '';
    final category = course['category'] ?? 'Language';

    // Consistent color scheme with new theme
    final primaryColor = Color(0xFF7A54FF);
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = isDark ? Colors.grey[800] : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header with Thumbnail
          _buildCourseHeader(
            title,
            instructor,
            thumbnail,
            level,
            status,
            category,
            duration,
            isDark,
            primaryColor,
            textColor,
            cardColor,
          ),

          const SizedBox(height: 20),

          // Rating and Enrollment Stats
          _buildStatsSection(
            rating,
            enrolledStudents,
            price,
            language,
            isDark,
            primaryColor,
            textColor,
            subTextColor,
            cardColor,
          ),

          const SizedBox(height: 20),

          // Course Description
          _buildDescriptionSection(
            description,
            isDark,
            primaryColor,
            textColor,
            subTextColor,
            cardColor,
          ),

          const SizedBox(height: 20),

          // Course Details Grid
          _buildDetailsGrid(
            startDate,
            endDate,
            duration,
            level,
            language,
            status,
            isDark,
            primaryColor,
            textColor,
            subTextColor,
            cardColor,
          ),

          const SizedBox(height: 20),

          // Enrollment Status
          _buildEnrollmentStatus(status, primaryColor),
        ],
      ),
    );
  }

  Widget _buildCourseHeader(
    String title,
    String instructor,
    String thumbnail,
    String level,
    String status,
    String category,
    String duration,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color? cardColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Thumbnail Section
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: thumbnail.isEmpty
                  ? LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.8),
                        primaryColor,
                        primaryColor.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              image: thumbnail.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(thumbnail),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                if (thumbnail.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.school,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Status Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildStatusBadge(status),
                ),

                // Level Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      level,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Duration Badge
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: const TextStyle(
                            color: Colors.white,
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
          ),

          // Course Title and Instructor
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 18, color: primaryColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'by $instructor',
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'active':
        statusColor = Color(0xFF7A54FF);
        statusIcon = Icons.play_circle;
        break;
      case 'upcoming':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    double rating,
    int enrolledStudents,
    double price,
    String language,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    Color? cardColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rating
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Rating',
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Container(height: 40, width: 1, color: Colors.grey.shade300),

          // Students
          Expanded(
            child: Column(
              children: [
                Text(
                  enrolledStudents.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Students',
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Container(height: 40, width: 1, color: Colors.grey.shade300),

          // Price
          Expanded(
            child: Column(
              children: [
                Text(
                  '\$${price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Container(height: 40, width: 1, color: Colors.grey.shade300),

          // Language
          Expanded(
            child: Column(
              children: [
                Icon(Icons.language, color: primaryColor, size: 20),
                const SizedBox(height: 4),
                Text(
                  language,
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(
    String description,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    Color? cardColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'Course Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(fontSize: 15, color: subTextColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(
    String startDate,
    String endDate,
    String duration,
    String level,
    String language,
    String status,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    Color? cardColor,
  ) {
    final details = [
      {'title': 'Start Date', 'value': startDate, 'icon': Icons.calendar_today},
      {'title': 'End Date', 'value': endDate, 'icon': Icons.event_available},
      {'title': 'Duration', 'value': duration, 'icon': Icons.schedule},
      {'title': 'Level', 'value': level, 'icon': Icons.signal_cellular_alt},
      {'title': 'Language', 'value': language, 'icon': Icons.language},
      {'title': 'Status', 'value': status, 'icon': Icons.info_outline},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.grey.shade200,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    detail['icon'] as IconData,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detail['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  detail['value'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnrollmentStatus(String status, Color primaryColor) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Course Completed';
        break;
      case 'active':
        statusColor = primaryColor;
        statusIcon = Icons.play_circle;
        statusText = 'Currently Enrolled';
        break;
      case 'upcoming':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Enrollment Confirmed';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = 'Enrollment Status';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
