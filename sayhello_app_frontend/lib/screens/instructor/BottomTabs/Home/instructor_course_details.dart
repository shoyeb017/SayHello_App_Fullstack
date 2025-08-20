import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../providers/course_provider.dart';
import '../../../../../../services/storage_service.dart';

class InstructorCourseDetailsTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorCourseDetailsTab({super.key, required this.course});

  @override
  State<InstructorCourseDetailsTab> createState() =>
      _InstructorCourseDetailsTabState();
}

class _InstructorCourseDetailsTabState
    extends State<InstructorCourseDetailsTab> {
  bool _isLoading = false;
  int _realEnrollmentCount = 0;
  double _averageRating = 0.0;
  int _imageUpdateKey = 0; // Add this to force image refresh
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    if (!mounted) return;

    final courseProvider = context.read<CourseProvider>();
    final courseId = widget.course['id']?.toString();

    if (courseId == null) return;

    try {
      // Load real enrollment count
      final enrollmentCount = await courseProvider.getEnrollmentCount(courseId);

      // Load average rating from feedback
      final rating = await _loadAverageRating(courseId);

      if (mounted) {
        setState(() {
          _realEnrollmentCount = enrollmentCount;
          _averageRating = rating;
        });
      }
    } catch (e) {
      print('Error loading course data: $e');
    }
  }

  Future<double> _loadAverageRating(String courseId) async {
    try {
      // TODO: Implement when feedback table is available
      // For now, return a default rating or calculate from existing data
      final courseProvider = context.read<CourseProvider>();
      final rating = await courseProvider.getCourseAverageRating(courseId);
      return rating;
    } catch (e) {
      print('Error loading rating: $e');
      return 0.0;
    }
  }

  // Calculate duration in weeks between start and end date
  int _calculateDurationInWeeks(String startDateStr, String endDateStr) {
    try {
      if (startDateStr.isEmpty || endDateStr.isEmpty) return 0;

      // Parse dates in either ISO format or DD/MM/YYYY format
      DateTime startDate;
      DateTime endDate;

      if (startDateStr.contains('/')) {
        // Parse DD/MM/YYYY format
        final parts = startDateStr.split('/');
        if (parts.length == 3) {
          startDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          return 0;
        }
      } else {
        startDate = DateTime.parse(startDateStr);
      }

      if (endDateStr.contains('/')) {
        // Parse DD/MM/YYYY format
        final parts = endDateStr.split('/');
        if (parts.length == 3) {
          endDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          return 0;
        }
      } else {
        endDate = DateTime.parse(endDateStr);
      }

      final difference = endDate.difference(startDate).inDays;
      return (difference / 7).round();
    } catch (e) {
      print('Error calculating duration: $e');
      return 0;
    }
  }

  // Calculate completion percentage based on current date vs duration
  int _calculateCompletionPercentage(String startDateStr, String endDateStr) {
    try {
      if (startDateStr.isEmpty || endDateStr.isEmpty) return 0;

      // Parse dates in either ISO format or DD/MM/YYYY format
      DateTime startDate;
      DateTime endDate;

      if (startDateStr.contains('/')) {
        // Parse DD/MM/YYYY format
        final parts = startDateStr.split('/');
        if (parts.length == 3) {
          startDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          return 0;
        }
      } else {
        startDate = DateTime.parse(startDateStr);
      }

      if (endDateStr.contains('/')) {
        // Parse DD/MM/YYYY format
        final parts = endDateStr.split('/');
        if (parts.length == 3) {
          endDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          return 0;
        }
      } else {
        endDate = DateTime.parse(endDateStr);
      }

      final now = DateTime.now();

      // If course hasn't started yet
      if (now.isBefore(startDate)) return 0;

      // If course has ended
      if (now.isAfter(endDate)) return 100;

      // Calculate percentage based on time passed
      final totalDuration = endDate.difference(startDate).inDays;
      final daysPassed = now.difference(startDate).inDays;

      if (totalDuration <= 0) return 0;

      final percentage = ((daysPassed / totalDuration) * 100).round();
      return percentage.clamp(0, 100);
    } catch (e) {
      print('Error calculating completion: $e');
      return 0;
    }
  }

  // Calculate total revenue (enrolled students × price)
  double _calculateTotalRevenue(int enrolledStudents, double price) {
    return enrolledStudents * price;
  }

  // Format date string to display format (DD/MM/YYYY)
  String _formatDateString(String dateStr) {
    try {
      if (dateStr.isEmpty) return '';

      // If it's already in DD/MM/YYYY format, return as is
      if (dateStr.contains('/') && dateStr.split('/').length == 3) {
        return dateStr;
      }

      // Try to parse as ISO date
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      // If parsing fails, try to extract just the date part
      final cleanDate = dateStr.split(' ').first;
      try {
        final date = DateTime.parse(cleanDate);
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e2) {
        print('Error formatting date: $e2');
        return dateStr.split(' ').first; // Return first part as fallback
      }
    }
  }

  Future<void> _refreshCourseData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final courseProvider = context.read<CourseProvider>();
    final courseId = widget.course['id']?.toString();

    if (courseId != null) {
      await courseProvider.loadCourse(courseId);

      if (courseProvider.currentCourse != null && mounted) {
        setState(() {
          // Update the course data with fresh data from backend
          final updatedCourse = courseProvider.currentCourse!;
          widget.course.addAll(updatedCourse.toJson());
        });
      }
    }

    await _loadCourseData();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        // Show loading overlay if updating
        if (_isLoading || courseProvider.isLoading) {
          return Stack(
            children: [
              _buildContent(isDark, localizations),
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF7A54FF),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return _buildContent(isDark, localizations);
      },
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations localizations) {
    // Extract course data with fallback values
    final title = widget.course['title'] ?? 'Course Title';
    final description =
        widget.course['description'] ??
        'This is a comprehensive course designed to help students master the subject with practical examples and expert guidance.';
    final language = widget.course['language'] ?? 'English';
    final level = widget.course['level'] ?? 'Intermediate';

    // Format dates properly
    final startDate = _formatDateString(
      widget.course['startDate'] ?? widget.course['start_date'] ?? '2025-07-15',
    );
    final endDate = _formatDateString(
      widget.course['endDate'] ?? widget.course['end_date'] ?? '2025-09-15',
    );

    // Calculate duration in weeks
    final durationWeeks = _calculateDurationInWeeks(startDate, endDate);
    final duration = durationWeeks > 0 ? '$durationWeeks weeks' : '8 weeks';

    final totalSessions =
        widget.course['totalSessions'] ?? widget.course['total_sessions'] ?? 24;

    // Use calculated rating or fallback
    final rating = _averageRating > 0 ? _averageRating : 0.0;

    // Use real enrollment count if available, otherwise fallback
    final enrolledStudents = _realEnrollmentCount > 0
        ? _realEnrollmentCount
        : (widget.course['students'] ?? 0);
    final price =
        double.tryParse(widget.course['price']?.toString() ?? '79.99') ?? 79.99;
    final thumbnail =
        widget.course['thumbnail'] ?? widget.course['thumbnail_url'] ?? '';
    final status = widget.course['status'] ?? 'active';

    // Calculate completion percentage based on dates
    final completionRate = _calculateCompletionPercentage(startDate, endDate);

    // Calculate total revenue
    final totalRevenue = _calculateTotalRevenue(enrolledStudents, price);

    // Color scheme
    final primaryColor = const Color(0xFF7A54FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return RefreshIndicator(
      onRefresh: _refreshCourseData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Edit Course Action - Moved to Top
            _buildEditCourseSection(
              isDark,
              primaryColor,
              textColor,
              cardColor,
              localizations,
            ),

            const SizedBox(height: 16),

            // Course Header with Thumbnail and Key Stats
            _buildCourseHeader(
              title,
              instructor: 'You',
              thumbnail: thumbnail,
              status: status,
              rating: rating,
              enrolledStudents: enrolledStudents,
              totalRevenue: totalRevenue,
              isDark: isDark,
              primaryColor: primaryColor,
              textColor: textColor,
              cardColor: cardColor,
              localizations: localizations,
            ),

            const SizedBox(height: 16),

            // Quick Stats Row
            _buildQuickStats(
              enrolledStudents,
              completionRate,
              totalSessions,
              isDark,
              primaryColor,
              textColor,
              subTextColor,
              cardColor,
              localizations,
            ),

            const SizedBox(height: 16),

            // Course Information Grid
            _buildCourseInfoGrid(
              level,
              duration,
              language,
              price,
              startDate,
              endDate,
              isDark,
              primaryColor,
              textColor,
              subTextColor,
              cardColor,
              localizations,
            ),

            const SizedBox(height: 16),

            // Description Section
            _buildDescriptionSection(
              description,
              isDark,
              primaryColor,
              textColor,
              subTextColor,
              cardColor,
              localizations,
            ),

            const SizedBox(height: 16),

            // Revenue Analytics
            _buildRevenueSection(
              price,
              enrolledStudents,
              totalRevenue,
              isDark,
              primaryColor,
              textColor,
              subTextColor,
              cardColor,
              localizations,
            ),

            const SizedBox(height: 20),
          ], // Close Column children
        ), // Close Column
      ), // Close SingleChildScrollView
    ); // Close RefreshIndicator
  }

  Widget _buildCourseHeader(
    String title, {
    required String instructor,
    required String thumbnail,
    required String status,
    required double rating,
    required int enrolledStudents,
    required double totalRevenue,
    required bool isDark,
    required Color primaryColor,
    required Color textColor,
    required Color? cardColor,
    required AppLocalizations localizations,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Thumbnail Section
          Container(
            key: ValueKey(
              'course_image_$_imageUpdateKey',
            ), // Add key for image refresh
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
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
                        Icon(Icons.school, size: 40, color: Colors.white),
                        const SizedBox(height: 6),
                        Text(
                          localizations.courseThumbnail,
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
                  top: 10,
                  right: 10,
                  child: _buildStatusBadge(status),
                ),
                // Revenue Badge
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_money, size: 12, color: Colors.white),
                        Text(
                          '\$${totalRevenue.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Change Image Button
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _changeImage(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A54FF).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Change Image',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Course Title and Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
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
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.people, size: 14, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '$enrolledStudents ${localizations.studentsCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: FontWeight.w500,
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
        statusColor = const Color(0xFF7A54FF);
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    int enrolledStudents,
    int completionRate,
    int totalSessions,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    Color? cardColor,
    AppLocalizations localizations,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            localizations.coursesStudents,
            enrolledStudents.toString(),
            Icons.people,
            primaryColor,
            textColor,
            subTextColor,
          ),
          _buildDivider(),
          _buildStatItem(
            localizations.completion,
            '$completionRate%',
            Icons.check_circle,
            Colors.green,
            textColor,
            subTextColor,
          ),
          _buildDivider(),
          _buildStatItem(
            localizations.sessions,
            totalSessions.toString(),
            Icons.video_library,
            Colors.blue,
            textColor,
            subTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    Color textColor,
    Color subTextColor,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: subTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildCourseInfoGrid(
    String level,
    String duration,
    String language,
    double price,
    String startDate,
    String endDate,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    Color? cardColor,
    AppLocalizations localizations,
  ) {
    final details = [
      {
        'title': localizations.level,
        'value': level,
        'icon': Icons.signal_cellular_alt,
      },
      {
        'title': localizations.duration,
        'value': duration,
        'icon': Icons.schedule,
      },
      {
        'title': localizations.language,
        'value': language,
        'icon': Icons.language,
      },
      {
        'title': localizations.price,
        'value': '\$${price.toStringAsFixed(2)}',
        'icon': Icons.attach_money,
      },
      {
        'title': localizations.starts,
        'value': startDate,
        'icon': Icons.calendar_today,
      },
      {'title': 'End Date', 'value': endDate, 'icon': Icons.event_available},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final detail = details[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.grey.shade200,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(detail['icon'] as IconData, color: primaryColor, size: 16),
              const SizedBox(height: 6),
              Text(
                detail['title'] as String,
                style: TextStyle(
                  fontSize: 9,
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  detail['value'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescriptionSection(
    String description,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    Color? cardColor,
    AppLocalizations localizations,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: primaryColor, size: 16),
              const SizedBox(width: 6),
              Text(
                localizations.courseDescription,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: subTextColor, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSection(
    double price,
    int enrolledStudents,
    double totalRevenue,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    Color? cardColor,
    AppLocalizations localizations,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monetization_on, color: Colors.green, size: 16),
              const SizedBox(width: 6),
              Text(
                localizations.revenueAnalytics,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRevenueItem(
                  localizations.coursePrice,
                  '\$${price.toStringAsFixed(0)}',
                  Icons.local_offer,
                  primaryColor,
                  textColor,
                  subTextColor,
                ),
              ),
              Expanded(
                child: _buildRevenueItem(
                  localizations.totalRevenue,
                  '\$${totalRevenue.toStringAsFixed(0)}',
                  Icons.account_balance_wallet,
                  Colors.green,
                  textColor,
                  subTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(
    String label,
    String value,
    IconData icon,
    Color color,
    Color textColor,
    Color subTextColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: subTextColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEditCourseSection(
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color? cardColor,
    AppLocalizations localizations,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit, color: primaryColor, size: 16),
              const SizedBox(width: 6),
              Text(
                localizations.courseManagement,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.edit, size: 16, color: Colors.white),
                  label: Text(
                    'Edit',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _showEditCourseDialog(localizations),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.delete, size: 16, color: Colors.white),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _showDeleteCourseDialog(localizations),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteCourseDialog(AppLocalizations localizations) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseTitle = widget.course['title'] ?? 'this course';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(
              'Delete Course',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete "$courseTitle"?',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone. All course content and enrollments will be permanently deleted.',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.cancel,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _deleteCourse(context, localizations),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: Text('Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCourse(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    final courseProvider = context.read<CourseProvider>();
    final courseId = widget.course['id']?.toString();

    if (courseId == null) {
      _showSnackBar(context, 'Course ID is required', isError: true);
      return;
    }

    // Close dialog and show loading
    Navigator.pop(context);
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await courseProvider.deleteCourse(courseId);

      if (success && mounted && context.mounted) {
        // Refresh the course provider to update the course list/portal
        // Use loadInstructorCourses instead of loadCourses for instructor view
        if (widget.course['instructor_id'] != null) {
          await courseProvider.loadInstructorCourses(
            widget.course['instructor_id'].toString(),
          );
        }

        _showSnackBar(
          context,
          'Course deleted successfully! 🗑️',
          isError: false,
        );

        // Navigate back to courses list after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && context.mounted) {
            Navigator.pop(context);
          }
        });
      } else if (mounted && context.mounted) {
        _showSnackBar(
          context,
          courseProvider.error ?? 'Failed to delete course',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted && context.mounted) {
        _showSnackBar(context, 'Failed to delete course: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEditCourseDialog(AppLocalizations localizations) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseProvider = context.read<CourseProvider>();

    // Controllers for form fields
    final titleController = TextEditingController(
      text: widget.course['title'] ?? '',
    );
    final descriptionController = TextEditingController(
      text: widget.course['description'] ?? '',
    );
    final sessionsController = TextEditingController(
      text:
          widget.course['total_sessions']?.toString() ??
          widget.course['totalSessions']?.toString() ??
          '',
    );

    // Date state
    DateTime? selectedStartDate;
    DateTime? selectedEndDate;

    // Initialize dates from course data
    try {
      if (widget.course['start_date'] != null) {
        selectedStartDate = DateTime.parse(widget.course['start_date']);
      }
      if (widget.course['end_date'] != null) {
        selectedEndDate = DateTime.parse(widget.course['end_date']);
      }
    } catch (e) {
      // Fallback to current date
      selectedStartDate = DateTime.now();
      selectedEndDate = DateTime.now().add(const Duration(days: 60));
    }

    // Normalize level to lowercase for database
    String selectedLevel = _normalizeLevel(widget.course['level']);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7A54FF),
                        const Color(0xFF9C7AFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Course Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Update your course information',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Title
                        _buildModernTextField(
                          label: 'Course Title',
                          controller: titleController,
                          icon: Icons.title,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        _buildModernTextField(
                          label: 'Description',
                          controller: descriptionController,
                          icon: Icons.description,
                          isDark: isDark,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Level Selection
                        _buildModernDropdown(
                          label: 'Course Level',
                          value: selectedLevel,
                          icon: Icons.signal_cellular_alt,
                          items: ['beginner', 'intermediate', 'advanced'],
                          onChanged: (value) =>
                              setDialogState(() => selectedLevel = value!),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        // Total Sessions
                        _buildModernTextField(
                          label: 'Total Sessions',
                          controller: sessionsController,
                          icon: Icons.video_library,
                          isDark: isDark,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // Start Date
                        _buildDatePicker(
                          label: 'Start Date',
                          selectedDate: selectedStartDate,
                          icon: Icons.calendar_today,
                          onDateSelected: (date) =>
                              setDialogState(() => selectedStartDate = date),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        // End Date
                        _buildDatePicker(
                          label: 'End Date',
                          selectedDate: selectedEndDate,
                          icon: Icons.event_available,
                          onDateSelected: (date) =>
                              setDialogState(() => selectedEndDate = date),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey[600]!
                                  : Colors.grey[400]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            localizations.cancel,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            print('Save Changes button pressed');
                            _updateCourseModern(
                              context,
                              courseProvider,
                              localizations,
                              titleController.text,
                              descriptionController.text,
                              selectedLevel,
                              sessionsController.text,
                              widget.course['thumbnail_url'] ??
                                  widget.course['thumbnail'] ??
                                  '',
                              selectedStartDate,
                              selectedEndDate,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A54FF),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to normalize level
  String _normalizeLevel(String? level) {
    if (level == null) return 'beginner';
    final levelLower = level.toLowerCase();
    switch (levelLower) {
      case 'beginner':
        return 'beginner';
      case 'intermediate':
        return 'intermediate';
      case 'advanced':
        return 'advanced';
      default:
        return 'beginner';
    }
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF7A54FF), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              hintText: 'Enter $label',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF7A54FF), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            dropdownColor: isDark ? Colors.grey[800] : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item[0].toUpperCase() + item.substring(1)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required IconData icon,
    required Function(DateTime) onDateSelected,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: const Color(0xFF7A54FF),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  onDateSelected(picked);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(icon, color: const Color(0xFF7A54FF), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedDate != null
                            ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                            : 'Select Date',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateCourseModern(
    BuildContext context,
    CourseProvider courseProvider,
    AppLocalizations localizations,
    String title,
    String description,
    String level,
    String sessionsStr,
    String thumbnailUrl,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    print('_updateCourseModern called with title: $title, level: $level');
    // Validation
    if (title.trim().isEmpty) {
      _showSnackBar(context, 'Title cannot be empty', isError: true);
      return;
    }

    if (description.trim().isEmpty) {
      _showSnackBar(context, 'Description cannot be empty', isError: true);
      return;
    }

    final sessions = int.tryParse(sessionsStr);
    if (sessions == null || sessions <= 0) {
      _showSnackBar(
        context,
        'Please enter a valid number of sessions',
        isError: true,
      );
      return;
    }

    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      _showSnackBar(
        context,
        'Start date must be before end date',
        isError: true,
      );
      return;
    }

    // Store the main context before closing dialog
    final mainContext = this.context;

    // Close dialog and show loading
    Navigator.pop(context);
    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare update data
      final updateData = <String, dynamic>{
        'title': title.trim(),
        'description': description.trim(),
        'level': level,
        'total_sessions': sessions,
      };

      if (thumbnailUrl.isNotEmpty) {
        updateData['thumbnail_url'] = thumbnailUrl;
      }

      if (startDate != null) {
        updateData['start_date'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        updateData['end_date'] = endDate.toIso8601String();
      }

      // Get course ID
      final courseId = widget.course['id']?.toString();
      if (courseId == null) {
        throw Exception('Course ID is required');
      }

      // Update course via provider
      print('About to update course with data: $updateData');
      final success = await courseProvider.updateCourse(courseId, updateData);
      print(
        'Update course result: success=$success, error=${courseProvider.error}',
      );

      if (success && mounted) {
        // Update local course data
        setState(() {
          widget.course.addAll(updateData);
          // Also update any display-friendly fields
          widget.course['totalSessions'] = sessions;
          widget.course['thumbnail'] = thumbnailUrl;
          widget.course['thumbnail_url'] = thumbnailUrl;

          if (startDate != null) {
            widget.course['startDate'] = startDate.toIso8601String().split(
              'T',
            )[0];
          }
          if (endDate != null) {
            widget.course['endDate'] = endDate.toIso8601String().split('T')[0];
          }
        });

        // Refresh the course provider to update the course list/portal
        // Use loadInstructorCourses instead of loadCourses for instructor view
        if (widget.course['instructor_id'] != null) {
          await courseProvider.loadInstructorCourses(
            widget.course['instructor_id'].toString(),
          );
        }

        // Reload course data to get fresh information
        await _loadCourseData();

        // Only show snackbar if context is still valid
        if (mounted && mainContext.mounted) {
          print('Showing success snackbar');
          final successMessage = 'Course updated successfully!';

          // Add a small delay to ensure dialog is fully closed
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && mainContext.mounted) {
              _showSnackBar(mainContext, successMessage, isError: false);
            }
          });
        }
      } else if (mounted && mainContext.mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && mainContext.mounted) {
            _showSnackBar(
              mainContext,
              courseProvider.error ?? 'Failed to update course',
              isError: true,
            );
          }
        });
      }
    } catch (e) {
      if (mounted && mainContext.mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && mainContext.mounted) {
            _showSnackBar(
              mainContext,
              'Failed to update course: $e',
              isError: true,
            );
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changeImage() async {
    try {
      print('Change image clicked');

      // Show image picker
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) {
        print('No image selected');
        return;
      }

      print('Image selected: ${image.path}');

      // Show loading state
      setState(() {
        _isLoading = true;
      });

      // Get course ID
      final courseId = widget.course['id']?.toString();
      if (courseId == null) {
        throw Exception('Course ID is required');
      }

      // Upload image
      print('Uploading image for course: $courseId');
      final newImageUrl = await _storageService.uploadCourseThumbnail(
        File(image.path),
        courseId,
      );

      print('Image uploaded successfully: $newImageUrl');

      // Update course with new image URL
      final courseProvider = context.read<CourseProvider>();
      final success = await courseProvider.updateCourse(courseId, {
        'thumbnail_url': newImageUrl,
      });

      if (success && mounted) {
        // Update local course data and force UI refresh
        setState(() {
          widget.course['thumbnail_url'] = newImageUrl;
          widget.course['thumbnail'] = newImageUrl;
          _imageUpdateKey++; // Force image widget to rebuild
          _isLoading = false;
        });

        // Refresh course provider
        if (widget.course['instructor_id'] != null) {
          await courseProvider.loadInstructorCourses(
            widget.course['instructor_id'].toString(),
          );
        }

        // Show success message
        if (mounted && context.mounted) {
          _showSnackBar(
            context,
            'Course image updated successfully!',
            isError: false,
          );
        }
      } else {
        throw Exception(courseProvider.error ?? 'Failed to update course');
      }
    } catch (e) {
      print('Failed to change image: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (context.mounted) {
          _showSnackBar(context, 'Failed to update image: $e', isError: true);
        }
      }
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    print('_showSnackBar called: message="$message", isError=$isError');
    // Double check that widget is still mounted and context is valid
    if (!mounted) return;

    try {
      // Use a post-frame callback to ensure the widget tree is stable
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: isError
                  ? Colors.red.shade600
                  : Colors.green.shade600,
              duration: Duration(seconds: isError ? 4 : 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      });
    } catch (e) {
      // Silently handle any context access errors
      print('Error showing snackbar: $e');
    }
  }

  @override
  void dispose() {
    // Clean up any pending operations
    super.dispose();
  }
}
