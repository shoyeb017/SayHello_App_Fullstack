import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import 'course_payment.dart';

class UnenrolledCourseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> course;

  const UnenrolledCourseDetailsPage({super.key, required this.course});

  @override
  State<UnenrolledCourseDetailsPage> createState() =>
      _UnenrolledCourseDetailsPageState();
}

class _UnenrolledCourseDetailsPageState
    extends State<UnenrolledCourseDetailsPage> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Extract all course data with fallback values - matching course_details.dart
    final title =
        widget.course['title'] ?? localizations.courseDetailsFallbackTitle;
    final description =
        widget.course['description'] ??
        localizations.courseDetailsFallbackDescription;
    final language =
        widget.course['language'] ??
        localizations.courseDetailsFallbackLanguage;
    final level =
        widget.course['level'] ?? localizations.courseDetailsFallbackLevel;
    final instructor =
        widget.course['instructor'] ??
        localizations.courseDetailsFallbackInstructor;
    final startDate = widget.course['startDate'] ?? '2025-07-15';
    final endDate = widget.course['endDate'] ?? '2025-09-15';
    final duration =
        widget.course['duration'] ??
        localizations.courseDetailsFallbackDuration;
    final status =
        widget.course['status'] ?? localizations.courseDetailsFallbackStatus;
    final rating = widget.course['rating'] ?? 4.7;
    final enrolledStudents = widget.course['students'] ?? 42;
    final price =
        double.tryParse(widget.course['price']?.toString() ?? '49.99') ?? 49.99;
    final thumbnail = widget.course['thumbnail'] ?? '';
    final category =
        widget.course['category'] ??
        localizations.courseDetailsFallbackCategory;
    final totalSessions = widget.course['totalSessions'] ?? 20;

    // Consistent color scheme with new theme
    final primaryColor = Color(0xFF7A54FF);
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = isDark ? Colors.grey[800] : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.courseDetails,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero-style Course Header (Unique Design)
                  _buildHeroCourseHeader(
                    title,
                    instructor,
                    thumbnail,
                    level,
                    status,
                    category,
                    duration,
                    rating,
                    price,
                    isDark,
                    primaryColor,
                    textColor,
                    cardColor,
                  ),

                  const SizedBox(height: 20),
                  // Quick Info Pills (Unique Layout)
                  _buildQuickInfoPills(
                    language,
                    totalSessions,
                    enrolledStudents,
                    isDark,
                    primaryColor,
                    textColor,
                    subTextColor,
                    cardColor,
                    localizations,
                  ),

                  const SizedBox(height: 20),
                  // Course Overview Card
                  _buildCourseOverviewCard(
                    description,
                    startDate,
                    endDate,
                    duration,
                    level,
                    isDark,
                    primaryColor,
                    textColor,
                    subTextColor,
                    cardColor,
                    localizations,
                  ),

                  const SizedBox(height: 20),
                  // Instructor Spotlight (Different from course details)
                  _buildInstructorSpotlight(
                    instructor,
                    isDark,
                    primaryColor,
                    textColor,
                    subTextColor,
                    cardColor,
                    localizations,
                  ),

                  const SizedBox(height: 20),
                  // Student Feedback Preview
                  _buildStudentFeedbackPreview(
                    rating,
                    isDark,
                    primaryColor,
                    textColor,
                    subTextColor,
                    cardColor,
                    localizations,
                  ),

                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
          ),

          // Enhanced Enrollment Action Bar
          _buildEnhancedEnrollmentBar(
            price,
            isDark,
            primaryColor,
            textColor,
            localizations,
          ),
        ],
      ),
    );
  }

  // Hero-style header with overlayed content (Unique Design)
  Widget _buildHeroCourseHeader(
    String title,
    String instructor,
    String thumbnail,
    String level,
    String status,
    String category,
    String duration,
    double rating,
    double price,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color? cardColor,
  ) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: thumbnail.isEmpty
            ? LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.8),
                  primaryColor,
                  primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        image: thumbnail.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(thumbnail),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Floating status and level badges
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
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
              ],
            ),
          ),

          // Price badge
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '\$${price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Bottom content overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.white.withOpacity(0.9),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.courseDetailsInstructorBy(instructor),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white.withOpacity(0.8),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.category,
                        color: Colors.white.withOpacity(0.8),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Quick info pills layout (Unique Design)
  Widget _buildQuickInfoPills(
    String language,
    int totalSessions,
    int enrolledStudents,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    Color? cardColor,
    AppLocalizations localizations,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoPill(
            localizations.courseDetailsLanguageLabel,
            language,
            Icons.language,
            primaryColor,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoPill(
            localizations.courseDetailsSessionsLabel,
            totalSessions.toString(),
            Icons.video_library,
            Colors.blue,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoPill(
            localizations.courseDetailsStudentsLabel,
            enrolledStudents.toString(),
            Icons.people,
            Colors.orange,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPill(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Course overview with timeline (Unique Design)
  Widget _buildCourseOverviewCard(
    String description,
    String startDate,
    String endDate,
    String duration,
    String level,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    Color? cardColor,
    AppLocalizations localizations,
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
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.courseDetailsOverviewTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: subTextColor, height: 1.5),
          ),
          const SizedBox(height: 18),

          // Course timeline
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      localizations.courseDetailsTimelineTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.courseDetailsStartDateLabel,
                            style: TextStyle(fontSize: 10, color: subTextColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            startDate,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      color: primaryColor.withOpacity(0.3),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            localizations.courseDetailsEndDateLabel,
                            style: TextStyle(fontSize: 10, color: subTextColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            endDate,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    localizations.courseDetailsDurationLevel(duration, level),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Instructor spotlight with different layout
  Widget _buildInstructorSpotlight(
    String instructor,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    Color? cardColor,
    AppLocalizations localizations,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Instructor avatar with decoration
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.person, color: Colors.white, size: 35),
          ),
          const SizedBox(height: 14),
          Text(
            instructor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            localizations.courseDetailsInstructorTitle,
            style: TextStyle(
              fontSize: 12,
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            localizations.courseDetailsInstructorDescription,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: subTextColor, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInstructorStat(
                '8+',
                localizations.courseDetailsInstructorYearsExp,
                Icons.school,
                primaryColor,
              ),
              _buildInstructorStat(
                '4.8',
                localizations.courseDetailsInstructorRating,
                Icons.star,
                Colors.amber,
              ),
              _buildInstructorStat(
                '1.2K',
                localizations.courseDetailsInstructorStudents,
                Icons.people,
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorStat(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  // Student feedback preview with different design
  Widget _buildStudentFeedbackPreview(
    double rating,
    bool isDark,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    Color? cardColor,
    AppLocalizations localizations,
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
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.feedback, color: Colors.amber, size: 20),
              const SizedBox(width: 10),
              Text(
                localizations.courseDetailsFeedbackTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rating overview
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < rating.floor()
                              ? Colors.amber
                              : Colors.grey[300],
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.courseDetailsHighlyRated,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.courseDetailsReviewsCount,
                      style: TextStyle(fontSize: 10, color: subTextColor),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        localizations.courseDetailsSatisfactionRate,
                        style: TextStyle(
                          fontSize: 9,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Enhanced enrollment bar with better styling
  Widget _buildEnhancedEnrollmentBar(
    double price,
    bool isDark,
    Color primaryColor,
    Color textColor,
    AppLocalizations localizations,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    localizations.courseDetailsOneTimePayment,
                    style: TextStyle(
                      fontSize: 9,
                      color: primaryColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CoursePaymentPage(course: widget.course),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        localizations.courseDetailsEnrollNow,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Color(0xFF7A54FF);
      case 'upcoming':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
