import 'package:flutter/material.dart';

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

  // Sample course reviews from students
  final List<Map<String, dynamic>> _courseReviews = [
    {
      'id': 'review_1',
      'studentName': 'Alice Johnson',
      'studentAvatar': 'A',
      'courseRating': 4.5,
      'courseMessage':
          'Excellent course structure! The material is well-organized and easy to follow.',
      'timestamp': '2025-08-05 2:30 PM',
      'type': 'positive',
    },
    {
      'id': 'review_2',
      'studentName': 'Bob Wilson',
      'studentAvatar': 'B',
      'courseRating': 4.0,
      'courseMessage': 'Good content but could use more practical examples.',
      'timestamp': '2025-08-04 11:20 AM',
      'type': 'constructive',
    },
    {
      'id': 'review_3',
      'studentName': 'Carol Smith',
      'studentAvatar': 'C',
      'courseRating': 5.0,
      'courseMessage':
          'Amazing course! Learned so much and the pace was perfect.',
      'timestamp': '2025-08-03 4:15 PM',
      'type': 'positive',
    },
  ];

  // Sample instructor reviews from students
  final List<Map<String, dynamic>> _instructorReviews = [
    {
      'id': 'instructor_review_1',
      'studentName': 'Emma Watson',
      'studentAvatar': 'E',
      'instructorRating': 4.8,
      'instructorMessage':
          'Very supportive instructor! Always available for questions and explains concepts clearly.',
      'timestamp': '2025-08-06 1:45 PM',
      'type': 'positive',
    },
    {
      'id': 'instructor_review_2',
      'studentName': 'Mike Johnson',
      'studentAvatar': 'M',
      'instructorRating': 4.2,
      'instructorMessage':
          'Great teaching style, could provide more detailed feedback on assignments.',
      'timestamp': '2025-08-05 9:30 AM',
      'type': 'constructive',
    },
  ];

  // Sample students list for giving feedback
  final List<Map<String, dynamic>> _students = [
    {
      'id': 'student_1',
      'name': 'Alice Johnson',
      'avatar': 'A',
      'progress': 85,
      'status': 'Active',
    },
    {
      'id': 'student_2',
      'name': 'Bob Wilson',
      'avatar': 'B',
      'progress': 72,
      'status': 'Active',
    },
    {
      'id': 'student_3',
      'name': 'Carol Smith',
      'avatar': 'C',
      'progress': 95,
      'status': 'Completed',
    },
    {
      'id': 'student_4',
      'name': 'Emma Watson',
      'avatar': 'E',
      'progress': 78,
      'status': 'Active',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF7A54FF);

    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final cardColor = Theme.of(context).cardColor;

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
                        'Feedback Management',
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
                  'View student reviews and provide personalized feedback',
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
                  'Course Rating',
                  '${(_courseReviews.fold<double>(0, (sum, r) => sum + r['courseRating']) / _courseReviews.length).toStringAsFixed(1)}',
                  Icons.school,
                  Colors.blue,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Instructor Rating',
                  '${(_instructorReviews.fold<double>(0, (sum, r) => sum + r['instructorRating']) / _instructorReviews.length).toStringAsFixed(1)}',
                  Icons.person,
                  Colors.green,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Total Reviews',
                  '${_courseReviews.length + _instructorReviews.length}',
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
            'Course Reviews from Students',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 10),

          ..._courseReviews.take(2).map((review) {
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
                            review['studentAvatar'],
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
                            review['studentName'],
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
                            color: _getRatingColor(
                              review['courseRating'],
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 10,
                                color: _getRatingColor(review['courseRating']),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                review['courseRating'].toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getRatingColor(
                                    review['courseRating'],
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
                      review['courseMessage'],
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review['timestamp'],
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
            'Instructor Reviews from Students',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 10),

          ..._instructorReviews.take(2).map((review) {
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
                            review['studentAvatar'],
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
                            review['studentName'],
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
                            color: _getRatingColor(
                              review['instructorRating'],
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 10,
                                color: _getRatingColor(
                                  review['instructorRating'],
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                review['instructorRating'].toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getRatingColor(
                                    review['instructorRating'],
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
                      review['instructorMessage'],
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review['timestamp'],
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
            'Give Student Feedback',
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
                    'Select Student',
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
                        'Choose a student...',
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                      isExpanded: true,
                      underline: Container(),
                      dropdownColor: cardColor,
                      style: TextStyle(color: textColor, fontSize: 12),
                      items: _students.map((student) {
                        return DropdownMenuItem<String>(
                          value: student['id'],
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: primaryColor.withOpacity(0.2),
                                child: Text(
                                  student['avatar'],
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
                                  student['name'],
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
                                    student['status'],
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  student['status'],
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: _getStatusColor(student['status']),
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
                    'Rate Student Performance',
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
                            : 'No rating',
                        style: TextStyle(fontSize: 11, color: subTextColor),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Feedback Message
                  Text(
                    'Feedback Message',
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
                      hintText:
                          'Share your feedback about student\'s performance, participation, areas for improvement...',
                      hintStyle: TextStyle(color: subTextColor, fontSize: 11),
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
                          (_selectedStudentId == null || _isSubmittingFeedback)
                          ? null
                          : _submitStudentFeedback,
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
                              'Send Feedback to Student',
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

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.orange;
    if (rating >= 3.0) return Colors.deepOrange;
    return Colors.red;
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

  void _submitStudentFeedback() async {
    if (_studentFeedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please write your feedback'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_studentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingFeedback = true;
    });

    // Simulate submission delay
    await Future.delayed(const Duration(seconds: 2));

    final selectedStudent = _students.firstWhere(
      (s) => s['id'] == _selectedStudentId,
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
          '✅ Feedback sent to ${selectedStudent['name']} successfully!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _studentFeedbackController.dispose();
    super.dispose();
  }
}
