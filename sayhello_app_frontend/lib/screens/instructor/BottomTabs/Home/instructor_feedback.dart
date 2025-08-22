import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../providers/feedback_provider.dart';
import '../../../../../../providers/auth_provider.dart';
import '../../../../../../models/feedback.dart' as feedback_model;

class InstructorFeedbackTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const InstructorFeedbackTab({super.key, required this.course});

  @override
  State<InstructorFeedbackTab> createState() => _InstructorFeedbackTabState();
}

class _InstructorFeedbackTabState extends State<InstructorFeedbackTab> {
  final TextEditingController _studentFeedbackController =
      TextEditingController();
  double _studentRating = 0.0;
  bool _isSubmittingFeedback = false;
  String? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final feedbackProvider = Provider.of<FeedbackProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null) {
        // Load instructor feedback and course students
        feedbackProvider.loadInstructorFeedback(authProvider.currentUser!.id);
        feedbackProvider.loadCourseFeedback(widget.course['id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);
    final localizations = AppLocalizations.of(context)!;

    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = Theme.of(context).cardColor;

    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        final instructorFeedbacks = feedbackProvider.instructorFeedback;
        final courseFeedbacks = instructorFeedbacks
            .where((f) => f.feedbackType == feedback_model.FeedbackType.course)
            .toList();
        final instructorFeedbacksOnly = instructorFeedbacks
            .where(
              (f) => f.feedbackType == feedback_model.FeedbackType.instructor,
            )
            .toList();

        // Calculate average ratings
        final avgCourseRating = courseFeedbacks.isNotEmpty
            ? courseFeedbacks.fold<double>(0, (sum, f) => sum + f.rating) /
                  courseFeedbacks.length
            : 0.0;
        final avgInstructorRating = instructorFeedbacksOnly.isNotEmpty
            ? instructorFeedbacksOnly.fold<double>(
                    0,
                    (sum, f) => sum + f.rating,
                  ) /
                  instructorFeedbacksOnly.length
            : 0.0;

        if (feedbackProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primaryColor),
                SizedBox(height: 16),
                Text('Loading feedback...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.8), primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
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
                        Icon(Icons.rate_review, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            localizations.feedbackManagement,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.viewStudentReviewsDescription,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      localizations.courseRating,
                      avgCourseRating > 0
                          ? avgCourseRating.toStringAsFixed(1)
                          : '0.0',
                      Icons.school,
                      Colors.blue,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      localizations.instructorRating,
                      avgInstructorRating > 0
                          ? avgInstructorRating.toStringAsFixed(1)
                          : '0.0',
                      Icons.person,
                      Colors.green,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      localizations.totalReviews,
                      '${instructorFeedbacks.length}',
                      Icons.comment,
                      primaryColor,
                      isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Course Reviews Section
              Text(
                localizations.courseReviewsFromStudents,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 10),

              // Show course feedbacks
              if (courseFeedbacks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, color: subTextColor, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'No course reviews yet',
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ...courseFeedbacks.take(2).map((feedback) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
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
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue.withOpacity(0.2),
                                child: Text(
                                  feedback.learnerName?.isNotEmpty == true
                                      ? feedback.learnerName![0].toUpperCase()
                                      : 'S',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feedback.learnerName ?? 'Student',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getColorFromHex(
                                    feedback.ratingColor,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 10,
                                      color: _getColorFromHex(
                                        feedback.ratingColor,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      feedback.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getColorFromHex(
                                          feedback.ratingColor,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            feedback.feedbackText,
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feedback.formattedTimestamp,
                            style: TextStyle(fontSize: 9, color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 16),

              // Instructor Reviews Section
              Text(
                localizations.instructorReviewsFromStudents,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 10),

              // Show instructor feedbacks
              if (instructorFeedbacksOnly.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, color: subTextColor, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'No instructor reviews yet',
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ...instructorFeedbacksOnly.take(2).map((feedback) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
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
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.green.withOpacity(0.2),
                                child: Text(
                                  feedback.learnerName?.isNotEmpty == true
                                      ? feedback.learnerName![0].toUpperCase()
                                      : 'S',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feedback.learnerName ?? 'Student',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getColorFromHex(
                                    feedback.ratingColor,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 10,
                                      color: _getColorFromHex(
                                        feedback.ratingColor,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      feedback.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getColorFromHex(
                                          feedback.ratingColor,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            feedback.feedbackText,
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feedback.formattedTimestamp,
                            style: TextStyle(fontSize: 9, color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 16),

              // Give Student Feedback Section
              Text(
                localizations.giveStudentFeedback,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Student Selection
                      Text(
                        localizations.selectStudent,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedStudentId,
                          hint: Text(
                            localizations.chooseAStudent,
                            style: TextStyle(color: subTextColor, fontSize: 12),
                          ),
                          isExpanded: true,
                          underline: Container(),
                          dropdownColor: cardColor,
                          style: TextStyle(color: textColor, fontSize: 12),
                          items: feedbackProvider.courseStudents.map((student) {
                            return DropdownMenuItem<String>(
                                value: student['id'],
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: primaryColor.withOpacity(
                                        0.2,
                                      ),
                                      child: Text(
                                        student['name']
                                                ?.toString()
                                                .substring(0, 1)
                                                .toUpperCase() ??
                                            'S',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        student['name'] ?? 'Unknown Student',
                                        style: TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          student['status'] ?? 'Active',
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        student['status'] ?? 'Active',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: _getStatusColor(
                                            student['status'] ?? 'Active',
                                          ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStudentId = value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Rating
                      Text(
                        localizations.rateStudentPerformance,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _studentRating = index + 1.0;
                                });
                              },
                              child: Icon(
                                index < _studentRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: primaryColor,
                                size: 18,
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            _studentRating > 0
                                ? '${_studentRating.toInt()}/5'
                                : localizations.noRating,
                            style: TextStyle(fontSize: 11, color: subTextColor),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Feedback Message
                      Text(
                        localizations.feedbackMessage,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _studentFeedbackController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: localizations.feedbackHintText,
                          hintStyle: TextStyle(
                            color: subTextColor,
                            fontSize: 11,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          contentPadding: const EdgeInsets.all(10),
                        ),
                        style: TextStyle(color: textColor, fontSize: 11),
                      ),

                      const SizedBox(height: 12),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (_selectedStudentId == null ||
                                  _isSubmittingFeedback)
                              ? null
                              : () => _submitStudentFeedback(localizations),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmittingFeedback
                              ? SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  localizations.sendFeedbackToStudent,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'At Risk':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _getColorFromHex(String hexColor) {
    // Remove the # if present
    hexColor = hexColor.replaceAll('#', '');
    // Add FF for alpha if not present
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  void _submitStudentFeedback(AppLocalizations localizations) async {
    if (_studentFeedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.pleaseWriteYourFeedback),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_studentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.pleaseProvideARating),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a student'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingFeedback = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final feedbackProvider = Provider.of<FeedbackProvider>(
        context,
        listen: false,
      );

      final success = await feedbackProvider.submitStudentFeedback(
        courseId: widget.course['id'],
        instructorId: authProvider.currentUser?.id ?? '',
        learnerId: _selectedStudentId!,
        feedbackText: _studentFeedbackController.text.trim(),
        feedbackAbout: 'student_performance',
        rating: _studentRating.round(),
      );

      if (success) {
        // Find selected student name for success message
        final selectedStudent = feedbackProvider.courseStudents.firstWhere(
          (s) => s['id'] == _selectedStudentId,
          orElse: () => {'name': 'Student'},
        );

        setState(() {
          _isSubmittingFeedback = false;
          _studentFeedbackController.clear();
          _studentRating = 0.0;
          _selectedStudentId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Feedback sent successfully to ${selectedStudent['name']}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isSubmittingFeedback = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send feedback: ${feedbackProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _isSubmittingFeedback = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send feedback: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _studentFeedbackController.dispose();
    super.dispose();
  }
}
