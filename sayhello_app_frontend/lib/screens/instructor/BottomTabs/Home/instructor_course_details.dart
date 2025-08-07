import 'package:flutter/material.dart';
import '../../../../../../l10n/app_localizations.dart';

class InstructorCourseDetailsTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorCourseDetailsTab({super.key, required this.course});

  @override
  State<InstructorCourseDetailsTab> createState() =>
      _InstructorCourseDetailsTabState();
}

class _InstructorCourseDetailsTabState
    extends State<InstructorCourseDetailsTab> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    // Extract course data with fallback values
    final title = widget.course['title'] ?? 'Course Title';
    final description =
        widget.course['description'] ??
        'This is a comprehensive course designed to help students master the subject with practical examples and expert guidance.';
    final language = widget.course['language'] ?? 'English';
    final level = widget.course['level'] ?? 'Intermediate';
    final startDate = widget.course['startDate'] ?? '2025-07-15';
    final endDate = widget.course['endDate'] ?? '2025-09-15';
    final duration = widget.course['duration'] ?? '8 weeks';
    final totalSessions = widget.course['totalSessions'] ?? 24;
    final rating = widget.course['rating'] ?? 4.8;
    final enrolledStudents = widget.course['students'] ?? 48;
    final price =
        double.tryParse(widget.course['price']?.toString() ?? '79.99') ?? 79.99;
    final thumbnail = widget.course['thumbnail'] ?? '';
    final category = widget.course['category'] ?? 'Programming';
    final status = widget.course['status'] ?? 'active';

    // Instructor-specific data
    final completionRate = widget.course['completionRate'] ?? 85;
    final totalRevenue = enrolledStudents * price;

    // Color scheme
    final primaryColor = const Color(0xFF7A54FF);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return SingleChildScrollView(
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
            category,
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
        ],
      ),
    );
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
    String category,
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
        'title': localizations.category,
        'value': category,
        'icon': Icons.category,
      },
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
        'value': '\$${price.toStringAsFixed(0)}',
        'icon': Icons.attach_money,
      },
      {
        'title': localizations.starts,
        'value': startDate,
        'icon': Icons.calendar_today,
      },
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.edit, size: 16, color: Colors.white),
              label: Text(
                localizations.editCourseDetails,
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
        ],
      ),
    );
  }

  void _showEditCourseDialog(AppLocalizations localizations) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Controllers for form fields
    final titleController = TextEditingController(
      text: widget.course['title'] ?? '',
    );
    final descriptionController = TextEditingController(
      text: widget.course['description'] ?? '',
    );
    final priceController = TextEditingController(
      text: widget.course['price']?.toString() ?? '',
    );
    final sessionsController = TextEditingController(
      text: widget.course['totalSessions']?.toString() ?? '',
    );
    final thumbnailController = TextEditingController(
      text: widget.course['thumbnail'] ?? '',
    );
    final startDateController = TextEditingController(
      text: widget.course['startDate'] ?? '',
    );
    final endDateController = TextEditingController(
      text: widget.course['endDate'] ?? '',
    );

    String selectedLevel = widget.course['level'] ?? 'Beginner';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Text(
            localizations.editCourseDetailsTitle,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEditField(localizations.title, titleController, isDark),
                  const SizedBox(height: 12),
                  _buildEditField(
                    localizations.description,
                    descriptionController,
                    isDark,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  // Level Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedLevel,
                      decoration: InputDecoration(
                        labelText: localizations.level,
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      ),
                      dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                      items: ['Beginner', 'Intermediate', 'Advanced']
                          .map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLevel = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditField(
                          localizations.totalSessions,
                          sessionsController,
                          isDark,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildEditField(
                          localizations.priceWithSymbol,
                          priceController,
                          isDark,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildEditField(
                    localizations.thumbnailUrl,
                    thumbnailController,
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditField(
                          localizations.startDate,
                          startDateController,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildEditField(
                          localizations.endDate,
                          endDateController,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
              onPressed: () {
                // Update course data
                setState(() {
                  widget.course['title'] = titleController.text;
                  widget.course['description'] = descriptionController.text;
                  widget.course['level'] = selectedLevel;
                  widget.course['totalSessions'] =
                      int.tryParse(sessionsController.text) ?? 0;
                  widget.course['price'] =
                      double.tryParse(priceController.text) ?? 0.0;
                  widget.course['thumbnail'] = thumbnailController.text;
                  widget.course['startDate'] = startDateController.text;
                  widget.course['endDate'] = endDateController.text;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      localizations.courseDetailsUpdatedSuccessfully,
                    ),
                    backgroundColor: const Color(0xFF7A54FF),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
              ),
              child: Text(
                localizations.saveChanges,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    bool isDark, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontSize: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
      ),
    );
  }
}
