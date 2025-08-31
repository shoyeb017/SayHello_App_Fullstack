import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../providers/feedback_provider.dart';
import '../../../../../providers/auth_provider.dart';

class FeedbackTab extends StatefulWidget {
  final Map<String, dynamic> course;
  const FeedbackTab({super.key, required this.course});

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  final TextEditingController _courseFeedbackController =
      TextEditingController();
  final TextEditingController _instructorFeedbackController =
      TextEditingController();
  double _courseRating = 0.0;
  double _instructorRating = 0.0;
  bool _isSubmittingCourse = false;
  bool _isSubmittingInstructor = false;

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
        // Load feedback for this course (similar to instructor but for learner perspective)
        feedbackProvider.loadCourseFeedback(widget.course['id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);

    // Consistent theme colors
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = Theme.of(context).cardColor;

    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        // Get feedback data from provider
        final instructorFeedbacks = feedbackProvider.instructorFeedback;

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
                        Icon(Icons.feedback, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.courseFeedback,
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
                      AppLocalizations.of(context)!.reviewInstructorFeedback,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Instructor Feedback Section
              Text(
                AppLocalizations.of(context)!.feedbackFromInstructor,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 12),

              // Instructor Feedback List from Backend
              if (instructorFeedbacks.isEmpty)
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
                        'No feedback from instructor yet',
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ...instructorFeedbacks.take(3).map((feedback) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: primaryColor,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            feedback.instructorName ??
                                                'Instructor',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.verified,
                                          size: 12,
                                          color: primaryColor,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Instructor Feedback',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: subTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Rating
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRatingColor(
                                    feedback.rating.toDouble(),
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 10,
                                      color: _getRatingColor(
                                        feedback.rating.toDouble(),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${feedback.rating}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _getRatingColor(
                                          feedback.rating.toDouble(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Message
                          Text(
                            feedback.feedbackText,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Footer
                          Row(
                            children: [
                              Text(
                                feedback.formattedTimestamp,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: subTextColor,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Feedback',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 20),

              // Give Feedback Section
              Text(
                AppLocalizations.of(context)!.giveYourFeedback,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 12),

              // Course Feedback Form
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Feedback Header
                      Row(
                        children: [
                          Icon(Icons.school, color: primaryColor, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)!.courseFeedback,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Course Rating
                      Text(
                        AppLocalizations.of(context)!.rateCourse,
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
                                  _courseRating = index + 1.0;
                                });
                              },
                              child: Icon(
                                index < _courseRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: primaryColor,
                                size: 18,
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            _courseRating > 0
                                ? AppLocalizations.of(
                                    context,
                                  )!.ratingValue(_courseRating.toInt())
                                : AppLocalizations.of(context)!.noRating,
                            style: TextStyle(fontSize: 11, color: subTextColor),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Course Feedback Message
                      Text(
                        AppLocalizations.of(context)!.yourCourseFeedback,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _courseFeedbackController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.courseFeedbackHint,
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

                      // Submit Course Feedback Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmittingCourse
                              ? null
                              : () => _submitCourseFeedback(feedbackProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmittingCourse
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
                                  AppLocalizations.of(
                                    context,
                                  )!.submitCourseFeedback,
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

              const SizedBox(height: 12),

              // Instructor Feedback Form
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instructor Feedback Header
                      Row(
                        children: [
                          Icon(Icons.person, color: primaryColor, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)!.instructorFeedback,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Instructor Rating
                      Text(
                        AppLocalizations.of(context)!.rateInstructor,
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
                                  _instructorRating = index + 1.0;
                                });
                              },
                              child: Icon(
                                index < _instructorRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: primaryColor,
                                size: 18,
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            _instructorRating > 0
                                ? AppLocalizations.of(
                                    context,
                                  )!.ratingValue(_instructorRating.toInt())
                                : AppLocalizations.of(context)!.noRating,
                            style: TextStyle(fontSize: 11, color: subTextColor),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Instructor Feedback Message
                      Text(
                        AppLocalizations.of(context)!.yourInstructorFeedback,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _instructorFeedbackController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.instructorFeedbackHint,
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

                      // Submit Instructor Feedback Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmittingInstructor
                              ? null
                              : () =>
                                    _submitInstructorFeedback(feedbackProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmittingInstructor
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
                                  AppLocalizations.of(
                                    context,
                                  )!.submitInstructorFeedback,
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

              const SizedBox(height: 20),

              // Recent Feedback Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, color: primaryColor, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.feedbackSummary,
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
                          child: _buildSummaryCard(
                            AppLocalizations.of(context)!.averageRating,
                            instructorFeedbacks.isNotEmpty
                                ? (instructorFeedbacks.fold<double>(
                                            0,
                                            (sum, f) => sum + f.rating,
                                          ) /
                                          instructorFeedbacks.length)
                                      .toStringAsFixed(1)
                                : '0.0',
                            Icons.star,
                            Colors.amber,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryCard(
                            AppLocalizations.of(context)!.totalFeedback,
                            '${instructorFeedbacks.length}',
                            Icons.comment,
                            primaryColor,
                            isDark,
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
      },
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.orange;
    if (rating >= 3.0) return Colors.deepOrange;
    return Colors.red;
  }

  void _submitCourseFeedback(FeedbackProvider feedbackProvider) async {
    if (_courseFeedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseWriteCourseFeedback,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_courseRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseRateCourse),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingCourse = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await feedbackProvider.submitCourseFeedback(
        courseId: widget.course['id'],
        learnerId: authProvider.currentUser?.id ?? '',
        instructorId: widget.course['instructor_id'] ?? '',
        feedbackText: _courseFeedbackController.text.trim(),
        rating: _courseRating.round(),
      );

      if (success) {
        setState(() {
          _isSubmittingCourse = false;
          _courseFeedbackController.clear();
          _courseRating = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.courseFeedbackSubmitted,
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isSubmittingCourse = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit feedback: ${feedbackProvider.error}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _isSubmittingCourse = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit feedback: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitInstructorFeedback(FeedbackProvider feedbackProvider) async {
    if (_instructorFeedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseWriteInstructorFeedback,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_instructorRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseRateInstructor),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingInstructor = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await feedbackProvider.submitInstructorFeedback(
        courseId: widget.course['id'],
        learnerId: authProvider.currentUser?.id ?? '',
        instructorId: widget.course['instructor_id'] ?? '',
        feedbackText: _instructorFeedbackController.text.trim(),
        rating: _instructorRating.round(),
      );

      if (success) {
        setState(() {
          _isSubmittingInstructor = false;
          _instructorFeedbackController.clear();
          _instructorRating = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.instructorFeedbackSubmitted,
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isSubmittingInstructor = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit feedback: ${feedbackProvider.error}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _isSubmittingInstructor = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit feedback: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _courseFeedbackController.dispose();
    _instructorFeedbackController.dispose();
    super.dispose();
  }
}
